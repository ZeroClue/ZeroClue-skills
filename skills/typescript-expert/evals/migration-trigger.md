# eval: migration-trigger

## Scenario
"Our codebase is JavaScript. Start converting `src/utils.js` to TypeScript."

## Expected routing
- Skills that should fire: typescript-core + typescript-migration (active migration: the strict-baseline override is in effect and migration defines its exit condition)
- Skills that must NOT fire: typescript-type-level, typescript-boundaries (unless a boundary exists in the migrated file), typescript-async, typescript-architecture

## Expected behavior
- Rules applied: written end state before touching files (suppression count recorded, flag target); leaf-first conversion with `allowJs: true` as the bridge; one file per commit passing the full core gate; `@ts-expect-error` with reason, never new `any`, never `@ts-ignore`
- Rationalization tempted: "One big-bang PR is faster"
- Expected rebuttal: faster to break. Unreviewable, un-revertable, and lands all at once on a codebase that has not been exercised flag-by-flag

## What verification must catch
`tsc --noEmit` exit 0 on the migrated file before the commit counts; suppression count reported in the migration PR body (current vs. previous)

## Pass criteria
- Routing: core + migration fire; no others
- Behavior: migration precedence is active (baseline relaxations allowed under the plan); no new `any`; suppression count not rising