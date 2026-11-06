# Masterless Salt

Salt manages home-directory configuration, software installation, and dependencies
on Debian/Ubuntu and macOS. State files under `provisioning/salt/` define the
desired system; `top.sls` selects states by operating system and machine role.
Clone the repository with Git. The runner reads the machine role from a Salt
custom grain.

The [configuration guide](configuration.md) describes shared paths, ownership,
and permission defaults. All tracked configuration sources now live in Salt's
file tree.

Salt runs on demand with `salt-call --local`. No Salt master, key exchange,
background minion, or open ports are needed. Run the stack explicitly through
`scripts/provision`.

## Bootstrap on a fresh system

Install Git and clone this repository as described in the main README's
[bootstrap instructions](../README.md#bootstrap-new-machine). The examples below
use `~/dotfiles`; substitute your actual checkout path if different. Existing
checkouts under `~/.local/share/chezmoi` can stay there.

Install Salt separately using the steps below, set up the
[machine role](#machine-role), then preview and apply the Salt states for software
and configuration.
These instructions cover Debian/Ubuntu and macOS; the runner requires Bash
and Python 3. On Debian/Ubuntu, install Python with
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
cd "$HOME/dotfiles"
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
cd "$HOME/dotfiles"
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

To roll out changes gradually, name one or more state files after the mode.
Only those states and the files they include run, regardless of `top.sls`:

```bash
sudo bash scripts/provision preview configuration.zshrc
sudo bash scripts/provision apply pyenv virtualization
```

State names are SLS paths under `provisioning/salt/` without `.sls`, using dots
for subdirectories. Finish with a full apply so the whole stack converges.

The runner uses the repository's configuration and state tree, and removes its
private temporary cache and keys after each run. It does not modify `/etc/salt`.
It targets the invoking user's account. When invoked through sudo, it resolves
`SUDO_USER` through the operating system's account database. Run from your normal account, using sudo for system provisioning;
direct root logins are rejected.

The runner passes your `desktop`/`server` role and account into Salt as local
pillar data. A missing, invalid, or unreadable role grain stops provisioning.
Desktop-only states are skipped on servers. Changing the role to server does
not uninstall existing desktop software. User commands run as the original
user with their home and platform-appropriate data directories. Salt also manages
application settings and declarative lists.

## Machine role

The machine role is Salt's static custom grain `role` in
`~/.config/salt/grains` on both Linux and macOS:

```yaml
role: desktop  # or server
```

This is a standard Salt grains file: there is no enclosing `grains:` key.
See [Salt's grains documentation](https://docs.saltproject.io/en/latest/topics/grains/index.html).
There is no implicit desktop fallback. The runner copies this file beside its
isolated minion configuration and asks Salt to read the grain, then passes the
validated role into the existing pillar context. It does not load `/etc/salt/minion`
or start a daemon. Each invocation reads the current grains file.
The path is resolved from the target account's home directory, including under
sudo; inherited `HOME` and `XDG_CONFIG_HOME` do not change it.
This user path is the runner's convention; Salt loads the copied file through
its normal configuration-directory mechanism.

Choose `desktop` or `server` explicitly. On an existing machine, preserve its
current role when setting up the grains file.

As your normal user, create Salt's configuration directory if necessary, then
edit the grains file:

```bash
mkdir -p "$HOME/.config/salt"
chmod 700 "$HOME/.config/salt"
${EDITOR:-vi} "$HOME/.config/salt/grains"
chmod 600 "$HOME/.config/salt/grains"
```

Add or update only `role`, preserving any other grains. For a new file,
use your own account as owner and mode `0600`.
Grains are machine metadata; keep secrets outside this file.

The grain is local to each machine and is not managed by this stack. Preview
before applying a role change. Servers skip desktop states without removing
existing resources.

## Apply changes committed later

On each machine, pull the repository, then preview and apply Salt states:

```bash
cd "$HOME/dotfiles"
git pull --ff-only
sudo bash scripts/provision preview
sudo bash scripts/provision apply
```

Resolve any local changes or divergent history if `git pull --ff-only` fails
before proceeding. Review the previews before running the corresponding apply
command. Salt preview reports planned software and configuration changes.
The Salt commands above are for Debian/Ubuntu; omit `sudo` on macOS.

Use `git pull --ff-only` to update this checkout. Salt changes are applied only
when you run the runner; pulling commits alone does not apply them. Re-running
Salt evaluates the current desired state each time.

Updating these states does not upgrade the Salt runtime. Upgrade Salt separately
through apt (within the pinned LTS series) or a newer macOS installer. Review the
official installation guide before changing the pinned major version.

## Add more states

Add an SLS file under `provisioning/salt/` and list its name in `top.sls`.
Express dependencies using Salt requisites such as `require`, and keep each
state scoped to the supported operating systems and machine roles. Read the
role and target account from the `dotfiles` pillar; the `role` grain is the
source of role selection. Keep software installation states separate from configuration
states under `provisioning/salt/configuration/`.

Validate with a preview, an apply, and a second apply that reports no changes.
Also validate on a fresh machine or disposable VM when changing bootstrap
dependencies. Salt preview is described in the
[state testing documentation](https://docs.saltproject.io/en/latest/ref/states/testing.html).
