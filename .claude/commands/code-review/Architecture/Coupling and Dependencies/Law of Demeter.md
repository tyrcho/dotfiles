## Law of Demeter

> "Each unit should have only limited knowledge about other units: only talk to your immediate friends; don't talk to strangers."
> — Ian Holland

### Core Concept

**Limit knowledge of other objects' structure.** Only interact with immediate dependencies, not through them.

### The "One Dot" Rule

```python
# ❌ Wrong - Multiple dots (train wreck)
customer.get_wallet().get_credit_card().charge(amount)

# ✅ Correct - One dot
customer.charge(amount)  # Customer knows how to charge itself
```

### Formal Definition

A method `m` of object `a` may only invoke methods of:
- `a` itself
- `m`'s parameters
- Objects created within `m`
- `a`'s direct attributes
- Global/module-level objects

**Forbidden**: Methods of objects returned by other method calls.

### Exceptions: When Chaining Is Acceptable

| Pattern | Why It's OK |
|---------|-------------|
| **Builder pattern** | Same object returned; configures self |
| **Fluent interfaces** | Designed for chaining; returns `self` |
| **Data Transfer Objects** | No behavior to encapsulate |
| **Standard library** | `"hello".strip().upper()` — string ops |

### A Note on Tell-Don't-Ask

> "Tell-Don't-Ask encourages moving behavior into objects, but don't become a Getter Eradicator."
> — Martin Fowler

Objects sometimes collaborate effectively by *providing* information. Transformers that simplify data for clients (like `EmbeddedDocument`) are valid query methods. The principle is about co-locating behavior with data, not eliminating all accessors.

### Summary

1. **Only talk to immediate friends** — don't reach through objects
2. **One dot rule** — `a.b()` good, `a.b().c()` suspect
3. **Tell, don't ask** — command objects, don't interrogate (see also: Encapsulation)
4. **Exceptions exist** — builders, fluent APIs, DTOs are fine
