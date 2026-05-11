## Naming and Style

> "There are only two hard things in computer science: cache invalidation and naming things."
> — *Phil Karlton*

### Core Concept

TypeScript inherits JavaScript's naming conventions and adds a few of its own for types. The widely-followed convention — codified in the [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html) and the TypeScript Handbook — is consistent enough across the ecosystem that you should not invent your own variant. Use Prettier + ESLint with `@typescript-eslint` to enforce mechanically.

### Identifier conventions

| Element | Convention | Example |
|---------|------------|---------|
| Variable, function, method, parameter | `lowerCamelCase` | `userCount`, `parsePayload()` |
| Class, interface, type alias, enum, type parameter | `UpperCamelCase` | `UserRepository`, `Payload`, `T`, `TKey` |
| Module-level constant whose value is fundamental | `UPPER_SNAKE_CASE` | `MAX_RETRIES`, `API_VERSION` |
| Module-level constant otherwise | `lowerCamelCase` | `defaultTimeoutMs = 5_000` |
| Private (truly internal) | `#privateField` (class field) or just no `export` | `#cache` |
| Boolean variable / function | verb prefix: `is`, `has`, `can`, `should` | `isReady`, `hasAccess`, `canEdit` |
| File | `kebab-case.ts` or `lowerCamelCase.ts` — pick one project-wide | `user-repository.ts` |

**Don't**:

- **`I`-prefix on interfaces** (`IUser`) — C# holdover, no value.
- **`T`-prefix on type aliases** (`TUser`) — except for generic parameters, where `T`/`K`/`V` are conventional.
- **`_`-suffix or `_`-prefix on private fields** — use ECMAScript private fields (`#field`) inside classes, or just don't export at module level.
- **Hungarian notation** (`strName`, `arrItems`). The type system already tells you the type.
- **All-caps for everything `const`**. Reserve `UPPER_SNAKE_CASE` for genuine constants that are part of the public API (limits, magic numbers); use `lowerCamelCase` for ordinary `const`-bound values.

### Avoid abbreviations

Local loop counters (`i`, `j`) and well-known acronyms (`url`, `id`, `http`) are fine. Beyond those, write out the word. Future readers will spend more time guessing what `mgr`, `usrSvc`, or `attrs` means than you'll save typing.

Acronym casing: treat them as words. `parseHttpRequest`, `userId`, `apiKey` — not `parseHTTPRequest`, `userID`, `APIKey`. Consistency with surrounding code wins if the codebase has chosen a different rule.

### File and module layout

```typescript
// 1. Type-only imports first (the compiler can elide them)
import type { User } from "./types";

// 2. Runtime imports, grouped: std → third-party → local
import { readFile } from "node:fs/promises";

import { z } from "zod";

import { logger } from "./logger";

// 3. Constants and types this module owns
const DEFAULT_TIMEOUT_MS = 5_000;

type Result = { ok: true; user: User } | { ok: false; error: string };

// 4. Exported functions
export async function loadUser(id: string): Promise<Result> { ... }

// 5. Internal helpers below their first caller
function parseUser(raw: unknown): User { ... }
```

### Imports

- Use **named exports** for everything except top-level entry points. Default exports rename inconsistently across call sites and confuse tooling.
- Use `import type { ... }` for type-only imports — it survives `isolatedModules` and tree-shakes cleanly.
- No deep relative imports if the project uses path aliases (`@/users/...` over `../../../users/...`).
- No `import * as something` unless the namespace genuinely groups exports.

### Summary

1. **`lowerCamelCase` for values**, **`UpperCamelCase` for types**.
2. **No `I-` on interfaces, no `T-` on type aliases**, no Hungarian.
3. **Boolean prefixes**: `is`, `has`, `can`, `should`.
4. **Write out abbreviations** — `i`, `id`, `url` are fine; `mgr`, `attrs`, `usrSvc` are not.
5. **Named exports** over default exports.
6. **`import type`** for type-only imports.
7. **Enforce with Prettier + ESLint** — style should never be a review comment.
