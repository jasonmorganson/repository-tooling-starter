# Service and worktree lifecycle

Copy the files under `files/.config/`, then replace daemon and command
placeholders. Each daemon remains foreground, runs through mise/fnox, and
receives dependencies through explicit resolved-port environment variables.
Worktrunk derives branch state/ports and starts/stops only the daemon graph.
Database create, migration, and destruction remain application extensions.
