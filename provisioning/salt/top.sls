base:
  '*':
    - foundation
  'G@os:Debian or G@os:Ubuntu':
    - match: compound
    - jq
    - neovim
    - helm
{% if pillar.get('dotfiles', {}).get('role') == 'desktop' %}
    - vscode
{% endif %}
