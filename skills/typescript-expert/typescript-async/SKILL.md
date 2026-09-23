---
name: typescript-async
description: Async discipline — try/catch around await, no floating promises,
  Result pattern for expected errors, AbortController cancellation, timeouts,
  structured concurrency, retry with backoff. Use for any async/await, Promise,
  fetch, retry, timeout, or concurrency code.
metadata:
  version: "1.0.0"
---

# TypeScript Async Discipline

## Overview
Async code fails silently by default: rejections vanish, loops serialize,
cancellation never happens. This skill makes every async path explicit about
failure, completion, and cancellation.

## When to Use
- Writing or reviewing any `async` function, `await`, or `Promise`
- fetch calls, retries, timeouts, polling
- Background jobs, queues, concurrent batch processing
- Error handling design for anything I/O-shaped

## Discipline

### Pre-flight
1. Classify the failure: bug (programmer error → throw/never) vs domain outcome
   (expected → Result). Decide before writing the call.
2. Identify the cancellation story: what AbortSignal applies? If none exists,
   that's a finding to report, not a detail to skip.

### In-flight
- Every `await` sits inside `try/catch` in non-test code, or the function's
  contract explicitly documents propagation.
- No floating promises: every call is awaited, returned, or explicitly marked
  with a `// fire-and-forget: <reason>` comment naming the owner of the failure.
- Expected failures return `Result`, not throw:

  ```typescript
  type Result<T, E> =
    | { ok: true; value: T }
    | { ok: false; error: E };
  ```
- Cancellation: accept `signal?: AbortSignal`, thread it to fetch/operations,
  clean up in `finally`. AbortController is created by the caller, consumed here.
- Timeouts are wrappers, not vibes:

  ```typescript
  withTimeout(promise, 5_000, "fetchUser timed out");
  ```
- Concurrency: `Promise.all` only when all-or-nothing is correct;
  `Promise.allSettled` for independent tasks; bounded pools for large lists —
  never unbounded `all` over untrusted array sizes.
- Retries: capped count, exponential backoff with jitter, retry only idempotent
  operations, never retry on 4xx.

### Post-flight
Run the core gate plus the rejection-path test (see Verification).

## Rationalizations

| Excuse | Rebuttal |
|---|---|
| "The promise won't reject" | That's what the last person whose promise rejected said. Unhandled rejections crash Node and silently die in browsers. |
| "Fire-and-forget is fine here" | Then name the owner of its failure in a comment. Unnamed = unowned = unhandled. |
| "await in a loop is fine, N is small" | Today. Loops grow. If the calls are independent, they belong in `Promise.all`; if sequential by necessity, say so in a comment. |
| "I'll add the abort signal later" | Later never comes; the API shape changes now or never. Adding `signal` later is a breaking change across every caller. |
| "Throwing is simpler than Result" | Simpler for the writer, hostile to the caller — forces try/catch for an expected case. Expected outcomes are values. |
| "Promise.all fails fast, that's what I want" | Then document all-or-nothing at the call site. If partial success matters, you wanted allSettled. |

## Red Flags
- `void someAsync()` or bare `someAsync()` without a reason comment
- `await` with no surrounding try/catch and no documented propagation
- New `.then().catch()` chains
- Retry loop with no cap or no backoff
- `Promise.all` over a list whose length is untrusted
- No AbortSignal anywhere in a network-touching call chain
- Empty `catch (e) {}` — swallowing is worse than crashing

## Verification
1. Full core gate
2. Rejection-path test: force the underlying promise to reject; assert the
   Result/catch path produces the documented error shape
3. If cancellation exists in the design, one test where the signal aborts and
   cleanup runs (assert via spy/flag)

## References
- references/result-patterns.md — Result type, error taxonomy, retry/timeout wrappers
- references/cancellation.md — AbortController lifecycle, signal threading, finally cleanup
