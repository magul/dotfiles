{% if grains.get('os') in ['Debian', 'Ubuntu'] and pillar.get('dotfiles', {}).get('role') == 'desktop' %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation
  - vm-curator

vm-curator-config-directory:
  file.directory:
    - name: {{ (configuration.config_home ~ '/vm-curator') | yaml_dquote }}
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.directory_mode | yaml_dquote }}
    - makedirs: true
    - require:
      - test: configuration-context

vm-curator-config:
  file.managed:
    - name: {{ (configuration.config_home ~ '/vm-curator/config.toml') | yaml_dquote }}
    - source: salt://files/vm-curator/config.toml.jinja
    - template: jinja
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - require:
      - file: vm-curator-config-directory
      - cmd: vm-curator-install
{% endif %}
