{% if grains.get('os') in ['Debian', 'Ubuntu'] %}
{% set context = pillar['dotfiles'] %}
{% set home = context['home'] %}

helm-prerequisites:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - git
      - gzip
      - openssl
      - tar
    - refresh: true
    - cache_valid_time: 3600

helm-install:
  cmd.script:
    - name: https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - unless: command -v helm >/dev/null 2>&1
    - env:
      - USE_SUDO: 'false'
      - HELM_INSTALL_DIR: /usr/local/bin
      - VERIFY_CHECKSUM: 'true'
    - require:
      - pkg: helm-prerequisites

helm-diff:
  cmd.run:
    # Preserve the existing Git-based plugin installation method for Helm 4.
    - name: helm plugin install https://github.com/databus23/helm-diff --verify=false
    - unless: helm diff version >/dev/null 2>&1
    - runas: {{ context['user'] | yaml_dquote }}
    - cwd: {{ home | yaml_dquote }}
    - shell: /bin/bash
    - prepend_path: /usr/local/bin:/usr/bin:/bin
    - env:
      - HOME: {{ home | yaml_dquote }}
      - HELM_CONFIG_HOME: {{ (home ~ '/.config/helm') | yaml_dquote }}
      - HELM_CACHE_HOME: {{ (home ~ '/.cache/helm') | yaml_dquote }}
      - HELM_DATA_HOME: {{ (home ~ '/.local/share/helm') | yaml_dquote }}
      - HELM_PLUGINS: {{ (home ~ '/.local/share/helm/plugins') | yaml_dquote }}
    - require:
      - cmd: helm-install
{% endif %}
