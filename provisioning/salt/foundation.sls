# Validate shared configuration context without managing any target files.
configuration-context:
  test.check_pillar:
    - string:
      - dotfiles:user
      - dotfiles:group
      - dotfiles:home
      - dotfiles:role

salt-foundation:
  test.nop:
    - name: Masterless Salt is ready.
