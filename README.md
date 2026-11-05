# dotfiles

Dotfiles managed by [chezmoi](https://www.chezmoi.io/), with software provisioning
through masterless Salt on Debian/Ubuntu and macOS.

## Bootstrap (new machine)

Install chezmoi and initialize the repository:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init magul
```

On first run, chezmoi prompts for your name, email, and machine role (`desktop`
or `server`). Follow the [Salt bootstrap instructions](docs/salt.md) to install
Salt and provision software. On macOS, Salt also bootstraps Homebrew.

Then preview and apply your configuration:

```bash
chezmoi diff
chezmoi apply
```

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

Salt manages software installation, dependencies, and migrated configuration.
Chezmoi manages the remaining configuration during the gradual handoff.
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

```bash
chezmoi add ~/.gitconfig          # start managing a file
chezmoi add --template ~/.zshrc   # manage as template (for OS-specific content)
chezmoi edit ~/.gitconfig          # edit the source copy
chezmoi diff                       # preview pending changes
chezmoi apply                      # apply changes to home directory
chezmoi update                     # pull remote changes and apply
```

After pulling provisioning changes, run Salt preview and apply as described in
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

Then preview and apply both chezmoi and Salt changes. Machines without a role
retain desktop behavior. Switching to server skips desktop configuration and
software states; it does not remove existing files or uninstall applications.
Switching back to desktop manages those resources again on the next apply.

## How it works

This repo **is** the chezmoi source directory. Managed configuration maps to your
home directory:

| Source naming | Target | Notes |
|---------------|--------|-------|
| `dot_config/shell/aliases.sh` | `~/.config/shell/aliases.sh` | `dot_` prefix becomes `.` |
| `dot_zshrc.tmpl` | `~/.zshrc` | `.tmpl` suffix = template |

`docs/`, `scripts/`, and `provisioning/` are excluded from chezmoi's home-directory
targets. The provisioning runner reads its states directly from this repository.

Templates use `{{ .chezmoi.os }}` (`linux` or `darwin`) to vary content per OS.

## Adding OS-specific config

Use chezmoi's template syntax inside `.tmpl` files:

```
{{ if eq .chezmoi.os "darwin" -}}
# macOS-specific config here
{{ else if eq .chezmoi.os "linux" -}}
# Linux-specific config here
{{ end -}}
```

For Salt-managed configuration, select operating systems and machine roles in
the state and `top.sls`; see the [configuration migration guide](docs/configuration.md).

## Repo structure

```
.
├── .chezmoi.toml.tmpl          # prompts for identity and machine role on init
├── .chezmoiignore              # files to exclude from home directory
├── .gitignore
├── docs/
│   └── salt.md                # Salt bootstrap, apply, and update workflow
├── dot_config/
│   └── shell/
│       └── aliases.sh          # shared shell aliases
├── provisioning/
│   ├── config/minion          # repository-local Salt configuration
│   └── salt/                  # software states and top.sls selection
├── scripts/
│   ├── provision              # preview/apply runner
│   └── provision_context.py   # chezmoi role and user context for Salt
├── dot_zprofile.tmpl           # ~/.zprofile (OS-specific)
├── dot_zshrc.tmpl              # ~/.zshrc (OS-specific)
├── LICENSE
└── README.md
```
