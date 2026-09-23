# Variance

## The one-paragraph version
Variance is how a type's subtyping propagates through its generic positions.
TS infers it structurally; you annotate (`in`/`out`) only when the compiler
demands it or when inference picks something unsound.

## Quick rules
- **Covariant (`out`)**: output positions — returns, readonly properties.
  `Producer<Cat>` is assignable to `Producer<Animal>`. Safe default.
- **Contravariant (`in`)**: input positions — parameters.
  `Consumer<Animal>` is assignable to `Consumer<Cat>`.
- **Invariant (`in out`)**: both directions — mutable properties, methods that
  read AND write `T`. The strictest; the source of most variance errors.

## Common pitfall: double variance in callbacks
```typescript
interface Bad<T> {
  run(cb: (value: T) => T): void; // T in both in- and out-position → invariant
}
```
Split the interface if you need covariance: `run(cb: (v: never) => T)` for
production, `(v: T) => void` for consumption.

## When to annotate
- Method-style declarations are bivariant by default (unsound but convenient);
  use function-property syntax for strict checking.
- Add `in`/`out` when the error message names variance — never to silence one.
