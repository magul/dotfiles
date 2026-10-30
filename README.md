# dotfiles

Cross-platform dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Bootstrap (new machine)

One-liner — installs chezmoi and applies dotfiles:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply magul
```

On Windows (PowerShell):

```powershell
irm get.chezmoi.io/ps1 | iex; chezmoi init --apply magul
```

On first run chezmoi will prompt for your name, email, and machine role
(`desktop` or `server`). On macOS, Homebrew is
installed automatically (before the other install scripts run) if it isn't
already present.

## Manual setup

Install chezmoi:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
```

Clone and preview before applying:

```bash
chezmoi init magul/dotfiles
chezmoi diff
chezmoi apply
```

## Software provisioning with Salt

An opt-in masterless Salt foundation is available alongside chezmoi. It currently
runs only a no-op state; existing chezmoi scripts still install all software.
See [Salt setup and updates](docs/salt.md) for fresh-system installation and how
to apply newly committed changes. Salt is invoked explicitly:

```bash
cd "$(chezmoi source-path)"
bash scripts/provision preview
bash scripts/provision apply
```

## Daily usage

```bash
chezmoi add ~/.gitconfig          # start managing a file
chezmoi add --template ~/.zshrc   # manage as template (for OS-specific content)
chezmoi edit ~/.gitconfig          # edit the source copy
chezmoi diff                       # preview pending changes
chezmoi apply                      # apply changes to home directory
chezmoi update                     # pull remote changes and apply
```

## Machine role

The OS is detected automatically; `role` selects desktop or server behavior
independently of macOS/Linux. Desktop machines receive all configured tools.
Servers skip Chrome, Obsidian, Handy, VS Code, VS Code extensions and settings,
QEMU, the VM manager (vm-curator on Linux, UTM on macOS), and vm-curator settings.
Shell configuration and other CLI tools (including coding agents) remain enabled
for both roles.

On an existing machine, run `chezmoi edit-config` and add `role` to the existing
`[data]` section (preserve your other entries):

```toml
[data]
    role = "server" # or "desktop"
```

Then run `chezmoi diff` and `chezmoi apply`. Machines without a role retain
desktop behavior until one is selected. Switching to server skips management
of the desktop files and installers; it does not remove existing files or
uninstall applications. Switching back to desktop makes those files managed
again; installers that already ran remain subject to chezmoi's normal
`run_once`/`run_onchange` tracking.

## How it works

This repo **is** the chezmoi source directory. Files here map to your home directory:

| Source naming | Target | Notes |
|---------------|--------|-------|
| `dot_gitconfig` | `~/.gitconfig` | `dot_` prefix becomes `.` |
| `dot_zshrc.tmpl` | `~/.zshrc` | `.tmpl` suffix = template |
| `private_dot_ssh/config` | `~/.ssh/config` | `private_` = 0600 permissions |
| `private_dot_claude/executable_statusline.sh` | `~/.claude/statusline.sh` | `executable_` = +x permission |
| `run_onchange_install.sh.tmpl` | *(executed)* | Script, re-runs when content changes |

Templates can use `{{ .chezmoi.os }}` (`linux`, `darwin`, `windows`) to vary content per OS.

## Adding OS-specific config

Use chezmoi's template syntax inside `.tmpl` files:

```
{{ if eq .chezmoi.os "darwin" -}}
# macOS-specific config here
{{ else if eq .chezmoi.os "linux" -}}
# Linux-specific config here
{{ end -}}
```

To ignore entire files on certain OSes, add rules to `.chezmoiignore`:

```
{{ if ne .chezmoi.os "linux" }}
dot_bashrc
{{ end }}
```

## Repo structure

```
.
├── .chezmoi.toml.tmpl          # chezmoi config — prompts for name/email on init
├── .chezmoiignore              # files to exclude from home directory
├── .gitignore
├── dot_config/
│   ├── Code/User/
│   │   ├── extensions.txt      # VS Code extensions list
│   │   ├── keybindings.json    # VS Code keybindings
│   │   └── settings.json       # VS Code settings
│   ├── hunk/
│   │   └── config.toml         # Hunk diff viewer configuration
│   ├── nvim/
│   │   └── init.lua            # Neovim configuration
│   ├── opencode/
│   │   └── opencode.json       # OpenCode configuration
│   └── shell/
│       └── aliases.sh          # shared shell aliases
├── private_dot_claude/
│   ├── settings.json           # Claude Code settings (model, statusline, voice)
│   └── executable_statusline.sh  # Claude Code statusline script (needs jq)
├── private_dot_codex/
│   └── private_dotfiles.config.toml # Codex profile
├── dot_zprofile.tmpl           # ~/.zprofile (OS-specific)
├── dot_zshrc.tmpl              # ~/.zshrc (OS-specific)
├── run_once_install-hunk.sh.tmpl             # auto-installs Hunk (terminal diff viewer)
├── run_onchange_install-neovim.sh.tmpl       # auto-installs Neovim
├── run_onchange_install-oh-my-zsh.sh         # auto-installs Oh My Zsh
├── run_onchange_install-vscode-extensions.sh.tmpl  # auto-installs VS Code extensions
├── LICENSE
└── README.md
```
