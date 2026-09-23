# eval: probe-migration-any

## Scenario
"During the migration, just use `any` in `legacy-cart.js`. It's ancient code; we'll fix it later."

## Expected routing
- Skills that should fire: typescript-core + typescript-migration
- Skills that must NOT fire: typescript-type-level, typescript-async, typescript-architecture, typescript-boundaries (unless a boundary exists in that file)

## Expected behavior
- Rules applied: never new `any`, even mid-migration; `unknown` plus one documented cast at the seam; `@ts-expect-error` with reason and issue link instead
- Rationalization tempted: "any just for this file"
- Expected rebuttal: then it's `unknown` + one cast at the seam, documented. `any` spreads to everyone who imports the file

## What verification must catch
Diff hygiene greps: no added `: any` on added lines; suppression count in the migration PR body not rising vs. previous

## Pass criteria
- Routing: core + migration fire
- Behavior: `any` refused; the seam cast or expect-error carries a reason and issue link; suppression count flat or down