# eval: baseline-trigger

## Scenario
"Here's a helper in our TypeScript codebase. Clean up its types: `function formatName(user) { return user.first + ' ' + user.last; }`"

## Expected routing
- Skill that should fire: typescript-core (the always-on baseline; plain `.ts` edit with no deeper trigger)
- Skills that must NOT fire: typescript-type-level, typescript-boundaries, typescript-async, typescript-architecture, typescript-migration

## Expected behavior
- Rules applied: parameters typed from context with no `any`; no gratuitous annotations where inference determines the type; the verification gate runs before done is declared
- Rationalization tempted: "any is faster here"
- Expected rebuttal: `unknown` costs one narrowing check; `any` disables checking for the entire downstream call graph

## What verification must catch
`npx tsc --noEmit` exit 0; diff hygiene grep shows no added `: any` on added lines

## Pass criteria
- Routing: typescript-core fires; no sibling fires
- Behavior: signature has no `any`; `tsc --noEmit` output pasted, exit 0