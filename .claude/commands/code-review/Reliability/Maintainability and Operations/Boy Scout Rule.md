## Boy Scout Rule

> "Always leave the code better than you found it."
> — Robert C. Martin (Uncle Bob), *Clean Code*

### Core Concept

**With each commit, leave code slightly better than you found it.** Without active maintenance, technical debt accumulates. Continuous small improvements beat periodic "refactoring sprints."

### Why It Works

| Traditional Approach | Boy Scout Rule |
|---------------------|----------------|
| Accumulate debt, then "refactoring sprint" | Continuous small improvements |
| Cleanup disrupts feature delivery | Cleanup happens alongside features |
| Requires dedicated time allocation | Built into every commit |
| Big changes = big risk | Small changes = low risk |
| Code rot between sprints | Code improves continuously |

### What "Better" Looks Like

Small improvements that take seconds to minutes:

| Category | Examples |
|----------|----------|
| **Naming** | Rename `$a` to `$account`, `proc()` to `process_order()` |
| **Cleanup** | Remove unused imports, dead code, extra blank lines |
| **Deprecations** | Replace deprecated API calls with current alternatives |
| **Formatting** | Fix inconsistent indentation, add missing whitespace |
| **Duplication** | Extract repeated logic into a helper (if pattern is proven) |
| **Clarity** | Simplify a complex conditional into a named method |

### The Campground, Not the Forest

Clean the campground, not the entire forest.

```python
# ❌ Wrong - Changed 350 files to remove blank lines project-wide
# This makes code review impossible and introduces huge risk

# ✅ Correct - Cleaned up the file you're actually working in
def process_order(order_id: int) -> Order:
    # While adding this method, noticed and fixed:
    # - Renamed 'o' to 'order'
    # - Removed unused import
    # - Fixed inconsistent indentation
    order = self.repository.get(order_id)
    return self.apply_discount(order)
```

Scope cleanup to files you're already touching. Issues elsewhere? Create a ticket.

### Common Violations

**Code Smells Left Behind**:
- Ignoring deprecation warnings
- Leaving unused variables/imports
- Not fixing obvious naming issues
- Copying code instead of extracting

**Verbal Cues**:
- "I'll clean it up later" (you won't)
- "That's not my code"
- "It works, don't touch it"
- "We need a refactoring sprint"

### When NOT to Apply

**Exceptions**:
- **Unfamiliar code**: Don't "improve" code you don't fully understand
- **No test coverage**: Risky refactors in untested code can introduce bugs
- **Time-critical fixes**: Production incidents need the fix, not cleanup
- **Shared/external code**: Extra care when changes affect other teams

Clean up obvious issues; for larger concerns, create a ticket.

### Anti-Patterns

```python
# ❌ Wrong - "Not my problem" attitude
def add_discount(order):
    # Just adding my feature, ignoring the mess
    o = order  # terrible variable name from legacy code
    d = o.total * 0.1  # magic number
    o.total = o.total - d
    return o

# ✅ Correct - Boy Scout approach
def add_discount(order: Order) -> Order:
    # Cleaned up while adding feature:
    # - Renamed variables for clarity
    # - Extracted magic number to constant
    DISCOUNT_RATE = 0.1
    discount = order.total * DISCOUNT_RATE
    order.total = order.total - discount
    return order
```

### Relationship to Other Principles

| Principle | Connection |
|-----------|------------|
| **Broken Windows Theory** | Boy Scout Rule is the *antidote*—fix small issues before they invite bigger ones |
| **DRY** | Boy Scout Rule helps you spot and fix duplication incrementally |
| **Self-Documenting Code** | Rename unclear variables as you encounter them |
| **YAGNI** | Delete unused code when you find it |
| **Opportunistic Refactoring** | Same concept, different name—improve code while you're there |
| **Technical Debt** | Boy Scout Rule is continuous debt payment |

**Broken Windows**: Neglect invites more neglect. Boy Scout Rule signals "this code is cared for."

### Summary

1. **Leave code better than you found it** — Every commit is an opportunity
2. **Small improvements compound** — Minutes daily beats weeks annually
3. **Clean the campground, not the forest** — Scope to files you're touching
4. **Don't ignore the mess** — "Not my code" is not an excuse
5. **Make cleanup socially expected** — It should be as unacceptable to leave mess as to litter
