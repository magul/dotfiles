{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

{% if grains['os'] != 'MacOS' %}
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
{% endif %}

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
      - pkg: opencode-prerequisites
{% endif %}
      - file: opencode-directory
{% endif %}
