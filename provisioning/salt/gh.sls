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
# Track upstream rather than downloading once: GitHub rotates this signing key
# (the 2022 key expired 2026-09-05), and a stale copy breaks apt-get update.
gh-keyring:
  file.managed:
    - name: /etc/apt/keyrings/githubcli-archive-keyring.gpg
    - source: https://cli.github.com/packages/githubcli-archive-keyring.gpg
    - skip_verify: true
    - makedirs: true
    - dir_mode: '0755'
    - user: root
    - group: root
    - mode: '0644'
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
      - file: gh-keyring

gh-apt-update:
  cmd.run:
    - name: apt-get update
    - onchanges:
      - file: gh-keyring
      - file: gh-repository

gh-install:
  pkg.installed:
    - name: gh
    - refresh: false
    - require:
      - file: gh-repository
      - cmd: gh-apt-update
{% endif %}
