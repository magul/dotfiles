{% set context = pillar.get('dotfiles', {}) %}
{% if grains.get('os') in ['Debian', 'Ubuntu'] and context.get('role') == 'desktop' %}
{% set arch = grains.get('osarch') %}
{% if arch in ['amd64', 'arm64'] %}

chrome-repository-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - gnupg

chrome-repository:
  pkgrepo.managed:
    # Keep the previous chezmoi installer's repository and key paths.
    - name: deb [arch={{ arch }} signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main
    - file: /etc/apt/sources.list.d/google-chrome.list
    - key_url: https://dl.google.com/linux/linux_signing_key.pub
    - aptkey: false
    - require:
      - pkg: chrome-repository-prerequisites

chrome-package:
  pkg.installed:
    - name: google-chrome-stable
    - refresh: true
    - require:
      - pkgrepo: chrome-repository
{% else %}

chrome-unsupported-architecture:
  test.fail_without_changes:
    - name: Google Chrome requires Debian architecture amd64 or arm64.
{% endif %}
{% endif %}
