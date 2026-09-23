---
name: typescript-migration
description: Incremental TypeScript adoption — JS→TS conversion, strict-mode rollout flag by flag, TS version upgrades, suppression burn-down. Use when migrating a JavaScript codebase, enabling strict flags on existing code, or reducing accumulated type suppressions.
metadata:
  version: "1.0.0"
---

# TypeScript Migration Discipline

## Overview
Migrations are the one context where the core skill's strict baseline is temporarily suspended — under a plan that ends. This skill defines the plan, the order of operations, and the exit condition. A migration without an end state is just a codebase with `any` in it.

## When to Use
- Converting JS files/modules to TS (any scale)
- Enabling `strict` (or individual strict flags) on an existing TS codebase
- Upgrading TypeScript major versions
- Deliberately reducing `@ts-expect-error` / `any` counts

## Discipline

### Pre-flight (the plan — required before touching files)
1. Establish the current state: strict flags on/off, file counts, suppression counts (`grep -rc "@ts-expect-error" src | sort` — record the number).
2. Define the end state in writing: which flags on, suppression count target (zero new; existing trending down), date or milestone.
3. Choose the order (see references/incremental-strategies.md):
   - JS→TS: leaf modules first (fewest importers of their types), one module per commit, `allowJs: true` as the bridge.
   - Strict rollout order: `strictNullChecks` first (largest error class, most valuable), then `noImplicitAny`, then the rest of the family.

### In-flight
- One file or one flag per change, fully verified, committed. Big-bang is forbidden — it produces unreviewable diffs and broken builds.
- JSDoc types are a legitimate bridge: `// @ts-check` + JSDoc on `.js` files converts real type errors before the rename to `.ts`.
- During migration only: `@ts-expect-error` with reason + issue, `unknown` + one documented cast at the seam. Never new `any`, never `@ts-ignore` (see references/suppression-hygiene.md).
- A migrated file must pass the full core gate before the commit counts.

### Post-flight (the exit condition)
The migration is done when: every planned flag is on, `tsc --noEmit` exits 0, and the suppression count is at or below target. Then this skill deactivates and `typescript-core` owns the codebase again. State this transition explicitly in the final PR.

## Rationalizations

| Excuse | Rebuttal |
|---|---|
| "We'll never get strict on, too much code" | Strict flags roll out one at a time over months. "Never" means "we haven't written the plan." |
| "any just for this file" | Then it's `unknown` + one cast at the seam, documented. `any` spreads to everyone who imports the file. |
| "ts-ignore the whole file during migration" | That's not migration, it's annotation. expect-error per line, with reasons, on a burn-down list. |
| "One big-bang PR is faster" | Faster to break. Unreviewable, un-revertable, and lands all at once on a codebase that hasn't been exercised flag-by-flag. |
| "We'll clean the suppressions someday" | Suppressions only ever grow without a tracked budget. Burn-down is a standing checklist item or it never happens. |

## Red Flags
- Suppression count rising across migration PRs (the migration is going backwards)
- New `any` in a migration PR (the escape hatch being widened, not crossed)
- Strict flags turned off to "fix" the build (the migration being abandoned mid-flight)
- No written end state — the single strongest predictor of a permanent half-migration

## Verification
1. Full core gate per commit
2. Suppression count reported in every migration PR body: current vs. previous
3. Flag-status diff when a strict flag flips: `tsc --noEmit` before and after in the PR description

## References
- references/incremental-strategies.md — flag order, leaf-first conversion, JSDoc bridge
- references/suppression-hygiene.md — expect-error budget, reasons, burn-down tracking