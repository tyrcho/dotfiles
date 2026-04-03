## Fail-Fast & Defensive Programming

> "The best debugging is the debugging you never have to do because you found the problem immediately."
> — Jim Shore

### Core Concept

**Detect and report errors at the earliest possible moment.** Don't let invalid state propagate.

1. **Fail-Fast** — Detect early, fail immediately with clear diagnostics
2. **Defensive Programming** — Anticipate misuse, validate at boundaries

### Contracts

| Contract | Responsibility | Example |
|----------|---------------|---------|
| **Preconditions** | Caller must satisfy before calling | `assert user_id is not None` |
| **Postconditions** | Method must satisfy before returning | `assert result.is_valid()` |
| **Invariants** | Must hold throughout object lifetime | `assert self.balance >= 0` |

### Common Patterns

```python
# ✅ Guard Clauses - Fail fast at entry
def process_order(order):
    if order is None:
        raise ValueError("order required")
    if not order.items:
        raise ValueError("items required")

# ✅ Config Validation at Startup
def __init__(self):
    self.key = os.getenv("API_KEY")
    if not self.key:
        raise ConfigError("API_KEY required")
```

### Error Handling Strategies

| Error Type | Strategy |
|------------|----------|
| **Precondition violation** | Raise immediately |
| **Transient failure** | Retry with backoff |
| **Deterministic failure** | Fail permanently |
| **Invariant violation** | Assert (crash in dev) |

### Summary

1. **Validate early** — Check inputs at function entry, config at startup
2. **Fail loudly** — Clear error messages beat silent corruption
3. **Distinguish error types** — Transient (retry) vs. deterministic (fail) vs. bug (crash)
4. **Use assertions for invariants** — Things that should never be false (see also: Design by Contract)
5. **Trust validated data** — Don't re-validate inside trusted boundaries (see also: Parse, Don't Validate)
