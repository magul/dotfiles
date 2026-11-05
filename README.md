# dotfiles

Dotfiles and software managed by masterless Salt on Debian/Ubuntu and macOS.
The runner reads the machine role from Salt's `role` grain in
`~/.config/salt/grains`.

## Bootstrap (new machine)

Install Git first: on Debian/Ubuntu, use `sudo apt-get install -y git`; on macOS,
run `xcode-select --install` if needed and finish installing the Command Line Tools.
Clone the repository as your normal user:

```bash
git clone https://github.com/magul/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
```

Follow the [Salt bootstrap instructions](docs/salt.md#bootstrap-on-a-fresh-system)
to install Salt, set `role: desktop` or `role: server` in
`~/.config/salt/grains`, then preview and apply the stack. On macOS, Salt also
bootstraps Homebrew.

You can clone anywhere; commands below use `~/dotfiles` as an example. If you
already have this checkout under `~/.local/share/chezmoi`, keep using that directory
instead of cloning again. The runner works from any checkout location.

## Software provisioning with Salt

Salt manages software installation, dependencies, and all tracked configuration.
See [Salt setup and updates](docs/salt.md) for fresh-system installation and how
to apply newly committed changes. Salt is invoked explicitly:

```bash
cd "$HOME/dotfiles"
sudo bash scripts/provision preview
sudo bash scripts/provision apply
```

These commands use root for Debian/Ubuntu package management. On macOS, run
without `sudo` so Homebrew runs under your own account.
Run the Salt runner explicitly after pulling changes.

## Daily usage

Edit configuration sources under `provisioning/salt/files/` and their states under
`provisioning/salt/configuration/`. Preview and apply with the Salt runner.

After pulling changes, run Salt preview and apply as described in
[Salt setup and updates](docs/salt.md#apply-changes-committed-later).

## Machine role

The OS is detected automatically; `role` selects desktop or server behavior
independently of macOS/Linux. Desktop machines receive the desktop states and
configuration in addition to the shared CLI tools. Servers receive only the
shared states and configuration. Software and configuration selection is defined
in `provisioning/salt/top.sls`.

Set `role: desktop` or `role: server` in `~/.config/salt/grains`.
See [machine-role setup](docs/salt.md#machine-role) for details.

Then preview and apply Salt changes. Missing or invalid roles stop provisioning.
Switching to server skips desktop configuration and software states; it does not
remove existing files or uninstall applications. Switching back to desktop manages
those resources again on the next apply.

## How it works

Configuration sources live under `provisioning/salt/files/`; states under
`provisioning/salt/configuration/` select destinations, permissions, and dependencies.
The provisioning runner reads these files directly from this repository.

## Adding OS-specific config

Use Salt Jinja templates for platform differences and select operating systems
and machine roles in the state and `top.sls`; see the
[configuration guide](docs/configuration.md).

## Repo structure

```
.
├── .gitignore
├── docs/
│   └── salt.md                # Salt bootstrap, apply, and update workflow
├── provisioning/
│   ├── config/minion          # repository-local Salt configuration
│   └── salt/                  # software states and top.sls selection
├── scripts/
│   ├── provision              # preview/apply runner
│   └── provision_context.py   # local role and user context for Salt
├── LICENSE
└── README.md
```
