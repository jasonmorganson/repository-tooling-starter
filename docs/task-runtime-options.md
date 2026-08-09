# Repository task runtime options

This starter standardizes the interface, not a task language. Every repository
keeps the canonical `mise run setup | start | stop | check | test | lint |
format | build | ci` interface, but can choose the most suitable runtime for
each executable task under `.config/mise/tasks/`.

Mise installs and invokes the runtime named by the task's local MISE metadata
(`#MISE` in hash-comment languages and `//MISE` in TypeScript/Rust).
The root [`.config/mise/config.toml`](../.config/mise/config.toml) remains
language-neutral: application runtime pins belong to the adopting repository,
and task-runtime pins belong beside the task that uses them. This builds on
[mise native file tasks](https://mise.jdx.dev/tasks/file-tasks.html), whose
executable files use their shebang as the command and support `#MISE` metadata.

## Decision criteria

Choose per task, rather than by organizational preference. Consider:

- **Import model and built-ins.** Can it import sibling modules cleanly, and do
  its standard library and ecosystem fit the job?
- **Startup and build cost.** Is this a tiny hook, an occasional setup action,
  or a substantial utility whose compilation can be cached?
- **Isolation and permissions.** Can the task state the files, network access,
  commands, and secrets it needs?
- **Cross-platform behavior.** Will contributors and CI use macOS, Linux, or
  Windows, and is the runtime consistently available there?
- **Dependency reproducibility.** Are every library and tool version declared
  in the task or repository, rather than assumed from a developer's machine?
- **Application coupling.** Does this task deliberately need the application's
  package graph? Only then should it reuse that graph.

## Guardrails

1. Every task is an executable file with a shebang and task-local MISE `tools`
   metadata (`#MISE` or the language's comment equivalent). Do not put task
   bodies back into TOML.
2. Nontrivial tasks import repository-local modules (for example,
   `.config/mise/lib/deno/`), rather than growing one opaque task file.
3. Declare and version external dependencies. Never require a globally
   installed language package. A repository may centralize a lockfile when
   several tasks share dependencies.
4. Reuse the application's Bun/Node package graph only when that dependency is
   intentional and documented; otherwise use an isolated task dependency graph.
5. Declare external commands, fnox secret names, and capability boundaries in
   the task documentation/header. Secret values stay in environment-backed
   fnox providers, never in task files.
6. Deno tasks use the smallest applicable `--allow-*` set. Bun, Node,
   Babashka, Nushell, and Rust tasks explicitly document their commands,
   filesystem/network access, and fnox inputs because they do not provide
   Deno-style permission flags.

## Primary choices

| Runtime | Best fit | Why it is attractive | Trade-off |
| --- | --- | --- | --- |
| [Deno TypeScript](https://docs.deno.com/runtime/fundamentals/modules/) | Standalone, import-rich tooling | Native TypeScript, ESM imports, `jsr:`/`npm:` packages, and explicit capability flags. | Use a declared import map/lockfile and grant only the permissions required. |
| [Bun TypeScript](https://bun.sh/docs/runtime/module-resolution) | Tasks intentionally coupled to a Bun/Node application | Fast TypeScript execution and direct use of the app's npm package graph. | That coupling is undesirable for generic tooling; it has no Deno-style capability sandbox. |
| [Node TypeScript](https://nodejs.org/api/typescript.html) | Node-specific app tasks | Native type stripping serves simple TypeScript and the npm ecosystem is broad. | Native type stripping ignores `tsconfig.json` and does not transform TypeScript features; use a declared loader/build step when needed. |
| [Babashka](https://babashka.org/) | Fast operational automation when Clojure is acceptable | Fast native startup with batteries such as process execution, JSON, filesystem, and CLI libraries. | Adopt only where the team is comfortable maintaining Clojure modules. |
| [Nushell](https://www.nushell.sh/book/modules/using_modules.html) | Structured CLI and data pipelines | Modules plus typed table/record pipelines make JSON, CSV, and command output safer than stringly shell plumbing. | Prefer it for orchestration/data flow, not a broad third-party application library graph. |
| [Rust via rust-script](https://rust-script.org/) | Substantial, correctness- or performance-sensitive utilities | Cargo dependencies and cached compilation support robust reusable utilities. | First-run compilation and the Rust toolchain are justified only when the utility earns that cost. |

### Selection guidance

- Choose **Deno** for standalone TypeScript tooling that benefits from imports
  and explicit, minimal `--allow-*` permissions.
- Choose **Bun** only when a task deliberately reuses the repository's Bun/Node
  dependencies.
- Choose **Node** for Node-ecosystem tasks where that coupling is intentional;
  use its native TypeScript mode only within its documented limits.
- Choose **Babashka** for fast, batteries-included operational automation when
  Clojure is an acceptable local language.
- Choose **Nushell** for structured-data and CLI pipeline work.
- Choose **rust-script** for larger utilities where cached compilation is worth
  the startup/build cost.

## Situational choices

These are good when the task belongs naturally to an existing application or
operating environment, but are not a template-wide default.

| Runtime | Use it when | Constraint |
| --- | --- | --- |
| [Go](https://go.dev/ref/mod) | A repository already uses Go or needs a portable single-purpose CLI. | Third-party dependencies need an explicit `go.mod`; outside a module, only standard-library/file imports work. |
| [Elixir/Mix](https://hexdocs.pm/mix/Mix.html) | The app already runs on the BEAM and a task benefits from its OTP/HTTP ecosystem. | Keep Mix dependencies and release/runtime assumptions explicit. |
| [Scala CLI](https://scala-cli.virtuslab.org/) | JVM/Scala libraries materially reduce implementation risk. | JVM/compiler startup is substantial for hook-sized work. |
| [Kotlin scripts](https://kotlinlang.org/docs/custom-script-deps-tutorial.html) | Existing Kotlin/JVM code or libraries are the strongest fit. | Declare script dependencies and accept JVM tooling cost. |
| [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.5) | Windows, Azure/Microsoft APIs, or object-based administration dominate. | Require PowerShell 7+ and version required modules. |
| [Ruby with Bundler](https://bundler.io/guides/gemfile.html) | A mature Ruby CLI/library is already part of the repository. | Commit and use a `Gemfile.lock`; do not rely on system gems. |

## Configuration-only and watchlist options

[Pkl](https://pkl-lang.org/) and [CUE](https://cuelang.org/docs/) are useful for
configuration modeling, validation, and generation. They are not general
purpose task runners, so keep them behind a small Deno/Babashka/Nushell/Rust
adapter when lifecycle behavior is required.

[Zero](https://zerolang.ai/) is promising agent-first tooling, but its own site
states that it is experimental and breaking changes are expected. Treat it as
evaluation-only until that posture changes; do not make canonical tasks depend
on it. Other compile-heavy languages (for example Swift, Zig, or JVM tools)
remain situational: use them when the repository already owns their toolchain
or their libraries clearly outweigh build cost.

## Native mise file-task examples

The following examples are task files, not inline TOML bodies. Keep their
shared logic in sibling modules, and replace the `latest` policy with a
repository pin when reproducibility requires it.

### Deno: standalone task with explicit capabilities

`.config/mise/tasks/check/config`:

```ts
#!/usr/bin/env -S deno run --allow-read=. --allow-env=CI
//MISE description="Check repository configuration"
//MISE tools.deno="latest"

import { assertConfig } from "../../lib/deno/config.ts";

await assertConfig({ root: Deno.cwd(), ci: Deno.env.get("CI") === "true" });
```

The task can read only the repository and the named environment input. Add
`--allow-net=host` or another permission only when the module truly needs it;
see Deno's [security model](https://docs.deno.com/runtime/fundamentals/security/).

### Bun: deliberately reuse the application graph

`.config/mise/tasks/build/assets`:

```ts
#!/usr/bin/env bun
//MISE description="Build assets with the repository's Bun dependencies"
//MISE tools.bun="latest"

import { buildAssets } from "../../lib/bun/assets.ts";

await buildAssets({ packageRoot: process.cwd() });
```

Document the package dependency that `assets.ts` imports and keep the task near
the package manager lockfile. If it does not need that graph, prefer Deno or a
separate declared task dependency instead.

### Nushell: structured command results

`.config/mise/tasks/check/ports`:

```nu
#!/usr/bin/env nu
#MISE description="Confirm daemon ports are unique"
#MISE tools.nushell="latest"

use ../../lib/nu/ports.nu validate_ports

validate_ports
```

The module should expose structured records, and it should name any external
commands (such as `lsof`) it invokes. Supply environment-backed secret names
through `fnox exec` only when a task actually needs them.

### rust-script: cached compiled utility

`.config/mise/tasks/check/manifest`:

```rust
#!/usr/bin/env rust-script
//MISE description="Validate generated manifest invariants"
//MISE tools.rust="latest"
// cargo-deps: anyhow="1.0", serde_json="1.0"

#[path = "../../lib/rust/manifest.rs"]
mod manifest;

fn main() -> anyhow::Result<()> {
    manifest::validate(std::env::current_dir()?)
}
```

Keep the checked-in module in `.config/mise/lib/rust/manifest.rs` (using an
appropriate `#[path = ...]` declaration if necessary), pin dependencies in the
embedded Cargo metadata or a repository Cargo manifest, and document any
commands or fnox inputs it uses.

For Babashka, Go, Elixir, Scala CLI, Kotlin, and PowerShell, use the same
shape: a runtime shebang, a verified task-local mise tool identifier, imports
from a sibling repository module, and versioned dependencies. Verify the exact
mise registry identifier before adding it; `mise tasks validate` validates the
file-task header and discovery contract.

## Review checklist

Before accepting a task runtime choice, confirm that it preserves the canonical
task name, declares its runtime locally, imports repository-owned code, has no
ambient global package assumption, exposes only required capabilities/commands,
and receives secrets only from fnox. Then run:

```sh
mise tasks validate
mise run check
```

CI runs the same canonical lifecycle, so runtime-specific work remains inside
the task file rather than leaking into hooks or workflow YAML.
