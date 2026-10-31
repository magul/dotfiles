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
    - herdr
    - codex
    - claude-code
    - pyenv
    - oh-my-zsh
{% if pillar.get('dotfiles', {}).get('role') == 'desktop' %}
    - vscode
    - chrome
    - handy
    - obsidian
    - vm-curator
{% endif %}
