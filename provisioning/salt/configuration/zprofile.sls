{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation

zprofile-config:
  file.managed:
    - name: {{ (configuration.home ~ '/.zprofile') | yaml_dquote }}
    - source: salt://files/shell/zprofile.jinja
    - template: jinja
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - require:
      - test: configuration-context
{% endif %}
