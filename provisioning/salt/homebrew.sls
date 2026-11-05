{% if grains.get('os') == 'MacOS' %}
{% set context = pillar['dotfiles'] %}

homebrew-install:
  cmd.script:
    - name: https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
    - unless: command -v brew >/dev/null 2>&1
    - cwd: {{ context['home'] | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: /opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin
    - env:
      - HOME: {{ context['home'] | yaml_dquote }}
      - NONINTERACTIVE: '1'
    - reload_modules: true
{% endif %}
