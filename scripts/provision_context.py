"""Build local Salt pillar from the invoking user's chezmoi configuration."""

import json
import os
from pathlib import Path
import pwd
import re
import shutil
import subprocess
import sys


def build_context(repo):
    if os.geteuid() == 0:
        username = os.environ.get("SUDO_USER")
        if not username or username == "root":
            raise ValueError("Run provisioning from your user account using sudo, not a root login.")
        account = pwd.getpwnam(username)
    else:
        account = pwd.getpwuid(os.getuid())
    if account.pw_uid == 0:
        raise ValueError("The provisioning target must be a non-root user.")

    # sudo may remove user-installed executables from PATH.
    chezmoi = shutil.which("chezmoi")
    if not chezmoi:
        for directory in (Path(account.pw_dir) / ".local/bin", Path("/opt/homebrew/bin")):
            candidate = directory / "chezmoi"
            if candidate.is_file() and os.access(candidate, os.X_OK):
                chezmoi = str(candidate)
                break
    if not chezmoi:
        raise ValueError("chezmoi is required to read the machine role.")

    command = [chezmoi, "--source", str(repo), "execute-template",
               '{{ dict "role" (get . "role" | default "desktop") | toJson }}']
    if os.geteuid() == 0:
        command = ["sudo", "-H", "-u", account.pw_name, "--", *command]
    data = json.loads(subprocess.check_output(command, text=True))
    role = data.get("role")
    if role not in ("desktop", "server"):
        raise ValueError("chezmoi role must be desktop or server.")

    extensions = []
    if role == "desktop":
        for line in (repo / "dot_config/Code/User/extensions.txt").read_text().splitlines():
            extension = line.strip()
            if not extension or extension.startswith("#"):
                continue
            if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]*\.[A-Za-z0-9][A-Za-z0-9_-]*", extension):
                raise ValueError(f"Invalid VS Code extension ID: {extension!r}")
            if extension.lower() not in extensions:
                extensions.append(extension.lower())

    return {"dotfiles": {"role": role, "user": account.pw_name,
                         "home": account.pw_dir, "vscode_extensions": extensions}}


if __name__ == "__main__":
    try:
        print(json.dumps(build_context(Path(__file__).resolve().parent.parent)))
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError) as error:
        sys.exit(f"Cannot read provisioning context: {error}")
