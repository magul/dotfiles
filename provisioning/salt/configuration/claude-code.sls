{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation
  - claude-code
  - herdr
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

# Installs the hook script that reports Claude sessions to herdr. The installer
# also adds the hook to settings.json, which claude-settings below then replaces,
# so the template carries the same hook entry.
herdr-claude-integration:
  cmd.run:
    - name: herdr integration install claude
    - unless: "herdr integration status | grep -q '^claude: current '"
{% if grains['os'] != 'MacOS' %}
    - runas: {{ configuration.user | yaml_dquote }}
{% endif %}
    - cwd: {{ configuration.home | yaml_dquote }}
    - prepend_path: {{ (configuration.home ~ '/.local/bin:' ~ ('/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin' if grains['os'] == 'MacOS' else '/usr/local/bin:/usr/bin:/bin')) | yaml_dquote }}
    - env:
      - HOME: {{ configuration.home | yaml_dquote }}
    - require:
      - file: claude-config-directory
{% if grains['os'] == 'MacOS' %}
      - pkg: herdr-install
{% else %}
      - cmd: herdr-install
{% endif %}

claude-settings:
  file.managed:
    - name: {{ (configuration.home ~ '/.claude/settings.json') | yaml_dquote }}
    - source: salt://files/claude-code/settings.json
    - template: jinja
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - show_changes: false
    - require:
      - file: claude-config-directory
      - file: claude-statusline
      - cmd: claude-code-install
      - cmd: herdr-claude-integration
{% endif %}
