{% set context = pillar.get('dotfiles', {}) %}
{% if grains.get('os') in ['Debian', 'Ubuntu', 'MacOS'] and context.get('role') == 'desktop' %}
{% set user = context['user'] %}
{% set home = context['home'] %}
{% set package_state = 'pkg' if grains['os'] == 'MacOS' else 'cmd' %}
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
vscode-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
    - refresh: true
    - cache_valid_time: 3600

# Install the vendor package once. Its maintainer scripts then own the
# Microsoft apt source and keyring, and apt upgrades VS Code from there.
# Preseed the repository question so the source is added non-interactively.
vscode-package:
  cmd.run:
    - name: |
        set -euo pipefail
        case "$(dpkg --print-architecture)" in
            amd64) build=linux-deb-x64 ;;
            arm64) build=linux-deb-arm64 ;;
            armhf) build=linux-deb-armhf ;;
            *) echo "Unsupported VS Code architecture" >&2; exit 1 ;;
        esac
        echo 'code code/add-microsoft-repo boolean true' | debconf-set-selections
        download_dir=$(mktemp -d)
        trap 'rm -rf -- "$download_dir"' EXIT
        curl -fsSL "https://code.visualstudio.com/sha/download?build=stable&os=$build" \
            -o "$download_dir/code.deb"
        chmod 0755 "$download_dir"
        chmod 0644 "$download_dir/code.deb"
        apt-get update
        apt-get install --yes "$download_dir/code.deb"
    - unless: >-
        dpkg-query -W -f='${Status}' code 2>/dev/null |
        grep -Fxq 'install ok installed'
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - DEBIAN_FRONTEND: noninteractive
    - require:
      - pkg: vscode-prerequisites
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
      - {{ package_state }}: vscode-package
{% endfor %}
{% endif %}
