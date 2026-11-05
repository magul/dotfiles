{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation
  - configuration.shell-aliases
  - oh-my-zsh
  - pyenv
  - nodejs
  - helm
  - flux

zshrc-config:
  file.managed:
    - name: {{ (configuration.home ~ '/.zshrc') | yaml_dquote }}
    - source: salt://files/shell/zshrc.jinja
    - template: jinja
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - require:
      - test: configuration-context
      - file: shell-aliases-config
      - sls: oh-my-zsh
      - sls: pyenv
      - sls: nodejs
      - sls: helm
      - sls: flux
{% endif %}
