{% set context = pillar.get('dotfiles', {}) %}
{% if grains.get('os') in ['Debian', 'Ubuntu'] and context.get('role') == 'desktop' %}
{% set user = context['user'] %}
{% set home = context['home'] %}

vscode-repository-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - gnupg

vscode-repository:
  pkgrepo.managed:
    # Reuse the previous chezmoi installer's repository and key paths.
    - name: deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main
    - file: /etc/apt/sources.list.d/vscode.list
    - key_url: https://packages.microsoft.com/keys/microsoft.asc
    - aptkey: false
    - require:
      - pkg: vscode-repository-prerequisites

vscode-package:
  pkg.installed:
    - name: code
    - refresh: true
    - require:
      - pkgrepo: vscode-repository

{% for extension in context['vscode_extensions'] %}
vscode-extension-{{ extension }}:
  cmd.run:
    - name: /usr/bin/code --install-extension {{ extension }}
    - unless: /usr/bin/code --list-extensions | /usr/bin/grep -Fxi -- {{ extension }}
    - runas: {{ user | yaml_dquote }}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - env:
      - HOME: {{ home | yaml_dquote }}
      - XDG_CONFIG_HOME: {{ (home ~ '/.config') | yaml_dquote }}
      - XDG_DATA_HOME: {{ (home ~ '/.local/share') | yaml_dquote }}
    - require:
      - pkg: vscode-package
{% endfor %}
{% endif %}
