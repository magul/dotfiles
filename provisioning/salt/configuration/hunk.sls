{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation
  - hunk

hunk-config-directory:
  file.directory:
    - name: {{ (configuration.config_home ~ '/hunk') | yaml_dquote }}
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.directory_mode | yaml_dquote }}
    - makedirs: true
    - require:
      - test: configuration-context

hunk-config:
  file.managed:
    - name: {{ (configuration.config_home ~ '/hunk/config.toml') | yaml_dquote }}
    - source: salt://files/hunk/config.toml
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - require:
      - file: hunk-config-directory
{% if grains['os'] == 'MacOS' %}
      - pkg: hunk-install
{% else %}
      - cmd: hunk-install
{% endif %}
{% endif %}
