# Pilot Migration Map

Do not replace an application's existing tasks wholesale. First preserve its
application commands behind the starter's canonical task names, then add only
the missing capability files.

| Repository | Existing strengths | Migration focus | Acceptance proof |
| --- | --- | --- | --- |
| Model Channel | Turbo and `.config/mise.toml` | Add root mise sentinel, canonical tasks, hk, fnox, Pitchfork, and Worktrunk; retain its Node/nub/aube pins. | `mise run setup`, `check`, and CI range check in a clean worktree. |
| Pylee | Root mise lifecycle, hk, Turbo, Vercel tasks | Preserve Vercel login/link/pull and database tasks; introduce fnox, Pitchfork, Worktrunk, and canonical task aliases. | Vercel setup remains explicit; a branch gets isolated ports and stops cleanly. |
| Symphony | Service-oriented deployment topology | Add the complete starter and configure its one foreground service daemon plus declared environment secrets. | Service start/stop and exact-range CI check work without application background jobs. |
| AG2 | fnox, Pitchfork, Worktrunk, hk, structured mise tasks | Add the root sentinel, canonical aliases, and Turbo only if its workspace tasks support it; preserve existing database lifecycle. | Existing `setup`/database flow and worktree cleanup still pass. |
| Arrusted | Full multi-service, hk, fnox, Pitchfork, Worktrunk, Turbo baseline | Align naming and documentation only; retain its pinned/complex app-specific graph and stricter validation. | Existing worktree and provider smoke suites remain green. |

## Migration rules

- Work from a clean, dedicated branch or worktree for each repository.
- Keep all secret values out of committed fnox files; migrate declarations only.
- Add Turbo environment inputs before moving an output-affecting variable into
  cached tasks.
- Prove `mise run stop` before enabling Worktrunk's `pre-remove` hook.
- Use the starter self-check as a structural guard, not a substitute for each
  application's focused test and deployment checks.
