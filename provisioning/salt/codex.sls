{% if grains.get('os') in ['Debian', 'Ubuntu'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

include:
  - nodejs

codex-install:
  cmd.run:
    - name: |
        set -e
        source "$NVM_DIR/nvm.sh" --no-use
        nvm use default
        npm install --global @openai/codex
    # Check the selected Node's package and binary, not another codex on PATH.
    - unless: >-
        source "$NVM_DIR/nvm.sh" --no-use &&
        nvm use default >/dev/null 2>&1 &&
        npm list --global --depth=0 @openai/codex >/dev/null 2>&1 &&
        "$(npm prefix --global)/bin/codex" --version >/dev/null 2>&1
    - runas: {{ context['user'] | yaml_dquote }}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - HOME: {{ home | yaml_dquote }}
      - NVM_DIR: {{ (home ~ '/.nvm') | yaml_dquote }}
    - require:
      - cmd: nodejs-default
{% endif %}
