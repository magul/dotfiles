{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation
  - claude-code
  - jq

claude-config-directory:
  file.directory:
    - name: {{ (configuration.home ~ '/.claude') | yaml_dquote }}
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.directory_mode | yaml_dquote }}
    - require:
      - test: configuration-context

claude-statusline:
  file.managed:
    - name: {{ (configuration.home ~ '/.claude/statusline.sh') | yaml_dquote }}
    - source: salt://files/claude-code/statusline.sh
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.executable_mode | yaml_dquote }}
    - require:
      - file: claude-config-directory
      - pkg: jq

claude-settings:
  file.managed:
    - name: {{ (configuration.home ~ '/.claude/settings.json') | yaml_dquote }}
    - source: salt://files/claude-code/settings.json
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - show_changes: false
    - require:
      - file: claude-config-directory
      - file: claude-statusline
      - cmd: claude-code-install
{% endif %}
