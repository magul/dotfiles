# Configuration sources

Place migrated configuration files here, grouped by application. Salt references
them as `salt://files/<application>/<filename>`. Add `.jinja` for files rendered
with Salt's Jinja template engine.

Files in this directory are source assets, not home-directory targets. See
[the configuration migration guide](../../../docs/configuration.md) for the
ownership, permission, and handoff conventions.
