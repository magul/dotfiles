# Configuration

All tracked configuration is now managed by Salt. States under
`provisioning/salt/configuration/` define the managed files. Clone the repository
with Git; the runner reads Salt's `role` grain.

## Shared context

`scripts/provision_context.py` supplies `dotfiles:user`, `dotfiles:group`,
`dotfiles:home`, and `dotfiles:role` as local pillar data. User, primary group,
and home come from the operating system's account database, including when
Linux provisioning runs through sudo. The role comes from Salt's `role`
grain, loaded from `~/.config/salt/grains` through the isolated runner configuration.

The foundation checks that these values are strings. Configuration states and
templates import the shared map:

```jinja
{% from "configuration/map.jinja" import configuration with context %}
```

The map provides `user`, `group`, `home`, `role`, `os`, `config_home`, and
`vscode_user_dir`. `config_home` is `~/.config`; applications with other native
locations need their own path mapping. VS Code uses `.config/Code/User` on Linux
and `Library/Application Support/Code/User` on macOS.

Permission defaults are `directory_mode: '0700'`, `file_mode: '0600'`, and
`executable_mode: '0700'`. These defaults apply to new configuration states;
they do not change existing directories or software installation states.

## Source files and states

Store source files under `provisioning/salt/files/<application>/`.
Use `file.managed` for individual files and `template: jinja` only when rendering
is needed. Manage each configuration directory's owner, group, and mode explicitly.

For example, a future configuration state can use:

```yaml
{% from "configuration/map.jinja" import configuration with context %}

example-config-directory:
  file.directory:
    - name: {{ (configuration.config_home ~ '/example') | yaml_dquote }}
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.directory_mode | yaml_dquote }}
    - makedirs: true

example-config:
  file.managed:
    - name: {{ (configuration.config_home ~ '/example/config.toml') | yaml_dquote }}
    - source: salt://files/example/config.toml
    - user: {{ configuration.user | yaml_dquote }}
    - group: {{ configuration.group | yaml_dquote }}
    - mode: {{ configuration.file_mode | yaml_dquote }}
    - require:
      - file: example-config-directory
      - test: configuration-context
```

This is a pattern, not an enabled state. Include `foundation` when a configuration
state needs to run independently of the full stack. Add dependencies on the
application's installation state with the correct platform-specific state type.

Use explicit files rather than recursively copying, cleaning, or changing modes
across existing application directories. Leave credentials, runtime data, caches,
and local overrides outside managed file sets.

Before replacing an existing file, preserve any local edits you want to keep in
the source or a separate backup outside the runner's temporary directory. Salt's
`backup: minion` stores backups in its cache, which this runner removes after
each run; it does not provide a persistent backup here.

## Adopting existing configuration

1. Inspect the current destination and preserve local changes before replacement.
2. Add its source to Salt's file tree and define a configuration state.
3. Ensure only Salt manages the destination. Keep the existing destination
   available for adoption.
4. Check rendered content, destination paths, role selection, owner, group, and
   permissions on Linux and macOS. Preserve desktop-only selection where needed.
5. Preview, apply, then confirm a second apply reports no changes. Validate on
   the target platform before treating the change as complete.

Local secrets and `.zshrc.local` remain unmanaged. Bootstrap uses Git and Salt.
