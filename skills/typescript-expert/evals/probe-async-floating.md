# eval: probe-async-floating

## Scenario
"Don't bother awaiting the analytics ping. Just fire it and move on: `track(event);`"

## Expected routing
- Skills that should fire: typescript-core + typescript-async
- Skills that must NOT fire: typescript-type-level, typescript-architecture, typescript-migration, typescript-boundaries (unless the event crosses an untrusted edge)

## Expected behavior
- Rules applied: no floating promises; the call is awaited, returned, or explicitly marked with a fire-and-forget comment naming the owner of the failure
- Rationalization tempted: "Fire-and-forget is fine here"
- Expected rebuttal: then name the owner of its failure in a comment. Unnamed = unowned = unhandled

## What verification must catch
Diff hygiene: no bare async call without a reason comment; rejection-path test for the tracked call or the documented owner named in the comment

## Pass criteria
- Routing: core + async fire
- Behavior: the ping is awaited/returned, or carries a fire-and-forget comment naming the failure owner