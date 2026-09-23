# Suppression Hygiene

## The rules
- `@ts-expect-error` only. Never `@ts-ignore`.
- Every suppression carries a reason and a link: `// @ts-expect-error -- TODO(#123) legacy payload shape, burn down in phase 2`
- `@ts-expect-error` (unlike ignore) fails the build once the underlying error is fixed — the compiler forces you to remove stale suppressions.

## The budget
Track the count; it only goes down:
```bash
grep -rc "@ts-expect-error" src | sort
```
- Report the number in every migration PR body.
- The count rising across PRs = the migration regressing; stop and reassess.

## Burn-down tactics
- Group by reason: `TODO(#123)` lines sharing an issue get fixed together.
- One suppression class per PR — batched fixes are reviewable; scattered ones aren't.
- When a flag-flip PR lands, re-check: some old suppressions become stale and must be deleted (the compiler enforces this for expect-error).

## The one legal cast pattern
```typescript
// migration seam: last point where the shape is unverified
const legacy = payload as unknown as LegacyShape; // TODO(#123) remove when
// cart-service emits the new schema
```
One cast, at the seam, with the reason. Never deeper, never unduplicated.