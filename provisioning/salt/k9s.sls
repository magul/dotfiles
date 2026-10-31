{% if grains.get('os') in ['Debian', 'Ubuntu'] %}

k9s-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - python3
      - coreutils
      - gzip
      - tar
    - refresh: true
    - cache_valid_time: 3600

k9s-install:
  cmd.run:
    - name: |
        set -euo pipefail
        arch=$(dpkg --print-architecture)
        case "$arch" in
            amd64|arm64) ;;
            *) echo "Unsupported k9s architecture: $arch" >&2; exit 1 ;;
        esac
        download_dir=$(mktemp -d)
        trap 'rm -rf -- "$download_dir"' EXIT
        curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest \
            -o "$download_dir/release.json"
        archive_name="k9s_Linux_${arch}.tar.gz"
        archive_url=$(python3 -c '
        import json, sys
        with open(sys.argv[1]) as release_file:
            release = json.load(release_file)
        urls = [asset["browser_download_url"] for asset in release["assets"]
                if asset["name"] == sys.argv[2]]
        if len(urls) != 1:
            sys.exit("Expected one k9s release archive named " + sys.argv[2])
        print(urls[0])
        ' "$download_dir/release.json" "$archive_name")
        curl -fsSL "$archive_url" -o "$download_dir/$archive_name"
        curl -fsSL "${archive_url%/*}/checksums.sha256" -o "$download_dir/checksums.sha256"
        python3 -c '
        import hashlib, pathlib, sys
        directory, filename = pathlib.Path(sys.argv[1]), sys.argv[2]
        entries = [line.split() for line in (directory / "checksums.sha256").read_text().splitlines()]
        hashes = [entry[0] for entry in entries if len(entry) == 2 and entry[1].lstrip("*") == filename]
        digest = hashlib.sha256()
        with (directory / filename).open("rb") as archive:
            for chunk in iter(lambda: archive.read(1024 * 1024), b""):
                digest.update(chunk)
        if len(hashes) != 1 or digest.hexdigest() != hashes[0]:
            sys.exit("k9s archive checksum verification failed")
        ' "$download_dir" "$archive_name"
        tar -xzf "$download_dir/$archive_name" -C "$download_dir" k9s
        install -m 0755 "$download_dir/k9s" /usr/local/bin/k9s
    - unless: command -v k9s >/dev/null 2>&1
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - require:
      - pkg: k9s-prerequisites
{% endif %}
