# Validation Patterns

## Parse, don't validate

```typescript
import { z } from "zod";

const UserSchema = z.object({
  id: z.string().uuid().brand<"UserId">(),
  email: z.string().email(),
  role: z.enum(["admin", "member"]),
});
type User = z.infer<typeof UserSchema>;

async function getUser(url: string): Promise<User> {
  const res = await fetch(url);
  const body: unknown = await res.json();     // unknown at the edge
  return UserSchema.parse(body);              // User or throws — never a lie
}
```

## User input vs internal invariant

```typescript
// User input: accumulate, display
const result = UserSchema.safeParse(body);
if (!result.success) {
  return { status: 422, errors: result.error.flatten().fieldErrors };
}

// Internal invariant: fail fast
function must<T>(schema: z.ZodType<T>, value: unknown): T {
  return schema.parse(value);
}
```

## Config at startup

```typescript
const ConfigSchema = z.object({
  port: z.coerce.number().default(3000),
  dbUrl: z.string().url(),
  isProd: z.coerce.boolean().default(false),
});
export const config = ConfigSchema.parse(process.env);
// app code imports { config } and never touches process.env again
```

## Branded IDs through schemas

```typescript
const UserIdSchema = z.string().uuid().brand<"UserId">();
type UserId = z.infer<typeof UserIdSchema>;
const toUser = (id: UserId) => ...;
toUser("not-a-uuid")        // compile error
toUser(someOrderId)         // compile error — OrderId ≠ UserId
```

## Recursion note
One parse per boundary crossing. Re-parsing inside functions that received
already-typed arguments means the boundary is in the wrong place — move it
to the actual edge.
