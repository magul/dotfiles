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

On first run chezmoi will prompt for your name and email.

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

## Daily usage

```bash
chezmoi add ~/.gitconfig          # start managing a file
chezmoi add --template ~/.zshrc   # manage as template (for OS-specific content)
chezmoi edit ~/.gitconfig          # edit the source copy
chezmoi diff                       # preview pending changes
chezmoi apply                      # apply changes to home directory
chezmoi update                     # pull remote changes and apply
```

## How it works

This repo **is** the chezmoi source directory. Files here map to your home directory:

| Source naming | Target | Notes |
|---------------|--------|-------|
| `dot_gitconfig` | `~/.gitconfig` | `dot_` prefix becomes `.` |
| `dot_zshrc.tmpl` | `~/.zshrc` | `.tmpl` suffix = template |
| `private_dot_ssh/config` | `~/.ssh/config` | `private_` = 0600 permissions |
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
│   ├── nvim/
│   │   └── init.lua            # Neovim configuration
│   ├── opencode/
│   │   └── opencode.json       # OpenCode configuration
│   └── shell/
│       └── aliases.sh          # shared shell aliases
├── dot_zprofile.tmpl           # ~/.zprofile (OS-specific)
├── dot_zshrc.tmpl              # ~/.zshrc (OS-specific)
├── run_onchange_install-neovim.sh.tmpl       # auto-installs Neovim
├── run_onchange_install-oh-my-zsh.sh         # auto-installs Oh My Zsh
├── run_onchange_install-vscode-extensions.sh.tmpl  # auto-installs VS Code extensions
├── LICENSE
└── README.md
```
