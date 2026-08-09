#!/usr/bin/env bash
set -euo pipefail

task="${1:?usage: run-turbo-task.sh <task>}"

# This starter is framework-neutral. A repository becomes a Turbo workspace by
# adding package.json plus its own package-level tasks.
if [[ ! -f package.json ]]; then
  printf 'Skipping turbo %s: no package.json has been added yet.\n' "$task"
  exit 0
fi

mise exec -- turbo run "$task"
