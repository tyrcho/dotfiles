## Command-Query Separation

> "Asking a question should not change the answer."
> — Bertrand Meyer

### Core Concept

| Type | Purpose | Returns | Side Effects |
|------|---------|---------|--------------|
| **Query** | Return info | Yes | None |
| **Command** | Change state | None | Yes |

Methods returning values shouldn't change state. Methods changing state shouldn't return values.

### Why CQS Matters

1. **Reasoning Confidence**: Queries are safe to call anywhere
2. **Testing Simplicity**: Queries tested in isolation
3. **Caching Safety**: Queries can be cached
4. **Parallelization**: Queries run concurrently without race conditions

### Anti-Patterns

```python
# ❌ Wrong - Modifies AND returns
def get_or_create_user(self, email: str) -> User:
    user = self.db.find_by_email(email)
    if not user:
        user = User(email=email)
        self.db.save(user)  # Side effect!
    return user

# ✅ Correct - Separate operations
def find_user_by_email(self, email: str) -> User | None:
    """Query: Returns user or None, no side effects."""
    return self.db.find_by_email(email)

def create_user(self, email: str) -> None:
    """Command: Creates user, returns nothing."""
    self.db.save(User(email=email))
```

### Pragmatic Exceptions

- Stack pop operation (atomic)
- Thread-safe increment-and-get
- Database identity generation

### Summary

1. **Separate queries from commands** — Return value OR change state, not both
2. **Queries are safe** — Call them anywhere, cache them, parallelize them
3. **Commands need care** — Order matters, test state changes explicitly
4. **Break CQS pragmatically** — Atomic operations sometimes require both
