## Resilience & Graceful Degradation

> "In complex systems, failure is the normal state. Success is the special case that requires explanation."
> — Richard Cook

### Core Concept

**Continue operating despite partial failures.** Anticipate failure, implement recovery, degrade gracefully.

### The Three Pillars

| Pillar | Purpose | Mechanism |
|--------|---------|-----------|
| **Retry** | Recover from transient failures | Exponential backoff with jitter |
| **Fallback** | Provide degraded service | Cached data, default values |
| **Protect** | Prevent cascade failures | Circuit breakers, timeouts |

### Pattern 1: Exponential Backoff with Jitter

```python
delay = min(base_delay * 2^attempt + random_jitter, max_delay)
```

### Pattern 2: Circuit Breaker

Three states: CLOSED (normal) → OPEN (fail fast) → HALF-OPEN (test recovery)

### Pattern 3: Graceful Degradation

```python
# Cascading fallback strategy
def get_recommendations(user_id: str) -> list[Product]:
    try:
        return recommendation_service.get_personalized(user_id)
    except ServiceUnavailableError:
        cached = cache.get(f"recommendations:{user_id}")
        if cached:
            return cached
        return get_popular_items()  # Final fallback
```

### Summary

1. **Failures are inevitable** — Design for them, don't assume success
2. **Retry with exponential backoff and jitter** — Prevents thundering herd
3. **Only retry transient errors** — Auth failures should fail fast
4. **Use circuit breakers** — Prevent cascading failures
5. **Always set timeouts** — Unbounded waits exhaust resources
