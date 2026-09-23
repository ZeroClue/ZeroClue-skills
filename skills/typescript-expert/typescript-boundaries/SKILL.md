---
name: typescript-boundaries
description: Untrusted input handling — unknown at the edge, parse-don't-validate,
  schema validation, branded IDs, env parsing. Use for fetch/HTTP responses,
  JSON.parse, request bodies, query params, env vars, localStorage, forms, or
  any data crossing into the program from outside.
metadata:
  version: "1.0.0"
---

# TypeScript Boundary Discipline

## Overview
Types describe what we believe; validation proves what's true. Every byte
entering the program from outside — network, storage, environment, DOM —
is hostile until parsed. This skill defines the edge and everything past it.

## When to Use
- Reading fetch/axios/HTTP responses, JSON.parse, FormData, URLSearchParams
- Accessing `process.env`, localStorage, sessionStorage, cookies
- Consuming third-party callbacks, webhooks, message queues, file contents
- Defining DTOs, request/response types, config loading

## Discipline

### Pre-flight
1. Identify the boundary: name what crosses it (network? env? disk?).
2. Choose the parser: schema library (Zod/valibot/standard-schema) for structured
   data; hand-rolled guards for primitives; both for anything composite.

### In-flight
- Every boundary value is `unknown` until parsed. Never `JSON.parse(text) as T`.
- Parse at the edge, once. Inside the boundary, trust the types — do not
  re-validate what already passed.
- Co-locate schema with the type it produces: `type User = z.infer<typeof UserSchema>`
  — schema is the single source of truth, the type is derived.
- Parse env at startup, into a typed config object; never read `process.env`
  mid-logic.
- Distinguish failure modes: user input → `safeParse` and accumulate errors for
  display; internal invariants → fail fast and throw.
- Branded IDs at the boundary: parse `"123"` into `UserId`, not `string`.

### Post-flight
Run the core gate plus the malformed-input test: feed one invalid payload and
confirm the parse rejects it (see Verification).

## Rationalizations

| Excuse | Rebuttal |
|---|---|
| "The API is documented" | Docs are not runtime. The API changes, the network truncates, the proxy rewrites. The doc is a rumor; the schema is a contract. |
| "It's my own backend" | Your backend has bugs, deploys mid-request, and returns 502 HTML bodies on crashes. Parse anyway. |
| "Validation happens server-side" | This code IS a side to someone. Every program boundary is a trust boundary. |
| "The type is just for autocomplete" | Then it lies. A type that doesn't match runtime is worse than no type. |
| "It's internal, always safe" | localStorage is user-editable, env vars leak between environments, files get hand-edited. Internal is a mood, not a guarantee. |
| "I'll validate later, deeper in" | Every layer after the boundary now carries `as`. Validate at the door, trust the rooms. |

## Red Flags
- `JSON.parse(...)` followed by `as T` or `: T` without a parse step
- Response types declared as plain `interface`s with no schema or guard anywhere
- `process.env.X` read inline in functions (rather than a startup-parsed config)
- Webhook/callback params typed directly as domain types
- `catch` that swallows and returns the raw unknown

## Verification
1. Full core gate
2. One happy-path parse test AND one malformed-payload test per boundary:
   the malformed payload must produce a handled rejection, never a crash or
   a passed-through value

## References
- references/validation-patterns.md — parse-don't-validate patterns, Zod/valibot
  recipes, env parsing, branded IDs, error accumulation
