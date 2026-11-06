{% set context = pillar.get('dotfiles', {}) %}
{% if grains.get('os') == 'MacOS' and context.get('role') == 'desktop' %}
include:
  - homebrew

chrome-package:
  pkg.installed:
    - name: google-chrome
    - options:
      - --cask
    - require:
      - cmd: homebrew-install
{% elif grains.get('os') in ['Debian', 'Ubuntu'] and context.get('role') == 'desktop' %}
{% set arch = grains.get('osarch') %}
{% if arch in ['amd64', 'arm64'] %}

chrome-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
    - refresh: true
    - cache_valid_time: 3600

# Install the vendor package once. Its maintainer scripts and the daily
# /etc/cron.daily/google-chrome job then own the apt source and keyring, and
# apt upgrades Chrome from there.
chrome-package:
  cmd.run:
    - name: |
        set -euo pipefail
        download_dir=$(mktemp -d)
        trap 'rm -rf -- "$download_dir"' EXIT
        curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_{{ arch }}.deb \
            -o "$download_dir/google-chrome.deb"
        chmod 0755 "$download_dir"
        chmod 0644 "$download_dir/google-chrome.deb"
        apt-get update
        apt-get install --yes "$download_dir/google-chrome.deb"
    - unless: >-
        dpkg-query -W -f='${Status}' google-chrome-stable 2>/dev/null |
        grep -Fxq 'install ok installed'
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - DEBIAN_FRONTEND: noninteractive
    - require:
      - pkg: chrome-prerequisites
{% else %}

chrome-unsupported-architecture:
  test.fail_without_changes:
    - name: Google Chrome requires Debian architecture amd64 or arm64.
{% endif %}
{% endif %}
