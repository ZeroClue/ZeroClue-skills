# Cancellation

## Lifecycle

1. **Caller creates** `const controller = new AbortController()`
2. **Caller passes** `controller.signal` down
3. **Callee threads** the signal into fetch/timers/operations
4. **Callee cleans up** in `finally` — the ONLY place cleanup belongs
5. **Catcher distinguishes** `AbortError` (expected, usually silent/neutral)
   from real errors

## Threading the signal

```typescript
async function fetchUser(id: string, signal?: AbortSignal): Promise<User> {
  const res = await fetch(`/api/users/${id}`, { signal });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return UserSchema.parse(await res.json());
}

async function render(id: string, signal?: AbortSignal) {
  try {
    const user = await fetchUser(id, signal); // thread it, don't drop it
    return userCard(user);
  } finally {
    clearTimeout(debounceTimer); // cleanup always runs
  }
}
```

## Distinguishing abort from error

```typescript
catch (e) {
  if (e instanceof Error && e.name === "AbortError") return neutralState();
  throw e; // real error — keep going up
}
```

## Anti-patterns
- Creating the AbortController deep inside the callee (the caller can never cancel)
- Dropping the signal at an intermediate layer ("this layer doesn't need it" — it passes through)
- Treating AbortError as a failure path (it's a "we changed our mind" path)
