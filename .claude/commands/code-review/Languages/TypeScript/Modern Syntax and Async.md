## Modern Syntax and Async

> "Code is read more often than it is written."
> — *Guido van Rossum* (applies in any language)

### Core Concept

Modern TypeScript runtimes (Node 20+, current browsers, Bun, Deno) support ES2022+ syntax natively. A lot of the patterns from 2018-era tutorials — Promise chains, manual `null` checks, `var`, `require`, IIFEs — are no longer pulling their weight. Use the modern feature when it makes the code shorter without making it more clever.

### `async`/`await` over `.then()` chains

```typescript
// ❌ Promise chains: error handling scattered, intermediate values awkward
function loadUser(id: string): Promise<UserView> {
  return fetchUser(id)
    .then(user => fetchProfile(user.id).then(profile => ({ user, profile })))
    .then(({ user, profile }) => render(user, profile))
    .catch(err => { log.error(err); throw err; });
}

// ✅ Linear control flow, native try/catch
async function loadUser(id: string): Promise<UserView> {
  try {
    const user = await fetchUser(id);
    const profile = await fetchProfile(user.id);
    return render(user, profile);
  } catch (err) {
    log.error(err);
    throw err;
  }
}
```

**Run independent awaits in parallel.** Sequential `await`s waste latency when the operations don't depend on each other:

```typescript
// ❌ Serial: total time = fetchUser + fetchOrders
const user = await fetchUser(id);
const orders = await fetchOrders(id);

// ✅ Parallel: total time = max(fetchUser, fetchOrders)
const [user, orders] = await Promise.all([fetchUser(id), fetchOrders(id)]);
```

For partial-failure tolerance use `Promise.allSettled`. For racing, `Promise.race` / `Promise.any`.

### Optional chaining and nullish coalescing

```typescript
// ❌ Defensive ladders
const city = user && user.address && user.address.city ? user.address.city : "unknown";

// ✅ Optional chaining + nullish coalescing
const city = user?.address?.city ?? "unknown";
```

Use `??` (nullish coalescing), **not `||`**, for defaults — `||` treats `0`, `""`, and `false` as missing.

```typescript
// ❌ Bug: count=0 becomes 10
const count = config.count || 10;

// ✅ Only null/undefined trigger the fallback
const count = config.count ?? 10;
```

### Modules

ESM (`import`/`export`) is the modern target. CommonJS (`require`/`module.exports`) is for legacy interop. Set `"type": "module"` in `package.json` and `"module": "ESNext"` (or `"NodeNext"`) in `tsconfig`. Avoid default exports for anything beyond top-level entry points — named exports rename cleanly and tools refactor them safely.

### Avoid `var`, `enum`, and `namespace`

- **`var`** — function-scoped, hoisted, and dead. Use `const` by default, `let` when reassignment is real.
- **`enum`** — runtime baggage and weak typing. Prefer string-literal unions or `as const` objects.
- **`namespace`** — pre-ESM module system. Use ES modules.

```typescript
// ❌ enum: runtime object, loose comparison, can't tree-shake
enum Status { Active = "active", Inactive = "inactive" }

// ✅ Literal union: zero runtime cost, exhaustive, tree-shakable
type Status = "active" | "inactive";
const STATUSES = ["active", "inactive"] as const;
```

### Iteration

`for...of` over arrays, `for...of Object.entries(...)` over records, `.map`/`.filter`/`.reduce` for transforms. Avoid `for...in` on arrays (iterates inherited keys).

### Summary

1. **`async`/`await` over `.then`**; **`Promise.all`** for independent operations.
2. **`?.` and `??`** replace defensive ladders — `??` not `||` for defaults.
3. **ESM by default**, named exports over default exports.
4. **`const` by default**, `let` only when reassignment is real; `var` is dead.
5. **String-literal unions over `enum`**.
6. **`for...of` for arrays**, never `for...in`.
