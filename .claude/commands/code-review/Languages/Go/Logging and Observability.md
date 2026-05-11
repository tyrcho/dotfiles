## Logging and Observability

> "Logs are data, not prose."

### Core Concept

Logs exist to be **queried**, not read top to bottom. Three rules make that possible:

1. **Static message string.** Variable data goes in structured fields, not embedded with `%s`.
2. **Use the context-attached logger.** Request-scoped fields (org ID, trace ID, region) propagate automatically; the package-level logger drops them.
3. **Typed field values.** Pass numbers as numbers, errors via the error helper — don't pre-stringify.

`log/slog` is the modern standard-library answer (Go 1.21+). Most internal frameworks (Datadog `observability`, zap, zerolog) follow the same shape: `(message, key, value, key, value, ...)` or `(message, slog.Attr…)`.

### Static message, fields for data

The message string is the **searchable identifier**. Putting variable data in it means you can no longer pivot, alert, or aggregate.

```go
// ❌ Untraceable — every log line is unique, queries can't group them
log.Warnf("thing failed for org %s: %v", orgID, err)

// ✅ Message stays constant; org_id is a queryable field
log.Warn("thing failed",
    "org_id", orgID,
    "err",    err,
)
```

With `slog`:

```go
slog.WarnContext(ctx, "thing failed",
    slog.String("org_id", orgID),
    slog.Any("err", err),
)
```

In Log Management, `message:"thing failed"` plus `@org_id:42` is one query. With the `Warnf` form, you would have to regex over free text and still miss anything that varies.

### Use the context logger

A logger attached to the context carries request-scoped fields without you re-passing them at every call site. Use it everywhere a `ctx context.Context` is in scope.

```go
// ❌ Package-level logger — request context (org, region, trace ID) is gone
log.Warn("crawl skipped", "reason", "rate_limited")

// ✅ Context-scoped logger — org_id, region, crawler_name attach for free
observability.GetLogger(ctx).Warn("crawl skipped", "reason", "rate_limited")
```

The exact API depends on the framework — `observability.GetLogger(ctx)`, `slog` with a `ContextHandler`, `zap.Ctx(ctx)` — but the pattern is the same: pull the logger out of the context, not the package.

At service entry points (HTTP handler, RPC dispatch, job runner), enrich the logger with request-scoped fields once and store it in the context. Every downstream caller benefits.

### Field values stay typed

```go
// ❌ Pre-stringified — Log Management can't filter "count > 100" anymore
log.Info("processed", "count", strconv.Itoa(n), "elapsed", duration.String())

// ✅ Typed values — backend keeps them queryable
log.Info("processed", "count", n, "elapsed_ms", duration.Milliseconds())
```

Pre-stringification is a one-way trip. The backend can format a number for display; it can't reconstruct one from a string after the fact.

For durations, log a numeric milliseconds/nanoseconds field plus, optionally, a human-readable string. The numeric form is what alerts and dashboards consume.

### Errors go in their own field

Use the error helper your framework provides — it preserves the error chain and the stack:

```go
// ❌ Error loses its chain; backend sees one string
log.Warn("get user failed", "err", err.Error())

// ✅ Framework helper keeps the chain (errors.Is/As still works downstream)
log.Warn("get user failed", log.RichError(err))

// ✅ slog equivalent
slog.WarnContext(ctx, "get user failed", slog.Any("err", err))
```

When you wrap errors with `fmt.Errorf("verb noun: %w", ...)` at every layer (see Error Handling), the resulting log line carries the full trail: `get user 42: query users: scan row: invalid syntax`.

### Don't log and return

Pick one. Logging an error and then returning it means it gets logged again upstream — every call site adds a copy, all with different scopes.

```go
// ❌ Will appear in logs once here and again in every caller
if err != nil {
    log.Warn("get user failed", "err", err)
    return err
}

// ✅ Wrap and return; let the boundary that handles it log it
if err != nil {
    return fmt.Errorf("get user %s: %w", id, err)
}
```

Log at the **handler** boundary — the place where the error is consumed and not re-propagated — or in goroutines you start (where there's nothing to return to). Everywhere else, wrap and return.

### Levels

| Level | Use for |
|-------|---------|
| `Debug` | Verbose detail useful when reproducing a bug; off in production by default |
| `Info` | Lifecycle events — service started, job completed, request accepted |
| `Warn` | Recoverable problem — retry succeeded eventually, optional dependency unavailable |
| `Error` | A request or operation failed; investigation may be warranted |
| `Fatal` / panic-then-exit | Process cannot continue — startup misconfiguration only |

Avoid `Info` for every iteration of a tight loop — sample, or move it to `Debug`.

### Don't log secrets

Auth tokens, API keys, customer PII, full request bodies that may carry credentials — never log them, even at `Debug`. Use field allowlists or redaction wrappers when logging request data.

### Summary

1. **Static message string, variable data in fields.** Never `Warnf`/`Infof` with interpolation.
2. **Context logger** at every call site that has a `ctx`. Package-level logger only at top-level main / one-shot tools.
3. **Typed field values.** No `strconv.Itoa` / `time.Duration.String()` before logging.
4. **Errors via the framework helper** (`log.RichError`, `slog.Any("err", err)`) — keep the chain.
5. **Wrap and return, log at the boundary.** Don't double-log.
6. **No secrets / PII** in logs at any level.
