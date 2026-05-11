## Concurrency

> "Do not communicate by sharing memory; instead, share memory by communicating."
> — *Go proverb*

### Core Concept

Go gives you goroutines (cheap concurrency), channels (typed message passing), `sync` primitives (mutexes, wait groups), and `context` (cancellation + deadlines). Most concurrency bugs come from either sharing memory without protection, or holding locks for too long. The Go answer is to **pass ownership through channels** whenever you can, and use mutexes only when the data is genuinely shared state that multiple goroutines must update.

Run tests with `-race` (`go test -race ./...`) to catch data races. The race detector is the single highest-value tool in this area; turn it on in CI.

### Channels over mutexes

```go
// ❌ Shared map guarded by a mutex — every read/write needs a lock
type Counter struct {
    mu    sync.Mutex
    total map[string]int
}

func (c *Counter) Add(key string, n int) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.total[key] += n
}

// ✅ Single owner goroutine; updates arrive on a channel — no locks
type update struct{ key string; n int }

func runCounter(ctx context.Context, in <-chan update) map[string]int {
    total := map[string]int{}
    for {
        select {
        case <-ctx.Done():
            return total
        case u := <-in:
            total[u.key] += u.n
        }
    }
}
```

The owning-goroutine pattern eliminates the mutex by design: only one goroutine touches the data, so there's nothing to race. Mutexes are still the right tool when the data is read-heavy or the lifetime doesn't fit a single goroutine — but reach for them second, not first.

### Mutex discipline

When you do need a mutex:

```go
// ✅ Lock, defer Unlock on the next line, do the work
func (c *Cache) Put(key, value string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.store[key] = value
}
```

Rules:

- **`defer Unlock()` on the line after `Lock()`.** Guarantees release even on panic.
- **Hold the lock for as short a window as possible.** If you're about to do I/O or expensive computation, release first, work, then re-acquire to commit the result.
- **`sync.RWMutex`** for read-heavy paths — multiple readers can hold the read lock simultaneously.
- **Don't `defer` inside a loop** — defers fire when the surrounding function returns, not at the end of the iteration. Use an explicit `Unlock()` or move the locked section into a helper.

### Beware `defer` in loops

```go
// ❌ Locks accumulate; only released when the outer function exits
for _, key := range keys {
    c.mu.Lock()
    defer c.mu.Unlock()  // not what you want
    process(c.store[key])
}

// ✅ Scope each iteration in a function
for _, key := range keys {
    func() {
        c.mu.Lock()
        defer c.mu.Unlock()
        process(c.store[key])
    }()
}
```

### Context for cancellation

Long-running goroutines should accept a `context.Context` and respect cancellation. A goroutine that doesn't watch `ctx.Done()` is a leak waiting to happen.

```go
// ✅ Cancellable
func worker(ctx context.Context, in <-chan Job) {
    for {
        select {
        case <-ctx.Done():
            return
        case job := <-in:
            handle(ctx, job)
        }
    }
}
```

For background work spun off from a request: don't pass the request's `ctx` (it'll cancel when the request returns). Use `context.WithoutCancel(parent)` (Go 1.21+) to keep tracing/logging context but shed cancellation, then add a fresh deadline if needed.

### Each goroutine needs its own `recover`

A panic in one goroutine kills the whole process unless that goroutine has its own `recover`. There is no parent goroutine to catch for you. **The function that starts a goroutine is responsible.**

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

If you spawn many goroutines (a worker pool, a fan-out), wrap the recover in a small helper rather than repeating it.

### `WaitGroup` over manual coordination

```go
// ✅ Wait for fan-out workers to finish
var wg sync.WaitGroup
for _, item := range items {
    wg.Add(1)
    go func(item Item) {
        defer wg.Done()
        process(item)
    }(item)
}
wg.Wait()
```

Capture loop variables explicitly (`go func(item Item)`) or use Go 1.22+ where loop variables are per-iteration by default. Forgetting this is the classic "all goroutines see the last value" bug.

For bounded parallelism, prefer `errgroup.Group` from `golang.org/x/sync/errgroup` — it ties together cancellation, error propagation, and waiting in one type.

### Slice `append` is not goroutine-safe — and is tricky even single-threaded

```go
// ❌ Subtle: append may or may not share the backing array depending on cap
func observe(tags []string) {
    client.Incr("ok",  append(tags, "good"))
    client.Incr("bad", append(tags, "bad"))   // can clobber the previous "good"
}

// ✅ Force a new backing array
client.Incr("ok",  append([]string{"good"}, tags...))
client.Incr("bad", append([]string{"bad"},  tags...))
```

`append` reuses the underlying array when capacity allows. If a callee retains the slice (a queued metric, a goroutine), the next `append` to the same base mutates it. When in doubt, copy.

### Summary

1. **Prefer channels over mutexes** — share by communicating.
2. **Run tests with `-race`** in CI; pair with `t.Parallel()` in each subtest.
3. **`defer mu.Unlock()` on the line after `Lock()`.** Hold for the shortest possible scope.
4. **`RWMutex` for read-heavy** paths.
5. **No `defer` inside a loop** — wrap iterations in a helper function.
6. **Goroutines respect `context`** — every long-running one selects on `ctx.Done()`.
7. **Each goroutine has its own `recover`** — the starter is responsible.
8. **Force a fresh backing array** when appending in fan-out / observability code.
