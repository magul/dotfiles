{% if grains.get('os') in ['Debian', 'Ubuntu'] %}
{% set context = pillar['dotfiles'] %}

# macOS already defaults to zsh, and its runner has no root access to change it.
include:
  - oh-my-zsh
  - configuration.zshrc

# Switch only after zsh and .zshrc exist, so the first login skips zsh's
# new-user wizard. Only the shell attribute of the existing account is managed.
login-shell:
  user.present:
    - name: {{ context['user'] | yaml_dquote }}
    - shell: /usr/bin/zsh
    - require:
      - pkg: oh-my-zsh-prerequisites
      - file: zshrc-config
{% endif %}
