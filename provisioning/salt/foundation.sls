# Keep the initial stack executable without managing any software or services.
salt-foundation:
  test.nop:
    - name: Masterless Salt is ready; no software has been migrated yet.
