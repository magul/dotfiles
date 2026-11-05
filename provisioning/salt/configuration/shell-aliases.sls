{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation

shell-config-directory:
  file.directory:
    - name: {{ (configuration.config_home ~ '/shell') | yaml_dquote }}
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.directory_mode | yaml_dquote }}
    - makedirs: true
    - require:
      - test: configuration-context

shell-aliases-config:
  file.managed:
    - name: {{ (configuration.config_home ~ '/shell/aliases.sh') | yaml_dquote }}
    - source: salt://files/shell/aliases.sh
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - require:
      - file: shell-config-directory
{% endif %}
