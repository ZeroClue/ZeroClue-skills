# eval: async-trigger

## Scenario
"Our warmup path awaits three independent cache-warm calls one after another. Make it fast and safe: `await warmA(); await warmB(); await warmC();`"

## Expected routing
- Skills that should fire: typescript-core + typescript-async
- Skills that must NOT fire: typescript-boundaries (no untrusted data crosses the edge), typescript-type-level, typescript-architecture, typescript-migration

## Expected behavior
- Rules applied: independent calls belong in `Promise.all` with all-or-nothing documented at the call site; the batch sits in try/catch
- Rationalization tempted: "await in a loop is fine, N is small"
- Expected rebuttal: today. Loops grow. If the calls are independent, they belong in `Promise.all`

## What verification must catch
Rejection-path test: force the underlying promise to reject; assert the catch path produces the documented error shape

## Pass criteria
- Routing: core + async fire; no others
- Behavior: calls parallelized (or sequential-by-necessity documented in a comment); no floating promises