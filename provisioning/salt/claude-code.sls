{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

{% if grains['os'] != 'MacOS' %}
claude-code-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - coreutils
    - refresh: true
    - cache_valid_time: 3600
{% endif %}

claude-code-bin-directory:
  file.directory:
    - name: {{ (home ~ '/.local/bin') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'
    - makedirs: true

claude-code-install:
  cmd.script:
    - name: https://claude.ai/install.sh
    - unless: '"$HOME/.local/bin/claude" --version >/dev/null 2>&1'
{% if grains['os'] != 'MacOS' %}
    - runas: {{ context['user'] | yaml_dquote }}
{% endif %}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: {{ '/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin' if grains['os'] == 'MacOS' else '/usr/local/bin:/usr/bin:/bin' }}
    - env:
      - HOME: {{ home | yaml_dquote }}
    - require:
{% if grains['os'] != 'MacOS' %}
      - pkg: claude-code-prerequisites
{% endif %}
      - file: claude-code-bin-directory
{% endif %}
