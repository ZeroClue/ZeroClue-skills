# Type Recipes

## Derived types (one source of truth)

```typescript
const CONFIG = { host: "localhost", port: 8080, retries: 3 } as const;
type Config = typeof CONFIG;
type ConfigKey = keyof typeof CONFIG;
const LEVELS = ["debug", "info", "warn"] as const;
type Level = (typeof LEVELS)[number];
```

## Utility wrappers

```typescript
type Prettify<T> = { [K in keyof T]: T[K] } & {};        // flatten inferred types for display
type DeepReadonly<T> = T extends (infer U)[]
  ? readonly DeepReadonly<U>[]
  : T extends object ? { readonly [K in keyof T]: DeepReadonly<T[K]> }
  : T;
type DeepPartial<T> = T extends object ? { [K in keyof T]?: DeepPartial<T[K]> } : T;
```

## Template literal types

```typescript
type Route = `/${string}`;
type EnvKey = `VITE_${Uppercase<string>}`;
type EventName = `on${Capitalize<K>}`;
```

## Constrained generics

```typescript
function get<T, K extends keyof T>(obj: T, key: K): T[K] { return obj[key]; }
function merge<A extends object, B extends object>(a: A, b: B): A & B { return { ...a, ...b }; }
```

## infer in conditional position

```typescript
type ElementOf<T> = T extends (infer U)[] ? U : never;
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;
```

## Branded primitives

```typescript
declare const brand: unique symbol;
type Brand<T, B> = T & { readonly [brand]: B };
type UserId = Brand<string, "UserId">;
type OrderId = Brand<string, "OrderId">;
function getUser(id: UserId): User { ... }
// getUser(orderId) — compile error even though both are string
```
