# Keep the stack executable on platforms with no migrated software yet.
salt-foundation:
  test.nop:
    - name: Masterless Salt is ready.
