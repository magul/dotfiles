{% if grains.get('os') in ['Debian', 'Ubuntu'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

claude-code-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - coreutils
    - refresh: true
    - cache_valid_time: 3600

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
    - runas: {{ context['user'] | yaml_dquote }}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - HOME: {{ home | yaml_dquote }}
    - require:
      - pkg: claude-code-prerequisites
      - file: claude-code-bin-directory
{% endif %}
