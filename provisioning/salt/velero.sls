{% if grains.get('os') == 'MacOS' %}
include:
  - homebrew

velero-install:
  pkg.installed:
    - name: velero
    - options:
      - --formula
    - require:
      - cmd: homebrew-install
{% elif grains.get('os') in ['Debian', 'Ubuntu'] %}
{# Keep on the same minor version as the clusters' Velero server. #}
{% set velero_version = '1.18.2' %}

velero-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - coreutils
      - gzip
      - tar
    - refresh: true
    - cache_valid_time: 3600

velero-install:
  cmd.run:
    - name: |
        set -euo pipefail
        arch=$(dpkg --print-architecture)
        case "$arch" in
            amd64|arm64) ;;
            *) echo "Unsupported Velero architecture: $arch" >&2; exit 1 ;;
        esac
        version="v{{ velero_version }}"
        release_name="velero-${version}-linux-${arch}"
        archive_name="${release_name}.tar.gz"
        release_url="https://github.com/vmware-tanzu/velero/releases/download/${version}"
        download_dir=$(mktemp -d)
        trap 'rm -rf -- "$download_dir"' EXIT
        curl -fsSL "$release_url/$archive_name" -o "$download_dir/$archive_name"
        curl -fsSL "$release_url/CHECKSUM" -o "$download_dir/CHECKSUM"
        awk -v name="$archive_name" '$2 == name || $2 == "*" name' "$download_dir/CHECKSUM" \
            > "$download_dir/archive.sha256"
        if [ "$(wc -l < "$download_dir/archive.sha256")" -ne 1 ]; then
            echo "Expected one CHECKSUM entry for $archive_name" >&2
            exit 1
        fi
        (cd "$download_dir" && sha256sum --check --strict --quiet archive.sha256)
        tar -xzf "$download_dir/$archive_name" -C "$download_dir" "$release_name/velero"
        install -m 0755 "$download_dir/$release_name/velero" /usr/local/bin/velero
    - unless: |
        test "$(velero version --client-only 2>/dev/null | awk '$1 == "Version:" { print $2; exit }')" = "v{{ velero_version }}"
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - require:
      - pkg: velero-prerequisites
{% endif %}
