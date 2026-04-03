## Guard Clauses (Early Return)

> "The guard clause says, 'This is rare, and if it happens, do something and get out.'"
> — Martin Fowler, *Refactoring*

### Core Concept

Early exit when preconditions aren't met. Check invalid states at the top, return immediately. Keeps the "happy path" at outermost indentation.

**Fights rightward drift**—the "arrow anti-pattern":

```
if () {
    if () {
        do {
            if () {
                if () {
                    // actual logic buried here
                }
            }
        }
    }
}
```

Guard clauses flatten this by handling exceptions first.

### The Transformation

```python
# ❌ Wrong - Nested conditionals obscure the happy path
def get_pay_amount(employee):
    result = 0
    if employee.is_dead:
        result = dead_amount()
    else:
        if employee.is_separated:
            result = separated_amount()
        else:
            if employee.is_retired:
                result = retired_amount()
            else:
                result = normal_pay_amount()
    return result

# ✅ Correct - Guard clauses make special cases obvious
def get_pay_amount(employee):
    if employee.is_dead:
        return dead_amount()
    if employee.is_separated:
        return separated_amount()
    if employee.is_retired:
        return retired_amount()
    return normal_pay_amount()
```

### When to Use

1. **Precondition validation** — null checks, empty inputs, invalid states
2. **Edge case handling** — special states that bypass normal logic
3. **Base cases** — recursive function termination

```python
# ✅ Classic guard clause pattern
def send_welcome_email(user):
    if user is None:
        return
    if not user.email:
        return

    # Main logic at natural indentation
    mailer.send(user.email, "Welcome!")
```

### When NOT to Use

When both branches are equally valid, use conventional conditionals:

```python
# ❌ Misleading - Both branches are equally valid
def process_order(order):
    if order.is_express:
        return handle_express_shipping(order)
    return handle_standard_shipping(order)

# ✅ Better - if/else signals equal weight
def process_order(order):
    if order.is_express:
        handle_express_shipping(order)
    else:
        handle_standard_shipping(order)
```

A guard clause signals "this is unusual—handle it and leave." Equal-weight branches deserve equal-weight syntax.

### The Single-Return Myth

Some codebases enforce "single return point" rules—a practice from Dijkstra's era when early returns could cause resource leaks in C. In modern languages with garbage collection and `try/finally`, this constraint is obsolete. The single-return style forces mutable state to accumulate results:

```python
# ❌ Single-return requires mutable state
def validate(data):
    result = True
    if not data.get('name'):
        result = False
    if result and not data.get('email'):
        result = False
    return result

# ✅ Guard clauses are cleaner
def validate(data):
    if not data.get('name'):
        return False
    if not data.get('email'):
        return False
    return True
```

### Common Violations

**Guard clause buried in the middle:**

```python
# ❌ Wrong - Guards belong at the top
def process(item):
    item.prepare()
    item.validate()
    if not item.is_ready:  # Too late
        return None
    return item.execute()

# ✅ Correct - Check preconditions first
def process(item):
    if not item.can_process:
        return None
    item.prepare()
    item.validate()
    return item.execute()
```

### Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| **Fail-Fast** | Guard clauses are fail-fast's implementation: detect problems immediately and exit |
| **Cognitive Load** | Flattening nested conditionals reduces mental overhead |
| **Small Functions** | Guards work best in small, focused functions |
| **Design by Contract** | Guards enforce preconditions at runtime |

### Summary

1. **Exit early for exceptional cases** — handle invalid states at the top
2. **Flatten nested conditionals** — each guard removes a nesting level (see also: Cognitive Load)
3. **Signal intent** — guards = "unusual," if/else = "both paths normal"
4. **Keep guards at the entrance** — preconditions belong at the top
5. **Embrace multiple returns** — single-return is obsolete
