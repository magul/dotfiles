{% if grains.get('os') in ['Debian', 'Ubuntu'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

herdr-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - coreutils
      - mawk
    - refresh: true
    - cache_valid_time: 3600

herdr-bin-directory:
  file.directory:
    - name: {{ (home ~ '/.local/bin') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'
    - makedirs: true

herdr-install:
  cmd.script:
    - name: https://herdr.dev/install.sh
    - unless: '"$HERDR_INSTALL_DIR/herdr" --version >/dev/null 2>&1'
    - runas: {{ context['user'] | yaml_dquote }}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/sh
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - HOME: {{ home | yaml_dquote }}
      - HERDR_INSTALL_DIR: {{ (home ~ '/.local/bin') | yaml_dquote }}
    - require:
      - pkg: herdr-prerequisites
      - file: herdr-bin-directory
{% endif %}
