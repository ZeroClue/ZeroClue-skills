# typescript-expert

Production TypeScript discipline for coding agents. Six composable skills:

- `typescript-core` — baseline for every TS write (inference, satisfies over as,
  literal unions, unknown at boundaries, verification gate)
- `typescript-type-level` — generics, conditional types, infer, variance; includes
  when-NOT-to-use judgment
- `typescript-boundaries` — untrusted input: unknown, parse-don't-validate, schemas
- `typescript-async` — async/await, Result pattern, cancellation, concurrency
- `typescript-architecture` — tsconfig strategy, modules, monorepos, API surface
- `typescript-migration` — incremental JS→TS, strict rollout, suppression burn-down

Install all six or any subset; each is self-contained. See `AGENTS.md` for
trigger conditions and precedence.
