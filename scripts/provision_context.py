"""Build local Salt pillar from the invoking account and Salt's role grain."""

import json
import grp
import os
from pathlib import Path
import pwd
import re
import sys


def target_account():
    if os.geteuid() == 0:
        username = os.environ.get("SUDO_USER")
        if not username or username == "root":
            raise ValueError("Run provisioning from your user account using sudo, not a root login.")
        account = pwd.getpwnam(username)
    else:
        account = pwd.getpwuid(os.getuid())
    if account.pw_uid == 0:
        raise ValueError("The provisioning target must be a non-root user.")
    return account


def build_context(repo, role):
    account = target_account()

    if role not in ("desktop", "server"):
        raise ValueError(
            "Salt grain role must be desktop or server. "
            "Set it in ~/.config/salt/grains; see docs/salt.md#machine-role."
        )

    extensions = []
    if role == "desktop":
        for line in (repo / "provisioning/salt/files/vscode/extensions.txt").read_text().splitlines():
            extension = line.strip()
            if not extension or extension.startswith("#"):
                continue
            if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]*\.[A-Za-z0-9][A-Za-z0-9_-]*", extension):
                raise ValueError(f"Invalid VS Code extension ID: {extension!r}")
            if extension.lower() not in extensions:
                extensions.append(extension.lower())

    return {"dotfiles": {"role": role, "user": account.pw_name,
                         "group": grp.getgrgid(account.pw_gid).gr_name,
                         "home": account.pw_dir, "vscode_extensions": extensions}}


if __name__ == "__main__":
    try:
        if sys.argv[1:] == ["--grains-file"]:
            print(Path(target_account().pw_dir) / ".config/salt/grains")
            sys.exit(0)
        if sys.argv[1:]:
            raise ValueError("Usage: provision_context.py [--grains-file]")
        role = json.load(sys.stdin)["local"]
        print(json.dumps(build_context(Path(__file__).resolve().parent.parent, role)))
    except (ValueError, KeyError, OSError) as error:
        sys.exit(f"Cannot read provisioning context: {error}")
