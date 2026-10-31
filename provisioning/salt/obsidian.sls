{% set context = pillar.get('dotfiles', {}) %}
{% if grains.get('os') in ['Debian', 'Ubuntu'] and context.get('role') == 'desktop' %}
{% set home = context['home'] %}
{% set arch = grains.get('osarch') %}
{% set major = grains.get('osmajorrelease', 0) | int %}
{% set fuse = 'libfuse2t64' if (grains['os'] == 'Ubuntu' and major >= 24) or (grains['os'] == 'Debian' and major >= 13) else 'libfuse2' %}
{% set appimage = home ~ '/Applications/Obsidian.AppImage' %}
{% if arch in ['amd64', 'arm64'] %}

obsidian-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - python3
      - {{ fuse }}
    - refresh: true
    - cache_valid_time: 3600

obsidian-applications-directory:
  file.directory:
    - name: {{ (home ~ '/Applications') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'

obsidian-download:
  cmd.run:
    - name: |
        set -euo pipefail
        download_dir=$(mktemp -d "$HOME/Applications/.obsidian.XXXXXX")
        trap 'rm -rf -- "$download_dir"' EXIT
        curl -fsSL https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
            -o "$download_dir/release.json"
        appimage_url=$(python3 -c '
        import json, sys
        with open(sys.argv[1]) as release_file:
            release = json.load(release_file)
        urls = [asset["browser_download_url"] for asset in release["assets"]
                if asset["name"].endswith(".AppImage")
                and (("arm64" in asset["name"].lower() or "aarch64" in asset["name"].lower())
                     == (sys.argv[2] == "arm64"))]
        if len(urls) != 1:
            sys.exit("Expected one Obsidian AppImage for " + sys.argv[2])
        print(urls[0])
        ' "$download_dir/release.json" "$OBSIDIAN_ARCH")
        curl -fsSL "$appimage_url" -o "$download_dir/Obsidian.AppImage"
        chmod 0700 "$download_dir/Obsidian.AppImage"
        mv -- "$download_dir/Obsidian.AppImage" "$APPIMAGE_PATH"
    - unless: test -s "$APPIMAGE_PATH"
    - runas: {{ context['user'] | yaml_dquote }}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - HOME: {{ home | yaml_dquote }}
      - APPIMAGE_PATH: {{ appimage | yaml_dquote }}
      - OBSIDIAN_ARCH: {{ arch | yaml_dquote }}
    - require:
      - pkg: obsidian-prerequisites
      - file: obsidian-applications-directory

obsidian-appimage-permissions:
  file.managed:
    - name: {{ appimage | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'
    - replace: false
    - create: false
    - require:
      - cmd: obsidian-download

obsidian-launcher-directory:
  file.directory:
    - name: {{ (home ~ '/.local/share/applications') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0700'
    - makedirs: true

obsidian-launcher:
  file.managed:
    - name: {{ (home ~ '/.local/share/applications/obsidian.desktop') | yaml_dquote }}
    - user: {{ context['user'] | yaml_dquote }}
    - mode: '0600'
    - contents: |
        [Desktop Entry]
        Name=Obsidian
        Exec="{{ appimage | replace('\\', '\\\\') | replace('"', '\\"') | replace('`', '\\`') | replace('$', '\\$') | replace('%', '%%') }}" --no-sandbox %u
        Type=Application
        Icon=obsidian
        Categories=Office;
        MimeType=x-scheme-handler/obsidian;
    - require:
      - file: obsidian-appimage-permissions
      - file: obsidian-launcher-directory
{% else %}

obsidian-unsupported-architecture:
  test.fail_without_changes:
    - name: Obsidian requires Debian architecture amd64 or arm64.
{% endif %}
{% endif %}
