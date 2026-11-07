base:
  '*':
    - foundation
  'G@os:Debian or G@os:Ubuntu':
    - match: compound
    - configuration.shell-aliases
    - configuration.zprofile
    - configuration.zshrc
    - jq
    - gh
    - mosh
    - neovim
    - configuration.neovim
    - helm
    - flux
    - k9s
    - hunk
    - configuration.hunk
    - herdr
    - codex
    - configuration.codex
    - claude-code
    - configuration.claude-code
    - opencode
    - configuration.opencode
    - pyenv
    - oh-my-zsh
    - login-shell
{% if pillar.get('dotfiles', {}).get('role') == 'desktop' %}
    - vscode
    - configuration.vscode
    - chrome
    - handy
    - obsidian
    - calibre
    - vm-curator
    - configuration.vm-curator
{% endif %}
  'os:MacOS':
    - match: grain
    - configuration.shell-aliases
    - configuration.zprofile
    - configuration.zshrc
    - homebrew
    - nodejs
    - jq
    - gh
    - mosh
    - neovim
    - configuration.neovim
    - helm
    - flux
    - k9s
    - hunk
    - configuration.hunk
    - herdr
    - codex
    - configuration.codex
    - claude-code
    - configuration.claude-code
    - opencode
    - configuration.opencode
    - pyenv
    - oh-my-zsh
{% if pillar.get('dotfiles', {}).get('role') == 'desktop' %}
    - vscode
    - configuration.vscode
    - chrome
    - handy
    - obsidian
    - calibre
    - virtualization
    - utm
{% endif %}
