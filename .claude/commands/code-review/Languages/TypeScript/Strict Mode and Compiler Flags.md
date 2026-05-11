## Strict Mode and Compiler Flags

> "TypeScript without `strict: true` is a more annoying way to write JavaScript."

### Core Concept

TypeScript's safety is opt-in. Without `strict`, the compiler infers `any` everywhere it can't figure out the type — which silently undoes the entire reason for using TypeScript. **`strict: true` is the baseline**, not a stretch goal. In 2026 there is no excuse for shipping a new project without it.

`strict` is an umbrella that turns on eight flags. A few extra flags beyond `strict` are worth knowing.

### What `strict: true` enables

| Flag | Catches |
|------|---------|
| `noImplicitAny` | Variables/params whose type can't be inferred |
| `strictNullChecks` | `null`/`undefined` flowing into non-nullable slots |
| `strictFunctionTypes` | Unsound parameter variance in callback types |
| `strictBindCallApply` | `.bind/call/apply` with wrong argument types |
| `strictPropertyInitialization` | Class fields not initialised in the constructor |
| `noImplicitThis` | `this` of inferred `any` type |
| `useUnknownInCatchVariables` | `catch (e)` typed as `unknown`, not `any` |
| `alwaysStrict` | Emits `"use strict"` |

### Flags worth adding on top of `strict`

```jsonc
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,   // arr[i] is T | undefined
    "exactOptionalPropertyTypes": true, // {x?: T} disallows {x: undefined}
    "noImplicitOverride": true,         // require `override` keyword
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "bundler",      // for Vite/Next/Webpack
    "skipLibCheck": true
  }
}
```

`noUncheckedIndexedAccess` is the biggest practical win after `strict` — it forces you to handle the case where an index lookup returns nothing.

### Anti-Patterns

```typescript
// ❌ Without strictNullChecks, this compiles and crashes at runtime
function greet(user: { name: string } | null) {
  return `hello ${user.name}`; // user could be null
}

// ✅ With strictNullChecks, the compiler forces the check
function greet(user: { name: string } | null) {
  if (user === null) return "hello anonymous";
  return `hello ${user.name}`;
}
```

```typescript
// ❌ Without noUncheckedIndexedAccess, looks safe but isn't
const users: User[] = loadUsers();
const first = users[0];      // typed as User
console.log(first.name);     // crash if list is empty

// ✅ With noUncheckedIndexedAccess, the type tells the truth
const first = users[0];      // User | undefined
console.log(first?.name);    // optional chain or guard
```

### Migrating an existing project

Don't flip every flag in one PR. Sequence:

1. Turn on `strict: true` with `// @ts-expect-error` shims where needed.
2. Burn down the shims one PR at a time, scoped by directory or feature.
3. Then add `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`. These usually surface real bugs.

Never use `// @ts-ignore` — it suppresses errors silently when the underlying code changes. Use `// @ts-expect-error` so the suppression itself becomes an error once the bug is gone.

### Summary

1. **`strict: true` is the floor**, not a goal.
2. **Add `noUncheckedIndexedAccess`** — index access into arrays/records is genuinely partial.
3. **`useUnknownInCatchVariables`** (in `strict`) — narrow caught errors deliberately.
4. **`@ts-expect-error`, never `@ts-ignore`** — make stale suppressions fail loudly.
5. **Migrate flag-by-flag**, not all at once.
6. **Pin the config** in CI and refuse PRs that downgrade it.
