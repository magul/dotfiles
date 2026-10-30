base:
  '*':
    - foundation
  'G@os:Debian or G@os:Ubuntu':
    - match: compound
    - jq
    - neovim
{% if pillar.get('dotfiles', {}).get('role') == 'desktop' %}
    - vscode
{% endif %}
