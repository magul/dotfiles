{% if grains.get('os') in ['Debian', 'Ubuntu'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

opencode-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - coreutils
      - debianutils
      - gzip
      - tar
    - refresh: true
    - cache_valid_time: 3600

opencode-directory:
  file.directory:
    - name: {{ (home ~ '/.opencode') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'

opencode-install:
  cmd.script:
    - name: https://opencode.ai/install
    - args: --no-modify-path
    - unless: '"$HOME/.opencode/bin/opencode" --version >/dev/null 2>&1'
    - runas: {{ context['user'] | yaml_dquote }}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - HOME: {{ home | yaml_dquote }}
    - require:
      - pkg: opencode-prerequisites
      - file: opencode-directory
{% endif %}
