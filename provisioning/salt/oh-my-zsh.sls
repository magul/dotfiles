{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

{% if grains['os'] == 'MacOS' %}
include:
  - homebrew

oh-my-zsh-prerequisites:
  pkg.installed:
    - name: git
    - options:
      - --formula
    - require:
      - cmd: homebrew-install
{% else %}
oh-my-zsh-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - git
      - zsh
    - refresh: true
    - cache_valid_time: 3600
{% endif %}

# A clone installs the framework without touching .zshrc or the login shell
# (login-shell manages the latter on Debian/Ubuntu).
# Adopt an existing checkout without pulling or changing its revision.
# git.cloned rejects an existing non-repository target, so clone before
# managing the directory's permissions.
oh-my-zsh-install:
  git.cloned:
    - name: https://github.com/ohmyzsh/ohmyzsh.git
    - target: {{ (home ~ '/.oh-my-zsh') | yaml_dquote }}
{% if grains['os'] != 'MacOS' %}
    - user: {{ context['user'] | yaml_dquote }}
{% endif %}
    - require:
      - pkg: oh-my-zsh-prerequisites

oh-my-zsh-directory:
  file.directory:
    - name: {{ (home ~ '/.oh-my-zsh') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'
    - require:
      - git: oh-my-zsh-install
{% endif %}
