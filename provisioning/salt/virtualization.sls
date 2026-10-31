{% set context = pillar.get('dotfiles', {}) %}
{% if grains.get('os') in ['Debian', 'Ubuntu'] and context.get('role') == 'desktop' %}

virtualization-packages:
  pkg.installed:
    - pkgs:
      - qemu-system
      - qemu-system-gui
      - qemu-utils
      - qemu-user
      - qemu-user-binfmt
      - libvirt-daemon-system
      - libvirt-clients
      - virtinst
      - virt-manager
      - bridge-utils
      - ovmf
    - refresh: true
    - cache_valid_time: 3600

virtualization-user-groups:
  user.present:
    - name: {{ context['user'] | yaml_dquote }}
    - groups:
      - libvirt
      - kvm
    - remove_groups: false
    - createhome: false
    - require:
      - pkg: virtualization-packages

virtualization-service:
  service.running:
    - name: libvirtd
    - enable: true
    - require:
      - pkg: virtualization-packages
{% endif %}
