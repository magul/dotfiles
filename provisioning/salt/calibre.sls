{% set context = pillar.get('dotfiles', {}) %}
{% if grains.get('os') == 'MacOS' and context.get('role') == 'desktop' %}
include:
  - homebrew

calibre-install:
  pkg.installed:
    - name: calibre
    - options:
      - --cask
    - require:
      - cmd: homebrew-install
{% elif grains.get('os') in ['Debian', 'Ubuntu'] and context.get('role') == 'desktop' %}

calibre-distro-package:
  pkg.removed:
    - pkgs:
      - calibre
      - calibre-bin

calibre-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - python3
      - xdg-utils
      - xz-utils
      - libegl1
      - libopengl0
      - libxcb-cursor0
    - refresh: true
    - cache_valid_time: 3600

calibre-install:
  cmd.run:
    - name: |
        set -euo pipefail
        arch=$(dpkg --print-architecture)
        case "$arch" in
            amd64|arm64) ;;
            *) echo "Unsupported calibre architecture: $arch" >&2; exit 1 ;;
        esac
        download_dir=$(mktemp -d)
        trap 'rm -rf -- "$download_dir"' EXIT
        curl -fsSL https://download.calibre-ebook.com/linux-installer.sh \
            -o "$download_dir/linux-installer.sh"
        sh "$download_dir/linux-installer.sh" install_dir=/opt
    - unless: test -x /opt/calibre/calibre
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - require:
      - pkg: calibre-distro-package
      - pkg: calibre-prerequisites
{% endif %}
