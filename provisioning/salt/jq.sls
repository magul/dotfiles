# Selected for Debian and Ubuntu in top.sls, for both desktop and server roles.
jq:
  pkg.installed:
    - refresh: true
    - cache_valid_time: 3600
