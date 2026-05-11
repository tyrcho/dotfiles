## Testing

> "A test that passes for the wrong reason gives you confidence you don't have."

### Core Concept

Go ships with everything you need: the `testing` package, `go test`, and the `-race` flag. Reach for `testify/assert` for readability when you want it — but **avoid `testify.Suite`**, which hides the natural flow of table-driven tests, doesn't run subtests in parallel, and breaks editor integrations. The standard library + light assertions is what production Go codebases run.

Three habits matter more than any framework choice:

1. **Table-driven tests** with `t.Run` and `t.Parallel`.
2. **Black-box** over white-box — test the public surface, not internal state.
3. **No live dependencies** — every external system is faked in tests.

### Table-driven tests

```go
func TestParseID(t *testing.T) {
    t.Parallel()

    tests := []struct {
        name    string
        input   string
        want    int64
        wantErr error
    }{
        {name: "valid",            input: "42",        want: 42},
        {name: "empty",            input: "",          wantErr: ErrEmpty},
        {name: "non-numeric",      input: "abc",       wantErr: strconv.ErrSyntax},
        {name: "leading space",    input: " 42",       wantErr: strconv.ErrSyntax},
    }

    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            t.Parallel()

            got, err := ParseID(tc.input)
            if !errors.Is(err, tc.wantErr) {
                t.Fatalf("err = %v, want %v", err, tc.wantErr)
            }
            if err == nil && got != tc.want {
                t.Errorf("got = %d, want %d", got, tc.want)
            }
        })
    }
}
```

Notes:

- **`t.Parallel()` inside each subtest** — without it, the subtests still serialize. With it, they run concurrently and surface races.
- **`t.Parallel()` at the top of the parent** — lets the whole `TestParseID` run in parallel with sibling tests.
- **Use a map** instead of a slice when the order doesn't matter — it makes duplicate names a compile-time-ish issue (Go maps reject duplicate keys silently at insertion, but linters can catch it).
- **Name cases by behavior**, not implementation: "non-numeric input" over "fails ParseInt".

### Black-box over white-box

Test what the caller sees, not what the implementation does. White-box tests that read private fields or call unexported functions break on every refactor — even refactors that preserve behavior.

```go
// ❌ White-box: peeking at internal state
func TestCache_Internal(t *testing.T) {
    c := NewCache()
    c.Put("a", 1)
    if c.store["a"] != 1 {        // private field
        t.Fatal("expected stored")
    }
}

// ✅ Black-box: through the public API
func TestCache(t *testing.T) {
    c := NewCache()
    c.Put("a", 1)
    got, ok := c.Get("a")
    if !ok || got != 1 {
        t.Fatalf("Get(a) = %v, %v; want 1, true", got, ok)
    }
}
```

Place tests in `package foo_test` (separate package) when you want the compiler to enforce black-box discipline — you can only see exported identifiers.

### No live dependencies in tests

Tests that hit real AWS / databases / network are:

- **Flaky** — they fail on credentials expiring, rate limits, network blips.
- **Slow** — every CI run pays the latency.
- **Hard to reason about** — failure modes leak from the dependency.

Replace external dependencies with in-memory fakes implementing the consumer-side interface (see Interfaces and APIs). A fake `UserStore` for tests is a few dozen lines and lives next to the test.

```go
type fakeUserStore struct {
    users map[string]User
}

func (f *fakeUserStore) GetUser(_ context.Context, id string) (User, error) {
    u, ok := f.users[id]
    if !ok {
        return User{}, ErrNotFound
    }
    return u, nil
}
```

For time-dependent code, inject a clock (`func() time.Time`) — never call `time.Now()` directly inside testable logic.

### Cover the unhappy path

When you add a new branch — a new metric, a new field, a new error condition — add a test for the failure path, not only the happy one. Reviewers will flag this; better to add it preemptively.

The minimum bar for new behavior:

- Happy path.
- One failure path per branch.
- Boundary cases (empty input, zero, nil).

### `t.Helper()` for shared assertions

When a helper calls `t.Fatal` / `t.Error`, mark it as a helper so the reported line number is the **caller's**, not the helper's:

```go
func mustParse(t *testing.T, s string) int64 {
    t.Helper()
    v, err := ParseID(s)
    if err != nil {
        t.Fatalf("parse %q: %v", s, err)
    }
    return v
}
```

### `testdata/` for fixtures

Go's `go test` ignores `testdata/` directories — use them for golden files, sample inputs, fixtures. Read with `os.ReadFile("testdata/...")`. For golden-file tests, support a `-update` flag so regenerating expected output is one command.

### Race detector

```bash
go test -race ./...
```

Run in CI, always. The race detector is slow (~10× and ~5× memory) — don't enable it in production binaries — but in tests it's the cheapest concurrency bug catch you'll ever get.

### Verify AI-generated tests

AI tools produce tests that **compile and pass** but assert against fabricated expected values — incorrect tag names, made-up enum values, plausible-but-wrong API responses. The test suite goes green; the behavior is wrong.

If a test was generated, verify the expected values against the actual API / spec / contract before merging. **A passing AI-generated test is not evidence of correctness.**

### Summary

1. **Table-driven with `t.Run` + `t.Parallel`** inside each subtest.
2. **Avoid `testify.Suite`** — use plain `testing` + optional `testify/assert`.
3. **Black-box from `package foo_test`** — test the public surface.
4. **No live dependencies** — fake every external system; inject the clock.
5. **Cover the unhappy path** alongside the happy one.
6. **`t.Helper()`** in shared assertion helpers.
7. **`testdata/`** for fixtures; support a `-update` flag for goldens.
8. **`go test -race ./...` in CI.**
9. **Verify AI-generated expected values** against the real contract before trusting a green test.
