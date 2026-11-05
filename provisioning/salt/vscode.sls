{% set context = pillar.get('dotfiles', {}) %}
{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] and context.get('role') == 'desktop' %}
{% set user = context['user'] %}
{% set home = context['home'] %}
{% set code = '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' if grains['os'] == 'MacOS' else '/usr/bin/code' %}

{% if grains['os'] == 'MacOS' %}
include:
  - homebrew

vscode-package:
  pkg.installed:
    - name: visual-studio-code
    - options:
      - --cask
    - require:
      - cmd: homebrew-install
{% else %}
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
{% endif %}

{% for extension in context['vscode_extensions'] %}
vscode-extension-{{ extension }}:
  cmd.run:
    - name: >-
        {{ code | quote }} --install-extension {{ extension }}
    - unless: >-
        {{ code | quote }} --list-extensions | /usr/bin/grep -Fxi -- {{ extension }}
{% if grains['os'] != 'MacOS' %}
    - runas: {{ user | yaml_dquote }}
{% endif %}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - env:
      - HOME: {{ home | yaml_dquote }}
{% if grains['os'] != 'MacOS' %}
      - XDG_CONFIG_HOME: {{ (home ~ '/.config') | yaml_dquote }}
      - XDG_DATA_HOME: {{ (home ~ '/.local/share') | yaml_dquote }}
{% endif %}
    - require:
      - pkg: vscode-package
{% endfor %}
{% endif %}
