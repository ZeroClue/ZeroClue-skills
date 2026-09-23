---
name: typescript-architecture
description: Project-level TypeScript architecture — tsconfig strategy, monorepo project references, module boundaries, import direction, public API surface minimalism. Use when setting up or restructuring a project, defining module boundaries, designing exported APIs, or configuring monorepos.
metadata:
  version: "1.0.0"
---

# TypeScript Architecture Discipline

## Overview
Structure decisions that outlive any single file: how configs compose, how modules depend, and how much surface a package exposes. Architecture is mostly the discipline of saying no.

## When to Use
- Creating tsconfig, package.json, or repo structure from scratch
- Adding packages/workspaces, restructuring folders
- Designing a library or module's public exports
- Any "where should this live" decision with cross-file consequences

## Discipline

### Pre-flight
1. Map the dependency direction before adding files: config → primitives → domain → services → entry points. Dependencies point one way.
2. Confirm the module story: single package or workspace? This determines tsconfig strategy (see references/module-design.md).

### In-flight
- **tsconfig:** a `tsconfig.base.json` holds shared strictness; each package extends it and adds only what differs, with a `// why:` comment on each deviation. Never copy-paste configs between packages.
- **Monorepos:** project references with `composite: true`; build via `tsc -b`. Cross-package type errors surface at build time, not runtime.
- **Barrels are a smell:** `index.ts` re-exporting a package's guts creates cycles, kills tree-shaking, and hides real dependency edges. Export from the module; import from the module.
- **API surface:** export the minimum. Every export is a promise (see references/api-surface.md — Hyrum's Law: someone will depend on anything observable). Internal helpers stay internal.
- **Public functions get explicit return types.** Inference is for internals; APIs are contracts, and contracts are written down.
- **No cycles, ever.** If two modules need each other, one of them is wrong — extract the shared piece or invert the dependency.

### Post-flight
Run the core gate plus: `tsc -b --clean && tsc -b` (build graph integrity).

## Rationalizations

| Excuse | Rebuttal |
|---|---|
| "Barrel files make imports cleaner" | They make imports shorter and graphs worse: cycles, dead code retention, and refactor landslides. Import from the real module. |
| "I'll export this helper, might be useful" | Every export is maintenance debt and an API promise. Add it when a second caller exists, not before. |
| "The framework handles the config" | The framework handles its defaults, which are not your strictness. Base config still applies. |
| "One big tsconfig is simpler" | Until two packages need different targets/libs and the shared config becomes an average of wrong. Extend a base; differ explicitly. |
| "We'll fix the cycle later" | Cycles compound — every later fix threads through more code. Fix now while it's two files. |

## Red Flags
- Circular imports (verify with `madge --circular src/`)
- Cross-layer relative imports (`../../..`) that skip the layer boundary
- tsconfig drift: two packages with meaningfully different strictness, no comment why
- An `index.ts` exporting dozens of internal modules
- Public functions whose return types are inferred (readers can't see the contract)

## Verification
1. Full core gate
2. `tsc -b` (or the project's build) — project reference graph builds cleanly
3. Cycle check if `madge` is available — zero cycles

## References
- references/module-design.md — base-config pattern, project references, workspace layout
- references/api-surface.md — Hyrum's Law, export minimalism, explicit contract types