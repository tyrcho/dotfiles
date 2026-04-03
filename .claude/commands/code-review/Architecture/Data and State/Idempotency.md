## Idempotency

> "An operation is idempotent if performing it multiple times has the same effect as performing it once."

### Core Concept

**Multiple executions produce same result as one.** In distributed systems, duplicate requests are inevitable—design around them.

### Implementation Strategies

1. **Idempotency Keys**: Attach unique identifier to each request
2. **Deterministic IDs**: Generate IDs from content itself
3. **Database Upserts**: Use `INSERT ... ON CONFLICT`
4. **Conditional Writes**: Use version numbers (optimistic locking)
5. **Lease-Based Processing**: Acquire exclusive access before processing

### Naturally Idempotent Operations

| Operation | Why Idempotent |
|-----------|----------------|
| `GET /resource` | Reads don't change state |
| `PUT /resource` | Full replacement, same result |
| `DELETE /resource` | Deleting twice = still deleted |
| Setting a value | `x = 5` is idempotent; `x += 5` is not |

### Summary

1. **Duplicates are inevitable** in distributed systems—design for them
2. **Use deterministic IDs** derived from content when possible
3. **Prefer upserts** over inserts for database operations
4. **Track processed messages** in queue consumers
5. **Test by calling twice** and verifying same result
