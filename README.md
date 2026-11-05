# dotfiles

Dotfiles and software managed by masterless Salt on Debian/Ubuntu and macOS.
[Chezmoi](https://www.chezmoi.io/) still initializes the repository and supplies
the machine role.

## Bootstrap (new machine)

Install chezmoi and initialize the repository:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init magul
```

On first run, chezmoi prompts for your name, email, and machine role (`desktop`
or `server`). Follow the [Salt bootstrap instructions](docs/salt.md) to install
Salt and provision software and configuration. On macOS, Salt also bootstraps Homebrew.

Preview and apply software and configuration with the Salt runner as described
below. `chezmoi apply` no longer deploys configuration files.

## Manual setup

Install chezmoi:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
```

Initialize the repository:

```bash
chezmoi init magul/dotfiles
```

Complete the Salt bootstrap above, then preview and apply configuration.

## Software provisioning with Salt

Salt manages software installation, dependencies, and all tracked configuration.
Chezmoi remains a bootstrap and machine-role dependency.
See [Salt setup and updates](docs/salt.md) for fresh-system installation and how
to apply newly committed changes. Salt is invoked explicitly:

```bash
cd "$(chezmoi source-path)"
sudo bash scripts/provision preview
sudo bash scripts/provision apply
```

These commands use root for Debian/Ubuntu package management. On macOS, run
without `sudo` so Homebrew runs under your own account.
Salt is invoked separately from `chezmoi apply` and `chezmoi update`.

## Daily usage

Edit configuration sources under `provisioning/salt/files/` and their states under
`provisioning/salt/configuration/`. Preview and apply with the Salt runner.

After pulling changes, run Salt preview and apply as described in
[Salt setup and updates](docs/salt.md#apply-changes-committed-later).

## Machine role

The OS is detected automatically; `role` selects desktop or server behavior
independently of macOS/Linux. Desktop machines receive the desktop states and
configuration in addition to the shared CLI tools. Servers receive only the
shared states and configuration. Software and migrated configuration selection
is defined in `provisioning/salt/top.sls`. `.chezmoiignore` excludes repository
support files from home-directory targets.

On an existing machine, run `chezmoi edit-config` and add `role` to the existing
`[data]` section (preserve your other entries):

```toml
[data]
    role = "server" # or "desktop"
```

Then preview and apply Salt changes. Machines without a role
retain desktop behavior. Switching to server skips desktop configuration and
software states; it does not remove existing files or uninstall applications.
Switching back to desktop manages those resources again on the next apply.

## How it works

Configuration sources live under `provisioning/salt/files/`; states under
`provisioning/salt/configuration/` select destinations, permissions, and dependencies.
The provisioning runner reads these files directly from this repository.
Chezmoi has no remaining home-directory targets.

## Adding OS-specific config

Use Salt Jinja templates for platform differences and select operating systems
and machine roles in the state and `top.sls`; see the
[configuration migration guide](docs/configuration.md).

## Repo structure

```
.
├── .chezmoi.toml.tmpl          # prompts for identity and machine role on init
├── .chezmoiignore              # files to exclude from home directory
├── .gitignore
├── docs/
│   └── salt.md                # Salt bootstrap, apply, and update workflow
├── provisioning/
│   ├── config/minion          # repository-local Salt configuration
│   └── salt/                  # software states and top.sls selection
├── scripts/
│   ├── provision              # preview/apply runner
│   └── provision_context.py   # chezmoi role and user context for Salt
├── LICENSE
└── README.md
```
