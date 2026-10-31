{% if grains.get('os') in ['Debian', 'Ubuntu'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

nodejs-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - git
      - xz-utils
    - refresh: true
    - cache_valid_time: 3600

nvm-directory:
  file.directory:
    - name: {{ (home ~ '/.nvm') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'

nvm-install:
  cmd.script:
    - name: https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh
    - unless: test -s "$NVM_DIR/nvm.sh"
    - runas: {{ context['user'] | yaml_dquote }}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - HOME: {{ home | yaml_dquote }}
      - NVM_DIR: {{ (home ~ '/.nvm') | yaml_dquote }}
      - PROFILE: /dev/null
    - require:
      - pkg: nodejs-prerequisites
      - file: nvm-directory

nodejs-default:
  cmd.run:
    - name: |
        set -e
        source "$NVM_DIR/nvm.sh" --no-use
        nvm install --lts
        nvm alias default "$(nvm current)"
        test -x "$NVM_BIN/node" && test -x "$NVM_BIN/npm"
    - unless: >-
        source "$NVM_DIR/nvm.sh" --no-use &&
        nvm use default >/dev/null 2>&1 &&
        test -x "$NVM_BIN/node" && test -x "$NVM_BIN/npm"
    - runas: {{ context['user'] | yaml_dquote }}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - HOME: {{ home | yaml_dquote }}
      - NVM_DIR: {{ (home ~ '/.nvm') | yaml_dquote }}
    - require:
      - cmd: nvm-install
{% endif %}
