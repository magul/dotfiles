{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation
  - opencode

opencode-config-directory:
  file.directory:
    - name: {{ (configuration.config_home ~ '/opencode') | yaml_dquote }}
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.directory_mode | yaml_dquote }}
    - makedirs: true
    - require:
      - test: configuration-context

opencode-config:
  file.managed:
    - name: {{ (configuration.config_home ~ '/opencode/opencode.json') | yaml_dquote }}
    - source: salt://files/opencode/opencode.json
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - require:
      - file: opencode-config-directory
      - cmd: opencode-install
{% endif %}
