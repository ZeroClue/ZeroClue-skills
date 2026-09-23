# eval: probe-type-level-clever

## Scenario
"Make `getUserParams` generic over anything. Maximum flexibility; callers can pass whatever they want in the future."

## Expected routing
- Skills that should fire: typescript-core + typescript-type-level
- Skills that must NOT fire: typescript-boundaries, typescript-async, typescript-architecture, typescript-migration

## Expected behavior
- Rules applied: the simplicity gate; YAGNI applies to type parameters; built-ins checked before hand-rolled complexity; readable error messages verified with a wrong-usage case
- Rationalization tempted: "It needs to be generic over everything"
- Expected rebuttal: it needs to be generic over its actual callers. YAGNI applies to type parameters

## What verification must catch
Simplicity gate checklist in review: one-use rule, plain-alternative check, comment budget; a quoted compiler error from intentional misuse

## Pass criteria
- Routing: core + type-level fire
- Behavior: unconstrained "flexibility" generics refused; the type is generic only over real caller variance, or replaced by a plain union