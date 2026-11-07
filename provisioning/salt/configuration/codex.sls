{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% from "configuration/map.jinja" import configuration with context %}

include:
  - foundation
  - codex
  - herdr

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
        # herdr's integration enables hooks in config.toml; repeat it here in
        # case the profile is read without the base config.
        features:
          hooks: true
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

# Installs the hook script that reports Codex sessions to herdr, registers it
# in hooks.json, and enables hooks in config.toml. Salt manages none of those files.
herdr-codex-integration:
  cmd.run:
    - name: herdr integration install codex
    - unless: "herdr integration status | grep -q '^codex: current '"
{% if grains['os'] != 'MacOS' %}
    - runas: {{ configuration.user | yaml_dquote }}
{% endif %}
    - cwd: {{ configuration.home | yaml_dquote }}
    - prepend_path: {{ (configuration.home ~ '/.local/bin:' ~ ('/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin' if grains['os'] == 'MacOS' else '/usr/local/bin:/usr/bin:/bin')) | yaml_dquote }}
    - env:
      - HOME: {{ configuration.home | yaml_dquote }}
    - require:
      - file: codex-config-directory
{% if grains['os'] == 'MacOS' %}
      - pkg: herdr-install
{% else %}
      - cmd: herdr-install
{% endif %}
{% endif %}
