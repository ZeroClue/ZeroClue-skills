# API Surface

## Hyrum's Law
With enough users, it does not matter what your contract says: everything observable will be depended on by somebody. Every export, every inferred type in a public position, every incidental behavior is load-bearing for someone.

## Export minimalism checklist
- [ ] Every export has a current, named caller (not a hypothetical one)
- [ ] No re-export of internals "for convenience"
- [ ] Types exported separately from implementations where callers need them (`export type { User }` — and only when callers need it)
- [ ] Default exports avoided in libraries (named exports refactor safely)

## Contracts are written
```typescript
// internal: inference is fine
const formatInternal = (u: User) => `${u.name}`;

// public: explicit types, always
export function formatUser(user: User): string {
  return `${user.name}`;
}
```
Public return types are documentation that can't rot: the compiler enforces them at every call site and every downstream type-check.

## Breaking-change discipline
- Adding: fine. Widening input: fine. Narrowing return: fine.
- Removing, narrowing input, widening return: breaking — version major and migrate, or don't do it.
- Deprecation: mark, alias, migrate, remove — in that order, with a timeline.