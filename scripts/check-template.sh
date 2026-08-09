#!/usr/bin/env bash
set -euo pipefail

required_files=(
  mise.toml
  .config/mise/config.toml
  .config/fnox/local.toml
  .config/hk.pkl
  .config/pitchfork.toml
  .config/wt.toml
  turbo.json
  .github/workflows/ci.yml
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "Missing required template file: $file" >&2; exit 1; }
done

for task in setup start stop check test lint format build ci; do
  grep -Fq "[tasks.${task}]" .config/mise/config.toml || {
    echo "Missing canonical mise task: $task" >&2
    exit 1
  }
done

grep -Fq 'default_branch = "origin/main"' .config/hk.pkl
grep -Fq 'mise exec -- hk' .config/mise/config.toml
grep -Fq 'type = "plain"' .config/fnox/local.toml
grep -Fq 'fnox -c .config/fnox/local.toml' .config/pitchfork.toml
grep -Fq 'port-base={{ branch | hash_port }}' .config/wt.toml
grep -Fq '"cache": false, "persistent": true' turbo.json
grep -Fq 'CI_BASE_SHA' .github/workflows/ci.yml

# Reject concrete secret assignments while allowing names and provider metadata.
if grep -En '^\s*[A-Z][A-Z0-9_]*\s*=\s*"[^"].*"\s*$' .config/fnox/*.toml | grep -Ev 'provider\s*=|description\s*='; then
  echo "fnox config must declare secret sources, not secret values." >&2
  exit 1
fi

echo "Repository tooling starter contract is valid."
