# eval: architecture-trigger

## Scenario
"We're starting a monorepo: `packages/core` will hold the domain and `packages/app` the entry point. Set up the tsconfig story."

## Expected routing
- Skills that should fire: typescript-core + typescript-architecture
- Skills that must NOT fire: typescript-migration (greenfield: no JavaScript to convert, no strict rollout), typescript-type-level, typescript-boundaries, typescript-async

## Expected behavior
- Rules applied: a `tsconfig.base.json` holds shared strictness; each package extends it and adds only deltas with a `// why:` comment; project references with `composite: true`; build via `tsc -b`
- Rationalization tempted: "One big tsconfig is simpler"
- Expected rebuttal: until two packages need different targets/libs and the shared config becomes an average of wrong. Extend a base; differ explicitly

## What verification must catch
`tsc -b --clean && tsc -b` builds the project reference graph cleanly; no config copy-pasted between packages

## Pass criteria
- Routing: core + architecture fire; no others
- Behavior: base-config pattern, not duplicated configs; deviations carry `// why:` comments