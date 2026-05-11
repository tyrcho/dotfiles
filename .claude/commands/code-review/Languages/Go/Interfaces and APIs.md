## Interfaces and APIs

> "Accept interfaces, return structs."
> — *Go proverb*

### Core Concept

Go interfaces are satisfied **structurally** — any type with the required method set qualifies, no `implements` keyword. This makes interfaces best when defined by the **consumer** of a behavior, not the producer. The package needing a `Get(ctx, id) (User, error)` declares its own small interface; the package supplying the implementation returns a concrete struct.

This decoupling is the single biggest API design lever Go gives you.

### Accept interfaces, return structs

```go
// ❌ Returns an interface — caller now stuck with that surface
func NewStore(db *sql.DB) UserStore { ... }

// ✅ Returns a struct — caller can use it directly, or wrap it in their own interface
func NewStore(db *sql.DB) *Store { ... }
```

Returning an interface forces every caller's mock to implement it. Returning the struct lets the caller decide whether they need an abstraction, and define one shaped to their needs.

### Define small interfaces at the consumer

```go
// ✅ Consumer declares only what it needs
package report

type userLookup interface {
    GetUser(ctx context.Context, id string) (*User, error)
}

func Build(ctx context.Context, l userLookup, id string) (*Report, error) {
    u, err := l.GetUser(ctx, id)
    ...
}
```

The producer (`users` package) returns `*Client` with a `GetUser` method. The consumer (`report`) doesn't import a `users.UserLookup` interface — it states the one method it needs. Tests pass an in-memory fake; production passes the real client.

This is interface segregation done right. Some standard-library examples (`io.Reader`, `io.Writer`, `fmt.Stringer`) are single-method on purpose.

### Function signatures: ordering rules

```go
func myFunc(ctx context.Context, param1 T1, param2 T2) (Result, error)
```

- **`ctx context.Context` is always the first parameter** when present.
- **`error` is always the last return value** when present.
- Other parameters: most general → most specific.

A function needs a `context.Context` if it makes a network/disk call, starts a trace/span, or calls another function that does. Inside tests, `context.Background()` (or `t.Context()` on Go 1.24+) is fine; in production, **carry** the incoming context — don't manufacture a new one.

#### Context values

`context.Value` is for **request-scoped, optional** data — trace IDs, deadlines, logger fields. It is **not** a hidden parameter channel. If your code needs the value to work correctly, it belongs in the function signature.

```go
// ❌ orgID is load-bearing; signature lies about what the function needs
func Process(ctx context.Context) error {
    orgID := ctx.Value("org_id").(string) // not optional
    ...
}

// ✅ Required data is an explicit argument
func Process(ctx context.Context, orgID string) error { ... }
```

### Long parameter lists → config struct or functional options

More than three positional parameters — especially same-typed booleans or strings — invite call-site mistakes that the compiler can't catch.

```go
// ❌ Two booleans of the same type can be swapped silently at the call site
func Crawl(ctx context.Context, orgID string, dryRun, parallel bool) error

// ✅ Config struct: named fields, self-documenting, easy to extend
type CrawlOptions struct {
    OrgID    string
    DryRun   bool
    Parallel bool
}
func Crawl(ctx context.Context, opts CrawlOptions) error

// ✅ Alternative: functional options (https://dave.cheney.net/2014/10/17/functional-options-for-friendly-apis)
type CrawlOption func(*crawlConfig)

func WithDryRun() CrawlOption     { return func(c *crawlConfig) { c.dryRun = true } }
func WithParallel() CrawlOption   { return func(c *crawlConfig) { c.parallel = true } }

func Crawl(ctx context.Context, orgID string, opts ...CrawlOption) error
```

Config structs work well when the set of options is stable. Functional options shine when most callers want defaults and only a few set a knob — they keep call sites short and additions non-breaking.

### Channel direction in signatures

When a function takes or returns a channel, name the direction:

- `chan<- T` — send-only (the function writes).
- `<-chan T` — receive-only (the function reads).

This is a documentation feature with compiler enforcement: it stops a caller from accidentally reading from a channel meant to be written to.

```go
// ✅ Producer signals "I write here; you read"
func Produce(out chan<- Item)

// ✅ Consumer signals "I read here; you write"
func Consume(in <-chan Item)
```

### Avoid getters/setters for plain data

Go is not Java. A struct field is part of the API; expose it. Only introduce a method when there's logic beyond reading or writing.

```go
// ❌ Pointless ceremony
func (u *User) GetName() string { return u.name }
func (u *User) SetName(n string) { u.name = n }

// ✅ Just expose the field
type User struct {
    Name string
}
```

Reach for accessors only when you need validation, lazy computation, or to maintain an invariant.

### Returning errors with values

When a function returns `(T, error)`, **only look at `T` after checking `err == nil`**. Some standard-library functions return partial results on error (e.g., `io.Reader`), but the convention for your own code is: error means the other return values are not meaningful.

### Summary

1. **Accept interfaces, return structs.**
2. **Define interfaces at the consumer**, sized to one job.
3. **`ctx` first, `error` last** — every time.
4. **`context.Value` for optional/contextual data only.** Required data goes in the signature.
5. **>3 params → config struct or functional options**, especially with multiple booleans.
6. **`chan<-` and `<-chan`** for documented direction.
7. **No getters/setters** for plain data — exported fields are fine.
