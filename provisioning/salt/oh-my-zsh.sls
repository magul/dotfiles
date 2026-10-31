{% if grains.get('os') in ['Debian', 'Ubuntu'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

oh-my-zsh-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - git
      - zsh
    - refresh: true
    - cache_valid_time: 3600

oh-my-zsh-directory:
  file.directory:
    - name: {{ (home ~ '/.oh-my-zsh') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'

# A clone installs the framework without touching .zshrc or the login shell.
# Adopt an existing checkout without pulling or changing its revision.
oh-my-zsh-install:
  git.cloned:
    - name: https://github.com/ohmyzsh/ohmyzsh.git
    - target: {{ (home ~ '/.oh-my-zsh') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - require:
      - pkg: oh-my-zsh-prerequisites
      - file: oh-my-zsh-directory
{% endif %}
