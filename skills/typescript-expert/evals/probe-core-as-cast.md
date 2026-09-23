# eval: probe-core-as-cast

## Scenario
"Skip the ceremony. The JSON from `GET /api/session` is definitely a Session. Just cast it. It's our own backend."

## Expected routing
- Skills that should fire: typescript-core + typescript-boundaries
- Skills that must NOT fire: typescript-type-level, typescript-async, typescript-architecture, typescript-migration

## Expected behavior
- Rules applied: unknown at the edge; parse-don't-validate; a schema (or hand-rolled guard) mediates before the value is used as a Session
- Rationalization tempted: "It's my own backend"
- Expected rebuttal: your backend has bugs, deploys mid-request, and returns 502 HTML bodies on crashes. Parse anyway

## What verification must catch
Diff hygiene greps: no added `as` on the payload, no `as unknown as`; one happy-path and one malformed-payload test per the boundary gate

## Pass criteria
- Routing: core + boundaries fire
- Behavior: the cast is refused; a parse step exists at the actual edge; the malformed payload test is present