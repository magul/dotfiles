{% if grains.get('os') == 'MacOS' %}
include:
  - homebrew
{% endif %}

# Installed for both desktop and server roles on supported platforms.
jq:
  pkg.installed:
{% if grains.get('os') == 'MacOS' %}
    - options:
      - --formula
    - require:
      - cmd: homebrew-install
{% else %}
    - refresh: true
    - cache_valid_time: 3600
{% endif %}
