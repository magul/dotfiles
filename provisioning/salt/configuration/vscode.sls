{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] and pillar.get('dotfiles', {}).get('role') == 'desktop' %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation
  - vscode

vscode-config-directory:
  file.directory:
    - name: {{ configuration.vscode_user_dir | yaml_dquote }}
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.directory_mode | yaml_dquote }}
    - makedirs: true
    - require:
      - test: configuration-context

{% for name in ['settings', 'keybindings'] %}
vscode-{{ name }}:
  file.managed:
    - name: {{ (configuration.vscode_user_dir ~ '/' ~ name ~ '.json') | yaml_dquote }}
    - source: salt://files/vscode/{{ name }}.json
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - require:
      - file: vscode-config-directory
      - {{ 'pkg' if grains['os'] == 'MacOS' else 'cmd' }}: vscode-package
{% endfor %}
{% endif %}
