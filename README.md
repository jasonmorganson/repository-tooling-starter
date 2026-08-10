# Repository Tooling Starter

A minimal example that consumes the shared
[repository-tooling](https://github.com/jasonmorganson/repository-tooling)
Nushell task library through mise remote tasks. It keeps the configuration
baseline and application extensions local while tracking the shared task set.

## Canonical interface

```sh
mise run setup
mise run start
mise run stop
mise run format
mise run lint
mise run check
mise run test
mise run build
mise run ci
```

The root `mise.toml` includes the shared tasks from `main` first, then all
standard local task directories. A local task with the same name therefore wins
over the shared default. `start` is intentionally blocked until the repository
replaces local `app:serve` with its own foreground process.

## First adoption

1. Copy this directory into the repository root.
2. Keep the remote include on `main`, or replace `main` with a release tag or
   full commit SHA when the repository needs pinned shared-task behavior.
3. Add application runtime pins in `.config/mise/config.toml` and local
   overrides under `.config/mise/tasks/`. A local file may replace any shared
   task while retaining the rest of the shared task library.
4. Replace `app:serve` with the foreground app command. Add further Pitchfork
   daemons for services; use `depends`, resolved ports, and `fnox exec` rather
   than shell backgrounding.
5. Declare required secret *names* in `.config/fnox/local.toml`, for example:

   ```toml
   [secrets]
   API_TOKEN = { provider = "environment", description = "Development API token" }
   ```

6. If the repository needs databases or other stateful services, add a named
   Worktrunk extension. Do not put destructive create/drop steps in the base
   lifecycle.
7. Run `mise tasks validate`, `mise run setup`, and `mise run check`.

Use `mise run --no-cache <task>` or `MISE_TASK_REMOTE_NO_CACHE=true` to fetch
the remote task library without its local cache.

## Design rules

- Mise owns every executable invoked by hooks and CI; shared behavior comes
  from remote native tasks and repository-specific behavior stays local.
- Each shared task declares its runtime locally; application tasks choose their
  own runtime and dependencies.
- fnox configuration contains declarations only; values arrive through the
  environment in local development and CI.
- Pitchfork, not ad hoc shell jobs, owns daemon lifetime and port allocation.
- Worktrunk derives a stable per-branch port base and always runs `mise run stop`
  before removal.
- Turbo's cached tasks must explicitly declare configuration and required
  environment inputs. Add project-specific variables to `globalPassThroughEnv`
  only when they do not affect outputs; otherwise use task-level `env`.
- CI sends exact base and head SHAs to hk so changed-range checks cannot silently
  use a stale local branch.

See [repository-tooling](https://github.com/jasonmorganson/repository-tooling)
for the shared task source and its remote-task contract.
