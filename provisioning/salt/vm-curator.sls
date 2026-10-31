{% set context = pillar.get('dotfiles', {}) %}
{% if grains.get('os') in ['Debian', 'Ubuntu'] and context.get('role') == 'desktop' %}

include:
  - virtualization

vm-curator-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - python3
    - refresh: true
    - cache_valid_time: 3600

vm-curator-install:
  cmd.run:
    - name: |
        set -euo pipefail
        arch=$(dpkg --print-architecture)
        download_dir=$(mktemp -d)
        trap 'rm -rf -- "$download_dir"' EXIT
        curl -fsSL https://api.github.com/repos/mroboff/vm-curator/releases/latest \
            -o "$download_dir/release.json"
        deb_url=$(python3 -c '
        import json, sys
        with open(sys.argv[1]) as release_file:
            release = json.load(release_file)
        urls = [asset["browser_download_url"] for asset in release["assets"]
                if asset["name"].endswith("_" + sys.argv[2] + ".deb")]
        if len(urls) != 1:
            sys.exit("Expected one vm-curator Debian package for " + sys.argv[2])
        print(urls[0])
        ' "$download_dir/release.json" "$arch")
        curl -fsSL "$deb_url" -o "$download_dir/vm-curator.deb"
        chmod 0755 "$download_dir"
        chmod 0644 "$download_dir/vm-curator.deb"
        apt-get install --yes "$download_dir/vm-curator.deb"
    - unless: >-
        dpkg-query -W -f='${Status}' vm-curator 2>/dev/null |
        grep -Fxq 'install ok installed'
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - require:
      - pkg: vm-curator-prerequisites
      - pkg: virtualization-packages
      - user: virtualization-user-groups
      - service: virtualization-service
{% endif %}
