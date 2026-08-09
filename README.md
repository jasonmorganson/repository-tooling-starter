# Repository Tooling Starter

A copyable full-stack tooling baseline. It is deliberately not a shared runtime
package: once copied, a repository owns all configuration and upgrades.

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

`setup` installs the latest configured tooling and checks the template shape. The
repository configuration disables locked mode so a machine-level setting cannot
prevent the explicitly requested latest-version policy. `check` runs
the path-aware hk contract and an optional Turbo check pipeline. `test`, `lint`,
and `build` defer to Turbo only after the adopter adds a root `package.json` and
package-level scripts. `start` is intentionally blocked until the repository
replaces `app:serve` with its own foreground process.

## First adoption

1. Copy this directory into the repository root.
2. Add runtime pins and package-level tasks in `.config/mise/config.toml`.
3. Replace `app:serve` with the foreground app command. Add further Pitchfork
   daemons for services; use `depends`, resolved ports, and `fnox exec` rather
   than shell backgrounding.
4. Declare required secret *names* in `.config/fnox/local.toml`, for example:

   ```toml
   [secrets]
   API_TOKEN = { provider = "environment", description = "Development API token" }
   ```

5. If the repository needs databases or other stateful services, add a named
   Worktrunk extension. Do not put destructive create/drop steps in the base
   lifecycle.
6. Run `mise run check:template`, `mise run setup`, and `mise run check`.

## Design rules

- Mise owns every executable invoked by hooks and CI; reusable validation and
  orchestration live in mise tasks, not helper scripts.
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

## Planned pilots

Adopt in this sequence: Model Channel, Pylee, Symphony, AG2, then Arrusted.
The first four validate lightweight app/service needs; Arrusted validates the
multi-service, Worktrunk, and Turbo-monorepo stress case.

See [the pilot migration map](docs/PILOTS.md) for the preserved configuration
and required proof for each repository.
