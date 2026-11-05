base:
  '*':
    - foundation
  'G@os:Debian or G@os:Ubuntu':
    - match: compound
    - jq
    - neovim
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
    - chrome
    - handy
    - obsidian
    - vm-curator
{% endif %}
  'os:MacOS':
    - match: grain
    - homebrew
    - nodejs
    - jq
    - neovim
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
    - chrome
    - handy
    - obsidian
    - virtualization
    - utm
{% endif %}
