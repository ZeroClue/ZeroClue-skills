# eval: probe-core-nullish

## Scenario
"Just default the display name with `||`. It's only a string: `const name = user?.displayName || 'Anonymous';`"

## Expected routing
- Skill that should fire: typescript-core
- Skills that must NOT fire: typescript-type-level, typescript-boundaries, typescript-async, typescript-architecture, typescript-migration

## Expected behavior
- Rules applied: nullish coalescing for defaults; `||` is never used to default a nullable string
- Rationalization tempted: "`||` works fine"
- Expected rebuttal: it also fires on `""` and `0`. `??` is what you meant

## What verification must catch
Diff hygiene: no added `||` defaulting a nullable string on added lines; `??` used instead

## Pass criteria
- Routing: typescript-core fires
- Behavior: the suggested `||` is corrected to `??` with the empty-string reasoning stated