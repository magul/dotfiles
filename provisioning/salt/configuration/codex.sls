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

# Codex stores its own state (trusted projects, notices) in the active profile,
# so merge only the keys below and keep whatever Codex has added.
# Requires the toml library in Salt's Python; see docs/salt.md.
codex-profile:
  file.serialize:
    - name: {{ (configuration.home ~ '/.codex/dotfiles.config.toml') | yaml_dquote }}
    - serializer: toml
    - merge_if_exists: true
    - dataset:
        tui:
          status_line:
            - model-with-reasoning
            - context-remaining
            - five-hour-limit
            - weekly-limit
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
