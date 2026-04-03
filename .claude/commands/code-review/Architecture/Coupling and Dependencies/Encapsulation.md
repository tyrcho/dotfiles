## Encapsulation

> "Ask not what an object knows; ask what it can do for you."

### Core Concept

**Bundle data with behavior, hide internals behind interfaces.**

1. **Bundling**: Group related data and behavior
2. **Information Hiding**: Restrict direct access to internal state

### Tell, Don't Ask

Don't query state and decide externally—tell the object what to do.

```python
# ❌ Wrong - Asking for state, making decisions externally
def process_order(order):
    if order.get_status() == "pending":
        if order.get_total() > 100:
            discount = order.get_total() * 0.1
            order.set_total(order.get_total() - discount)
        order.set_status("processed")

# ✅ Correct - Telling the object what to do
def process_order(order):
    order.process()  # Order knows its own business rules
```

### Common Violations

- **Data Classes Without Behavior**: A "data class" that only contains fields and getters/setters
- **Getter/Setter Pairs That Add No Value**: Accessors without validation or computation
- **Returning Mutable Internal State**: Allowing callers to corrupt object invariants
- **Feature Envy**: Methods that use more data from another class than their own

### Summary

1. **Bundle data with behavior** — Objects should do things, not just hold data
2. **Hide implementation details** — Internals can change without affecting callers
3. **Tell, don't ask** — Command objects to act rather than querying their state
4. **Protect invariants** — Use access control to enforce object validity (see also: Parse, Don't Validate)
