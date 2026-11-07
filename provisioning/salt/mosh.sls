{% if grains.get('os') == 'MacOS' %}
include:
  - homebrew
{% endif %}

# Installed for both desktop and server roles on supported platforms.
# The mosh package ships both the client (mosh) and mosh-server, so desktops
# get the client and servers can accept mosh connections.
mosh:
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
