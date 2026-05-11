## Type Definitions

> "Types are documentation that doesn't lie."

### Core Concept

TypeScript gives you several ways to describe a shape: `interface`, `type` aliases, classes, `enum`, and `as const`. Picking the right one and applying utility types correctly is the difference between a type that helps and a type that gets in the way.

### `interface` vs `type` alias

Modern guidance has converged: **use `type` aliases by default; reach for `interface` only when you need declaration merging**. The historical `interface`-for-objects / `type`-for-everything-else split is no longer load-bearing — `type` handles objects fine and composes with `&`, `|`, and conditional types in ways `interface` can't.

```typescript
// ✅ type alias — works for objects, unions, intersections, primitives
type User = {
  readonly id: string;
  name: string;
  email?: string;
};

type Status = "active" | "inactive";
type Admin = User & { role: "admin" };

// ✅ interface — when you genuinely need declaration merging (e.g., augmenting Express.Request)
declare global {
  namespace Express {
    interface Request {
      user?: User;
    }
  }
}
```

**Never prefix interfaces with `I`** (`IUser`, `IRepository`). It's a holdover from C# and conveys nothing the type system doesn't already know. Same with `T`-prefixed types.

### `readonly` for immutability

```typescript
// ❌ Caller can mutate this and break your invariants
type Config = {
  endpoints: string[];
  timeoutMs: number;
};

// ✅ Frozen at the type level
type Config = {
  readonly endpoints: readonly string[];
  readonly timeoutMs: number;
};
```

For deep readonly across nested objects, write a `DeepReadonly<T>` helper or wrap with `Object.freeze` and `as const`. `as const` on object/array literals gives you the most precise type possible (literal types, `readonly`).

### Utility types

The built-in utility types replace a lot of hand-written conditional types.

| Utility | Use |
|---------|-----|
| `Partial<T>` | All fields optional — patch types |
| `Required<T>` | All fields required |
| `Readonly<T>` | All fields `readonly` |
| `Pick<T, K>` | Subset by key |
| `Omit<T, K>` | All but listed keys |
| `Record<K, V>` | Object with known key set |
| `ReturnType<F>` | Inferred return type |
| `Parameters<F>` | Tuple of parameter types |
| `Awaited<P>` | Unwrap a `Promise` |
| `NonNullable<T>` | Strip `null`/`undefined` |

Prefer composition over redefinition: if `UserView` is "`User` minus `password`", write `Omit<User, "password">`, not a parallel type that drifts.

### Branded types for primitive obsession

```typescript
// ❌ Every string looks the same to the compiler
function getUser(id: string): User { ... }
getUser("not-an-id-at-all"); // typechecks, crashes

// ✅ Branded type: nominal-feeling distinction over the same runtime string
type UserId = string & { readonly __brand: "UserId" };

function userId(raw: string): UserId {
  if (!raw.match(/^u_[a-z0-9]{16}$/)) throw new Error("invalid UserId");
  return raw as UserId;
}

function getUser(id: UserId): User { ... }
getUser("not-an-id"); // compile error
```

Apply to IDs, currency amounts, validated email strings, etc.

### Avoid `Function`, `Object`, and `{}` as types

These types are nearly useless:
- `Function` — any callable, no parameter or return information.
- `Object` / `{}` — every non-null value.

Use the actual signature (`(a: number) => string`) or `object` (lowercase, means "non-primitive") if you really mean any object.

### Summary

1. **`type` alias by default**, `interface` only for declaration merging.
2. **No `I-` prefix** on interfaces.
3. **`readonly` and `as const`** for anything callers shouldn't mutate.
4. **Utility types over hand-rolled** — `Pick`/`Omit`/`Partial` keep types in sync.
5. **Branded types** for IDs and validated primitives.
6. **Never `Function`/`{}`/`Object`** — they're documentation, not constraints.
