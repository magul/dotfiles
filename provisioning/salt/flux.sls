{% if grains.get('os') in ['Debian', 'Ubuntu'] %}

flux-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - coreutils
      - debianutils
      - gzip
      - tar
    - refresh: true
    - cache_valid_time: 3600

flux-install:
  cmd.script:
    - name: https://fluxcd.io/install.sh
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - unless: command -v flux >/dev/null 2>&1
    - require:
      - pkg: flux-prerequisites
{% endif %}
