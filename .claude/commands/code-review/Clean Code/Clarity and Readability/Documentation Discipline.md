## Documentation Discipline

> "Code tells you how, comments tell you why."
> — Jeff Atwood, Stack Overflow co-founder

### Core Concept

**Right documentation at the right level.** Comments don't compile, can't be tested, and rot—yet sometimes they're essential for explaining "why." The discipline: knowing the difference.

### The Documentation Pyramid

| Layer | Audience | Purpose |
|-------|----------|---------|
| **README** | New users/devs | First contact, setup, overview |
| **API Docs** | Consumers | Contract, usage, edge cases |
| **Docstrings** | Callers | What it does, params, returns |
| **Inline Comments** | Maintainers | Why this specific implementation |

Move documentation to the highest appropriate level.

### When Comments Add Value

```python
# ✅ Why - Business logic rationale
# Orders over $1000 require manager approval per SOX compliance (POLICY-2019-04)
if order.total > MANAGER_APPROVAL_THRESHOLD:
    require_approval(order)

# ✅ Why not - Explaining rejected alternatives
# Using linear search instead of binary: list is always <10 items
# and maintaining sort order would cost more than the lookup savings

# ✅ Workarounds - External constraints
# Firefox doesn't fire mouse events when dragging outside the window.
# Workaround: capture position on mouseLeave and extrapolate.

# ✅ Links - Attribution and context
# Algorithm from https://stackoverflow.com/a/46018816 (CC-BY-SA)

# ✅ Warnings - Prevent future mistakes
# Don't use global isFinite()—it returns true for null values
Number.isFinite(value)
```

### Comment Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| **Parrot comments** | `i += 1  # increment i` | Delete—code already says this |
| **Rotting comments** | Comment describes deleted code | Delete or update |
| **Journal comments** | `// Fixed by John, 3/15` | Use git blame instead |
| **Commented-out code** | Dead code polluting the file | Delete—git has history |
| **Closing brace comments** | `} // end if` | Extract to smaller functions |
| **Mandated comments** | Boilerplate on every method | Comment only when valuable |
| **TODO graveyards** | `// TODO: fix this (2019)` | Create tickets or delete |

```python
# ❌ Wrong - Parrot comment
def calculate_tax(amount):
    tax_rate = 0.08  # Set tax rate to 0.08
    return amount * tax_rate  # Return amount times tax rate

# ✅ Correct - Explains the why
def calculate_tax(amount):
    # California state tax rate as of 2024. Updates tracked in POLICY-TAX-01.
    CA_TAX_RATE = 0.08
    return amount * CA_TAX_RATE
```

### The Rot Problem

Comments drift from code silently. Keep close to code, review during code review, delete rather than let rot.

```python
# ❌ Rotting comment - Code changed, comment didn't
def get_users():
    # Returns active users sorted by name
    return User.query.filter_by(status='active').order_by(User.created_at).all()
    # ↑ Now sorted by created_at, comment lies
```

### Docstrings Done Right

```python
# ❌ Wrong - Restates the obvious
def add(a: int, b: int) -> int:
    """Add two integers. Args: a: First integer. b: Second integer."""
    return a + b

# ✅ Correct - Documents non-obvious behavior
def calculate_shipping(order: Order) -> Decimal:
    """
    Calculate shipping cost with business rules.

    - Free shipping for orders over $100
    - Hawaii/Alaska adds flat $15 (no free shipping)

    Raises:
        InvalidAddressError: If shipping address is incomplete
    """
```

### Relationship to Other Principles

| Principle | Connection |
|-----------|------------|
| **Self-Documenting Code** | Code shows *what/how*; comments explain *why/why not* |
| **DRY** | Don't repeat in comments what the code already says |
| **Single Source of Truth** | One authoritative place for each piece of documentation |
| **Boy Scout Rule** | Fix stale comments when you touch the code |

### Summary

1. **Code tells how, comments tell why** — Never explain what code does; explain why it does it
2. **Documentation has layers** — README → API docs → docstrings → inline comments
3. **Comments rot** — Review them during code review; delete rather than let them lie
4. **Anti-patterns abound** — Parrot, journal, and TODO graveyard comments add noise
5. **When in doubt, refactor** — If you need a comment to explain what, the code is unclear
