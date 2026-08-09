# Optional configuration modules

Modules are copy-only bundles. Copy a module's `files/` contents into the
repository, retain its README as an adoption record, and fill only its listed
required inputs. Modules never import configuration from this repository.

| Module | Select when | Do not select when |
| --- | --- | --- |
| `hk-javascript` | JavaScript/TypeScript checks use hk and Vitest. | Hooks need another policy. |
| `turbo-monorepo` | The repository owns a Turbo workspace. | There is no Turbo graph. |
| `service-worktree` | Foreground services need Pitchfork and Worktrunk. | There are no long-running services. |
| `github-actions-quality` | CI should run canonical tasks on exact refs. | CI lives on another platform. |
| `dependency-updates/dependabot` | A minimal GitHub-native policy is enough. | Renovate is selected. |
| `dependency-updates/renovate` | Grouped scheduled updates are needed. | Dependabot is selected. |

Select at most one dependency-update module. Never copy secret values,
application commands, database lifecycle, provider topology, or hk globs from
a module without replacing its explicit placeholders.

```sh
mise tasks validate
mise run module:check
mise run check
```
