# Pattern Library

## State machines: discriminated unions

```typescript
type FetchState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: Error };
```
Impossible states ("loading with data") are unrepresentable. This is the
default way to model any multi-state domain, not an advanced technique.

## Exhaustive switch

```typescript
function render(state: FetchState<User>) {
  switch (state.status) {
    case "idle": return idleView();
    case "loading": return spinner();
    case "success": return userCard(state.data);
    case "error": return errorView(state.error);
    default: {
      const _exhaustive: never = state;
      throw new Error(`Unhandled: ${JSON.stringify(_exhaustive)}`);
    }
  }
}
```
Adding a variant later breaks every non-updated switch at compile time.

## satisfies over as

```typescript
const routes = {
  home: { path: "/", auth: false },
  admin: { path: "/admin", auth: true },
} satisfies Record<string, { path: string; auth: boolean }>;
// routes.admin.path stays narrowed to "/admin" — literal inference preserved
```
`satisfies` checks the contract and keeps narrow types. `as` checks nothing
and widens.

## Literal unions + as const

```typescript
type LogLevel = "debug" | "info" | "warn" | "error";

const LOG_LEVELS = ["debug", "info", "warn", "error"] as const;
type LogLevel = (typeof LOG_LEVELS)[number]; // single source of truth
```
Runtime list and compile-time union derived from one declaration.

## Keyed data

```typescript
const usersById: Record<string, User> = {};
const pair: [id: string, name: string] = [id, name];
```

## Narrowing idioms

```typescript
// Type guard
const isUser = (v: unknown): v is User =>
  typeof v === "object" && v !== null && "id" in v && "name" in v;

// Narrow to union member
if ("error" in result) { ... }

// discriminate on a literal
if (state.status === "success") { state.data /* T */ }
```

## Branded primitives (see type-level skill for depth)

```typescript
type UserId = string & { readonly __brand: "UserId" };
declare function getUser(id: UserId): User;
// getUser("abc") is a compile error — plain strings can't impersonate IDs
```

## Nullish orchestration

```typescript
const name = user?.profile?.displayName ?? "Anonymous";
const port = config.port ?? 3000; // not || — port 0 is valid
```
