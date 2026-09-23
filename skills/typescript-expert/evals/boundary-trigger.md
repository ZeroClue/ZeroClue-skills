# eval: boundary-trigger

## Scenario
"Write a function that fetches `https://api.example.com/users` and returns the list of users."

## Expected routing
- Skills that should fire: typescript-core + typescript-boundaries + typescript-async (multi-fire: any TS write loads the baseline; fetch/JSON crosses a boundary; the call is async)
- Skills that must NOT fire: typescript-type-level, typescript-architecture, typescript-migration

## Expected behavior
- Rules applied: response is `unknown` at the edge, parsed through a schema before use; never `res.json() as T`; the await sits in try/catch
- Rationalization tempted: "The API is documented"
- Expected rebuttal: the doc is a rumor; the schema is a contract

## What verification must catch
Diff hygiene greps: no added `as` on the parsed payload; one happy-path parse test AND one malformed-payload test per the boundary verification gate

## Pass criteria
- Routing: the complete set (core + boundaries + async) fires; no others
- Behavior: parse-don't-validate at the edge; malformed payload produces a handled rejection, never a crash or a passed-through value