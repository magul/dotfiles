# Masterless Salt

Salt manages home-directory configuration, software installation, and dependencies
on Debian/Ubuntu and macOS. State files under `provisioning/salt/` define the
desired system; `top.sls` selects states by operating system and machine role.
Chezmoi still initializes the repository and supplies the machine role.

The [configuration guide](configuration.md) describes shared paths, ownership,
and permission defaults. All tracked configuration sources now live in Salt's
file tree.

Salt runs on demand with `salt-call --local`. No Salt master, key exchange,
background minion, or open ports are needed. There is no automatic Salt hook in
`chezmoi apply` or `chezmoi update`.

## Bootstrap on a fresh system

First install chezmoi and initialize this repository using the main README's
bootstrap instructions. Install Salt separately using the steps below, preview
and apply the Salt states for software and configuration. Chezmoi alone does
not deploy the managed files or install software.
These instructions cover Debian/Ubuntu and macOS; the runner requires Bash,
Python 3, and chezmoi. On Debian/Ubuntu, install Python with
`sudo apt-get install -y python3` if needed. On macOS, the runner looks for
Python in Salt's standalone installation before falling back to `python3` on
PATH; Homebrew is not required to start the runner.

### Debian / Ubuntu

Install the official Salt packages. Run these commands in Bash so a failed
download stops the pipeline:

```bash
bash
set -euo pipefail
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp >/dev/null
sudo chmod 0644 /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources \
  | sudo tee /etc/apt/sources.list.d/salt.sources >/dev/null
# Stay on the 3008 LTS series while receiving its patch releases.
printf 'Package: salt-*\nPin: version 3008.*\nPin-Priority: 1001\n' \
  | sudo tee /etc/apt/preferences.d/salt-pin-1001 >/dev/null
sudo apt-get update
sudo apt-get install -y salt-minion
sudo systemctl disable --now salt-minion
salt-call --version
exit
```

The `salt-minion` package supplies `salt-call`. Disable the daemon on this fresh
masterless installation; the runner invokes Salt directly.
The package series and repository setup follow the
[official DEB installation guide](https://docs.saltproject.io/salt/install-guide/en/latest/topics/install-by-operating-system/linux-deb.html).

### macOS

Download and install the LTS `.pkg` matching `uname -m` (`arm64` or `x86_64`)
from the [official macOS installation guide](https://docs.saltproject.io/salt/install-guide/en/latest/topics/install-by-operating-system/macos.html).
Skip its master configuration and service-start steps. If the installer starts
the minion, stop it:

```bash
sudo launchctl stop com.saltstack.salt.minion
salt-call --version
```

Salt bootstraps Homebrew and manages macOS software through Homebrew and native
user installers. Install Salt from the standalone `.pkg` above, independently
of Homebrew. The runner detects the usual Salt and Homebrew paths on Intel and
Apple Silicon Macs and runs as your current user.

The Homebrew installer may need Apple's Command Line Tools. If missing, run
`xcode-select --install` and finish installation before applying Salt. On a fresh
Mac, prepare administrator credentials with `sudo -v`, then run Salt without sudo:

```bash
cd "$(chezmoi source-path)"
bash scripts/provision preview
sudo -v
bash scripts/provision apply
bash scripts/provision apply  # should report no further changes
```

The Homebrew installer runs non-interactively as your user and uses sudo only
where required internally. If credentials expire, run `sudo -v` and retry. The
runner rejects root execution on macOS. Already-installed Homebrew is skipped.
See the [Homebrew installation guide](https://docs.brew.sh/Installation.html).

When Homebrew is missing, preview shows only its bootstrap state because Salt's
Homebrew package provider cannot load yet. Apply bootstraps Homebrew in a separate
Salt process, then runs the full stack. Rerun preview afterward to inspect package
states with the provider available.

macOS state rendering is checked on Linux; installation on a Mac remains untested.

### Run the stack

On Debian/Ubuntu, run both preview and apply as root so they use the same package
manager context:

```bash
cd "$(chezmoi source-path)"
sudo bash scripts/provision preview
sudo bash scripts/provision apply
sudo bash scripts/provision apply  # should report no further changes
```

Preview reports planned changes; apply brings the system into the desired state.
A second apply should report no further changes.

On macOS, use `bash scripts/provision preview` and `bash scripts/provision apply`
without `sudo` so Homebrew and native installers run under your own account.
Other operating systems have no package states selected by this stack.
Omitting the argument defaults to preview. Preview uses Salt's `test=True`;
apply uses `test=False`. The runner returns Salt's failure status.

The runner uses the repository's configuration and state tree, and removes its
private temporary cache and keys after each run. It does not modify `/etc/salt`.
It runs with the invoking user's
privileges. When invoked through sudo, it reads the original user's chezmoi
configuration through `sudo -H -u "$SUDO_USER"`. Run from your normal account,
using sudo for system provisioning; direct root logins are rejected.

The runner passes your existing chezmoi `desktop`/`server` role and account into
Salt as local pillar data. A missing role retains chezmoi's legacy desktop
default; an invalid role or unreadable configuration stops provisioning.
Desktop-only states are skipped on servers. Changing the role to server does
not uninstall existing desktop software. User commands run as the original
user with their home and platform-appropriate data directories. Salt also manages
application settings and declarative lists.

## Apply changes committed later

On each machine, pull the repository, then preview and apply Salt states:

```bash
cd "$(chezmoi source-path)"
git pull --ff-only
sudo bash scripts/provision preview
sudo bash scripts/provision apply
```

Resolve any local changes or divergent history if `git pull --ff-only` fails
before proceeding. Review the previews before running the corresponding apply
command. Salt preview reports planned software and configuration changes.
The Salt commands above are for Debian/Ubuntu; omit `sudo` on macOS.

If you normally use `chezmoi update`, follow it with the two
`scripts/provision` commands above. Salt changes
are applied only when you run the runner; pulling commits alone does not apply
them. Re-running Salt evaluates the current desired state each time.

Updating these states does not upgrade the Salt runtime. Upgrade Salt separately
through apt (within the pinned LTS series) or a newer macOS installer. Review the
official installation guide before changing the pinned major version.

## Add more states

Add an SLS file under `provisioning/salt/` and list its name in `top.sls`.
Express dependencies using Salt requisites such as `require`, and keep each
state scoped to the supported operating systems and machine roles. Read the
role and target account from the `dotfiles` pillar; chezmoi remains the source
of role selection. Keep software installation states separate from configuration
states under `provisioning/salt/configuration/`.

Validate with a preview, an apply, and a second apply that reports no changes.
Also validate on a fresh machine or disposable VM when changing bootstrap
dependencies. Salt preview is described in the
[state testing documentation](https://docs.saltproject.io/en/latest/ref/states/testing.html).
