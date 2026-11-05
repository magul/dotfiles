{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

{% if grains['os'] == 'MacOS' %}
include:
  - homebrew

nodejs-prerequisites:
  pkg.installed:
    - pkgs:
      - curl
      - git
      - xz
    - options:
      - --formula
    - require:
      - cmd: homebrew-install
{% else %}
nodejs-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - git
      - xz-utils
    - refresh: true
    - cache_valid_time: 3600
{% endif %}

nvm-directory:
  file.directory:
    - name: {{ (home ~ '/.nvm') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'

nvm-install:
  cmd.script:
    - name: https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh
    - unless: test -s "$NVM_DIR/nvm.sh"
{% if grains['os'] != 'MacOS' %}
    - runas: {{ context['user'] | yaml_dquote }}
{% endif %}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: {{ '/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin' if grains['os'] == 'MacOS' else '/usr/local/bin:/usr/bin:/bin' }}
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
{% if grains['os'] != 'MacOS' %}
    - runas: {{ context['user'] | yaml_dquote }}
{% endif %}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: {{ '/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin' if grains['os'] == 'MacOS' else '/usr/local/bin:/usr/bin:/bin' }}
    - env:
      - HOME: {{ home | yaml_dquote }}
      - NVM_DIR: {{ (home ~ '/.nvm') | yaml_dquote }}
    - require:
      - cmd: nvm-install
{% endif %}
