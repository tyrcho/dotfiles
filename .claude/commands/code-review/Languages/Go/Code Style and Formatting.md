## Code Style and Formatting

> "Gofmt's style is no one's favorite, yet gofmt is everyone's favorite."
> — *Rob Pike*

### Core Concept

Go enforces style mechanically — `gofmt` (or `gofumpt`) + `goimports` settle every formatting debate. Code review should focus on naming, layout, and intent, not whitespace. Run the formatters on save; if a reviewer is asking about brace placement, something is wrong with the toolchain, not the code.

The deeper conventions come from [Effective Go](https://go.dev/doc/effective_go) and the [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments). The standard library is the reference codebase — when in doubt, look at `strings`, `time`, or `net/http`.

### Tooling

- **`gofumpt`** — superset of `gofmt`, applies more simplifications.
- **`goimports`** — sorts/groups imports automatically.
- **`go vet`** — built-in correctness checks.
- **`staticcheck`** — additional lints; run in CI.

Run with `-race` during tests to surface data races (see Concurrency).

### Naming

| Element | Convention | Example |
|---------|------------|---------|
| Exported (public) identifier | `UpperCamelCase` | `NewClient`, `MaxRetries`, `UserID` |
| Unexported (package-local) | `lowerCamelCase` | `parseURL`, `defaultTimeout` |
| Receiver | 1–2 letter abbreviation of the type | `c *Client`, `u User` |
| Acronyms | Same case throughout | `userID` not `userId`; `parseHTTPRequest` not `parseHttpRequest` |
| Package | short, all-lowercase, no underscores | `time`, `http`, `useragent` |
| Interface for one method | method name + `-er` | `Reader`, `Stringer`, `Closer` |

Name expressiveness is **caller-relative**. A `Reader` inside package `content` is invoked as `content.Reader` — no need to repeat the package in the type name. `contentreader.ContentReader` is redundant.

Receiver names are consistent across all methods of a type: pick one (`c` for `Client`) and use it everywhere. Don't mix `c`, `client`, and `self`.

### Variable declaration

```go
// ✅ Zero value: use var
var name string
var count int

// ✅ Initialized: use :=
name := "alice"
count := 42

// ❌ Don't pretend you're initializing when you want zero value
name := ""   // misleading — looks like a deliberate empty string
count := 0   // ditto
```

Same applies to slices and maps:

```go
// ✅ Nil slice — readable, writable via append, no allocation
var tags []string

// ✅ Pre-allocated when length is known
result := make([]Item, 0, len(src))

// ✅ Map with capacity hint when known
cache := make(map[string]string, 100)

// ❌ Empty slice via literal — allocates, hides intent
tags := []string{}

// ❌ make with len=0 and no cap
tags := make([]string, 0)
```

Pre-allocating `make([]T, 0, len(src))` when copying or transforming a known-size source avoids reallocation overhead in hot paths. If the final size is unknown or the math is non-obvious, plain `var result []T` is clearer than a wrong pre-allocation.

### Magic strings → named constants

Any string literal that encodes a domain concept — permission name, auth scope, resource type, feature flag, error code — belongs in a `const`. The rule: **if you'd need to look up the string to understand what it means, it needs a name.**

```go
// ❌ Typo silently fails auth
if user.Scope == "https://www.googleapis.com/auth/cloud-platform" { ... }

// ✅ Compiler catches typos at every call site
const authScopeCloudPlatform = "https://www.googleapis.com/auth/cloud-platform"

if user.Scope == authScopeCloudPlatform { ... }
```

Prefer string-typed constants over `iota` when the value appears in logs or errors — a string prints its name, an int prints a number that requires a lookup.

**Sort `const` and `var` blocks alphabetically.** It makes duplicates obvious and keeps diffs minimal. This is especially important after AI-generated code, which often inserts in arbitrary order.

### File layout

A Go file reads top-down, general to specific:

```go
package business

import (
    // stdlib group
    "context"
    "fmt"

    // third-party group
    "github.com/example/foo"

    // local group
    "github.com/myorg/myrepo/internal/util"
)

const (
    DefaultRetries = 3
    DefaultTimeout = 30 * time.Second
)

var (
    ErrNotFound = errors.New("not found")
)

// Types and their methods, grouped together
type Client struct { ... }

func NewClient(...) *Client { ... }
func (c *Client) Get(ctx context.Context, id string) (*Item, error) { ... }

// Exported package-level functions
func Process(ctx context.Context, c *Client) error { ... }

// Unexported helpers last
func parseHeader(s string) (string, error) { ... }
```

Split files by intent (`client.go`, `errors.go`, `constants.go`) when one file grows past a screen or two. There's no overhead — files in the same package share scope.

### Doc comments

Every exported name needs a doc comment that **starts with the name** and is a complete sentence:

```go
// ❌ Doesn't help godoc
// returns the user

// ✅ Reads naturally in godoc output
// GetUser returns the user with the given id, or ErrNotFound if no such user exists.
func GetUser(ctx context.Context, id string) (*User, error)
```

Unexported names get comments when their purpose isn't obvious from the signature.

### Summary

1. **`gofumpt` + `goimports` on save** — style is not a review topic.
2. **`var` for zero values, `:=` for initialization** — don't mix the two.
3. **`make([]T, 0, n)` when length known**; `var s []T` when unknown.
4. **Domain strings → named constants**; alphabetical `const`/`var` blocks.
5. **Acronyms stay one case**: `userID`, `parseHTTPRequest`.
6. **Receivers: 1–2 letters, consistent across methods.**
7. **Doc comments start with the identifier**, full sentence.
