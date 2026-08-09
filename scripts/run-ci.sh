#!/usr/bin/env bash
set -euo pipefail

bash scripts/check-template.sh

if [[ -n "${CI_BASE_SHA:-}" && -n "${CI_HEAD_SHA:-}" ]]; then
  mise exec -- hk check --from "$CI_BASE_SHA" --to "$CI_HEAD_SHA"
else
  mise exec -- hk check --all
fi

mise run test
mise run build
