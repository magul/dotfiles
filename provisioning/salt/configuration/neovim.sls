{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation
  - neovim

neovim-config-directory:
  file.directory:
    - name: {{ (configuration.config_home ~ '/nvim') | yaml_dquote }}
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.directory_mode | yaml_dquote }}
    - makedirs: true
    - require:
      - test: configuration-context

neovim-config:
  file.managed:
    - name: {{ (configuration.config_home ~ '/nvim/init.lua') | yaml_dquote }}
    - source: salt://files/neovim/init.lua
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - require:
      - file: neovim-config-directory
      - pkg: neovim
{% endif %}
