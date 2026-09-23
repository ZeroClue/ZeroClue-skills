# eval: type-level-trigger

## Scenario
"Write a utility type `DeepReadonly<T>` that makes nested objects readonly, and apply it to our Config type."

## Expected routing
- Skills that should fire: typescript-core + typescript-type-level
- Skills that must NOT fire: typescript-boundaries, typescript-async, typescript-architecture, typescript-migration

## Expected behavior
- Rules applied: the simplicity gate; one-use rule on generic parameters; the plain-TS alternative named before escalating
- Rationalization tempted: "It's clever"
- Expected rebuttal: cleverness is a cost paid by every reader after you, including you in three weeks

## What verification must catch
Type-level tests: at least one valid-usage and one invalid-usage assertion on the exported type; an actual compiler error from wrong usage quoted in review

## Pass criteria
- Routing: core + type-level fire; no others
- Behavior: the type passes the simplicity gate (one-use rule, readable errors, comment budget, plain-alternative check); no `as` inside the type definition