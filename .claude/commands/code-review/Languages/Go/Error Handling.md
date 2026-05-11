## Error Handling

> "Errors are values."
> — *Rob Pike*

### Core Concept

Go has no exceptions. Errors flow back through return values, and the only way to lose them is to ignore them. Three principles cover almost everything:

1. **Handle, chain, or propagate** — in that order of preference.
2. **Wrap with `%w`** when you add context; never `%v`.
3. **Don't `panic`** — ever — for normal error flow.

### Handle, chain, or propagate

When you receive an error, ask in order:

1. **Can I handle it here?** (e.g. `errors.Is(err, ErrUnauthenticated)` → return HTTP 401 and stop)
2. **Can I add useful context?** Wrap with `fmt.Errorf("verb noun: %w", err)` and return.
3. **Otherwise, propagate as-is** — `return err`.

```go
// ✅ Handled
if errors.Is(err, ErrUnauthenticated) {
    http.Error(w, "Unauthorized", http.StatusUnauthorized)
    return
}

// ✅ Chained with context
return fmt.Errorf("get user %s: %w", id, err)

// ✅ Propagated unchanged (nothing useful to add)
return err
```

### Wrap with `%w`, never `%v`

`%w` keeps the original error chain so `errors.Is` and `errors.As` still work upstream. `%v` silently turns the wrapped error into a plain string — the chain is gone.

```go
// ❌ Looks fine; quietly breaks errors.Is downstream
return fmt.Errorf("get user: %v", err)

// ✅ Preserves the chain
return fmt.Errorf("get user: %w", err)
```

Verify with `errors.Is(err, target)` and `errors.As(err, &target)` at the consumer end. Don't compare with `==` except for sentinel errors that are guaranteed not to be wrapped.

### Wrapping convention: verb-noun prefix

Prefix wraps with `"verb noun"` — short, lowercase, no "failed to" or "error while". The verb names what was attempted; the noun names the object. Wrap at **every site that adds context**, not only at the top.

```go
// ❌ Noise that adds nothing
return fmt.Errorf("failed to parse user id: %w", err)
return fmt.Errorf("an error occurred while getting user: %w", err)

// ✅ Searchable, concise
return fmt.Errorf("parse user id: %w", err)
return fmt.Errorf("get user: %w", err)
```

When wrapped at each return site, an upstream log looks like:

```
handle request: get user 42: query users: scan row: invalid syntax
```

That trail is the stack trace Go doesn't otherwise give you.

### Conventions for error messages

- **Lowercase**, no trailing punctuation: `errors.New("not found")`, not `errors.New("Not found.")`.
- **No "failed to" / "error while"** — it's already an error.
- **Include relevant value content** (`"parse line %q: %w"` with the literal being parsed).
- **Don't echo input parameters** the caller already has — they'll add it if needed. Exception: inside loops, where the caller can't tell which iteration failed.
- **At service boundaries** (HTTP, RPC), translate internal errors into safe public messages. Don't leak stack traces or internal table names to clients.

### Sentinel errors

```go
var (
    ErrNotFound      = errors.New("not found")
    ErrUnauthorized  = errors.New("unauthorized")
)

if errors.Is(err, ErrNotFound) { ... }
```

Define sentinels in the package that owns them; export only if callers need to test for them. For richer comparison (status code, retryable?), use a custom type and `errors.As`.

### Never panic for control flow

`panic` aborts the entire process, not just the current goroutine's task. It is reserved for **truly unrecoverable** situations — initialization failures in `main`, programmer-error invariants in libraries (and only when the library makes that contract explicit).

Anywhere else, return an error.

```go
// ❌ Crashes the whole service if the config is bad at runtime
if config == nil {
    panic("config is required")
}

// ✅ Caller decides what to do
if config == nil {
    return fmt.Errorf("new client: %w", ErrConfigRequired)
}
```

### `recover` in goroutines

A `panic` in a goroutine kills the whole process unless caught by a `recover` inside that goroutine. The function that **starts** a goroutine is responsible for the `recover`. There is no parent goroutine to catch for you.

```go
go func() {
    defer func() {
        if r := recover(); r != nil {
            log.Error("worker panicked", "recover", r, "stack", debug.Stack())
        }
    }()
    work()
}()
```

`recover` is a safety net, not a control-flow tool. The error model handles every normal case.

### Don't discard errors

```go
// ❌ Silent failure
result, _ := someCall()

// ✅ Even if you can't recover, at least log
result, err := someCall()
if err != nil {
    log.Warn("some call failed", "err", err)
}
```

The only legitimate `_` for an error is when the API forces it (e.g., `defer f.Close()` and you genuinely can't act on a close failure — though you should usually log it).

### Summary

1. **Handle → chain → propagate**, in that order.
2. **`%w` not `%v`** when wrapping — preserves the error chain.
3. **Verb-noun prefix**, lowercase, no "failed to".
4. **Never `panic` for normal errors.** `recover` is a safety net inside the goroutine that started it.
5. **Use `errors.Is` / `errors.As`** — never `err == sentinel` on potentially-wrapped errors.
6. **Translate at service boundaries** — don't leak internal errors to clients.
7. **Never `_` an error** — at minimum, log it.
