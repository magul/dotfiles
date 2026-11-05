{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation
  - codex

codex-config-directory:
  file.directory:
    - name: {{ (configuration.home ~ '/.codex') | yaml_dquote }}
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.directory_mode | yaml_dquote }}
    - require:
      - test: configuration-context

codex-profile:
  file.managed:
    - name: {{ (configuration.home ~ '/.codex/dotfiles.config.toml') | yaml_dquote }}
    - source: salt://files/codex/dotfiles.config.toml
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - show_changes: false
    - require:
      - file: codex-config-directory
{% if grains['os'] == 'MacOS' %}
      - pkg: codex-install
{% else %}
      - cmd: codex-install
{% endif %}
{% endif %}
