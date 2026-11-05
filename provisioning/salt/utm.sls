{% set context = pillar.get('dotfiles', {}) %}
{% if grains.get('os') == 'MacOS' and context.get('role') == 'desktop' %}
include:
  - homebrew

utm-install:
  pkg.installed:
    - name: utm
    - options:
      - --cask
    - require:
      - cmd: homebrew-install
{% endif %}
