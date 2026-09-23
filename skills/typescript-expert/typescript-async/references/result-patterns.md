# Result Patterns

## The Result type

```typescript
export type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

export const Ok = <T>(value: T): Result<T, never> => ({ ok: true, value });
export const Err = <E>(error: E): Result<never, E> => ({ ok: false, error });
```

## Error taxonomy

| Kind | Mechanism | Examples |
|---|---|---|
| Bug | `throw` (or never returns) | null where impossible, invariant broken, wrong internal state |
| Domain outcome | `Result` return | user not found, invalid input, rate limited, timeout |

Rule of thumb: if the caller could meaningfully branch on it, it's a Result.
If only a human should ever see it in a crash log, it's a throw.

## Wrappers

```typescript
export async function withTimeout<T>(
  p: Promise<T>, ms: number, message: string, signal?: AbortSignal,
): Promise<Result<T, TimeoutError>> {
  // race the promise against a timer; reject timer wins → Err
}

export async function withRetry<T>(
  fn: (attempt: number) => Promise<T>,
  opts: { max: number; baseMs: number; retryOn: (e: unknown) => boolean },
): Promise<Result<T, RetryError>> {
  // exponential backoff + jitter; only idempotent operations
}
```

## Composing Results

```typescript
const user = await getUser(id);        // Result<User, NotFound>
if (!user.ok) return Err(user.error);
const perms = await getPerms(user.value.id); // Result<Perms, Denied>
```
(Or use a lib — Effect, neverthrow — if the codebase already has one; do not
hand-roll a second Result ecosystem beside an existing one.)
