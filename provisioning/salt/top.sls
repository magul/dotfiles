base:
  '*':
    - foundation
  'G@os:Debian or G@os:Ubuntu':
    - match: compound
    - jq
    - neovim
    - helm
    - codex
    - pyenv
    - oh-my-zsh
{% if pillar.get('dotfiles', {}).get('role') == 'desktop' %}
    - vscode
    - chrome
    - handy
    - obsidian
    - vm-curator
{% endif %}
