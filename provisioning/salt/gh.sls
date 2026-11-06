{% if grains.get('os') == 'MacOS' %}
include:
  - homebrew

gh-install:
  pkg.installed:
    - name: gh
    - options:
      - --formula
    - require:
      - cmd: homebrew-install
{% elif grains.get('os') in ['Debian', 'Ubuntu'] %}

gh-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
    - refresh: true
    - cache_valid_time: 3600

# Use GitHub's official apt repository so apt keeps gh current; distribution
# packages lag far behind upstream releases.
gh-keyring:
  cmd.run:
    - name: |
        set -euo pipefail
        install -d -m 0755 /etc/apt/keyrings
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
        chmod 0644 /etc/apt/keyrings/githubcli-archive-keyring.gpg
    - creates: /etc/apt/keyrings/githubcli-archive-keyring.gpg
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - require:
      - pkg: gh-prerequisites

gh-repository:
  file.managed:
    - name: /etc/apt/sources.list.d/github-cli.list
    - contents: >-
        deb [arch={{ grains['osarch'] }} signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg]
        https://cli.github.com/packages stable main
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - cmd: gh-keyring

gh-apt-update:
  cmd.run:
    - name: apt-get update
    - onchanges:
      - file: gh-repository

gh-install:
  pkg.installed:
    - name: gh
    - refresh: false
    - require:
      - file: gh-repository
      - cmd: gh-apt-update
{% endif %}
