{% if grains.get('os') in ['Debian', 'Ubuntu'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

hunk-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - coreutils
      - gzip
      - tar
    - refresh: true
    - cache_valid_time: 3600

hunk-directory:
  file.directory:
    - name: {{ (home ~ '/.hunk') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'

hunk-install:
  cmd.script:
    - name: https://hunk.dev/install.sh
    - unless: '"$HOME/.hunk/bin/hunk" --version >/dev/null 2>&1'
    - runas: {{ context['user'] | yaml_dquote }}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/sh
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - HOME: {{ home | yaml_dquote }}
      - HUNK_NO_MODIFY_PATH: '1'
      # An empty override selects ~/.hunk/bin and its sibling skills directory.
      - HUNK_INSTALL_DIR: ''
    - require:
      - pkg: hunk-prerequisites
      - file: hunk-directory
{% endif %}
