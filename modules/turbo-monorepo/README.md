# Turbo monorepo contract

Copy `files/.config/repository-tooling/turbo-inputs.json` unchanged, populate
its lists, and merge the resulting inputs into root `turbo.json`; do not
replace application task definitions. Artifact-affecting variables belong in a
task `env` or tracked configuration dependency. Runtime-only variables belong
in `passThroughEnv`/`globalPassThroughEnv`. Persistent `dev` is uncached.
