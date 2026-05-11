## Type System Discipline

> "Make illegal states unrepresentable."
> — *Yaron Minsky*

### Core Concept

The type system is most useful when it **rules out invalid states at compile time** rather than nagging you about valid ones. Two habits unlock that: avoid `any`, and lean on discriminated unions + exhaustiveness checks so the compiler reminds you every time a new case appears.

### `any` vs `unknown`

`any` opts out of the type system locally; `unknown` opts you back in. Use `unknown` for genuinely dynamic input (JSON, `catch` clauses, third-party SDKs), then narrow with type guards before using.

```typescript
// ❌ any infects every downstream usage
function parse(raw: any) {
  return raw.user.name.toUpperCase(); // no compile-time safety
}

// ✅ unknown forces the caller to narrow
function parse(raw: unknown): string {
  if (
    typeof raw === "object" && raw !== null &&
    "user" in raw && typeof raw.user === "object" && raw.user !== null &&
    "name" in raw.user && typeof raw.user.name === "string"
  ) {
    return raw.user.name.toUpperCase();
  }
  throw new Error("invalid payload");
}

// ✅ Better: parse to a known schema (zod, valibot) and let it do the narrowing
import { z } from "zod";
const Payload = z.object({ user: z.object({ name: z.string() }) });
function parse(raw: unknown) {
  return Payload.parse(raw).user.name.toUpperCase();
}
```

### Discriminated unions + exhaustiveness

Model state as a union of tagged variants, then let the compiler enforce that every branch is handled.

```typescript
// ❌ Boolean flags compose into impossible states
type Request = {
  isLoading: boolean;
  data?: User;
  error?: Error;
};
// `{ isLoading: true, data: u, error: e }` is allowed but nonsensical

// ✅ Discriminated union — impossible states don't typecheck
type Request =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: User }
  | { status: "error"; error: Error };

function render(r: Request): string {
  switch (r.status) {
    case "idle":    return "—";
    case "loading": return "…";
    case "success": return r.data.name;
    case "error":   return r.error.message;
    default:        return assertNever(r); // adding a new variant becomes a compile error
  }
}

function assertNever(x: never): never {
  throw new Error(`unhandled variant: ${JSON.stringify(x)}`);
}
```

### Narrow with guards, not casts

```typescript
// ❌ Lying with a cast — no runtime check, breaks silently
const user = payload as User;
console.log(user.name);

// ✅ User-defined type guard — the runtime check IS the type narrowing
function isUser(x: unknown): x is User {
  return typeof x === "object" && x !== null && "id" in x && typeof x.id === "string";
}
if (isUser(payload)) {
  console.log(payload.name); // typed as User here
}
```

`as` and the non-null assertion `!` are escape hatches. Every use is a place the type system stops protecting you — treat them like `// type: ignore`.

### `readonly` by default for shared shapes

```typescript
// ❌ Mutable type leaks into call sites
function process(items: number[]): number { ... }

// ✅ Reader contract — caller knows we don't mutate
function process(items: readonly number[]): number { ... }
```

For object types, prefix fields with `readonly`. For deep immutability, use `Readonly<T>` or model with frozen objects.

### Summary

1. **`unknown` for dynamic input, never `any`.**
2. **Discriminated unions + `assertNever`** to make impossible states unrepresentable and adding cases a compile error.
3. **Type guards over `as`** — the runtime check and the type narrowing should be the same line.
4. **`readonly` array/property** on anything you don't intend the callee to mutate.
5. **Parse, don't validate** — a schema library (zod) turns `unknown` into a typed value at the boundary.
6. **`!` and `as` are smells** — every instance needs a comment justifying it.
