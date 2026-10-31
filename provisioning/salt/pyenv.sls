{% if grains.get('os') in ['Debian', 'Ubuntu'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

pyenv-build-dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - ca-certificates
      - git
      - libssl-dev
      - zlib1g-dev
      - libbz2-dev
      - libreadline-dev
      - libsqlite3-dev
      - curl
      - libncurses-dev
      - xz-utils
      - tk-dev
      - libxml2-dev
      - libxmlsec1-dev
      - libffi-dev
      - liblzma-dev
    - refresh: true
    - cache_valid_time: 3600

pyenv-directory:
  file.directory:
    - name: {{ (home ~ '/.pyenv') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'

# Ensure repositories exist without automatically pulling or changing revisions.
pyenv-install:
  git.cloned:
    - name: https://github.com/pyenv/pyenv.git
    - target: {{ (home ~ '/.pyenv') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - require:
      - pkg: pyenv-build-dependencies
      - file: pyenv-directory

pyenv-virtualenv:
  git.cloned:
    - name: https://github.com/pyenv/pyenv-virtualenv.git
    - target: {{ (home ~ '/.pyenv/plugins/pyenv-virtualenv') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - require:
      - git: pyenv-install
{% endif %}
