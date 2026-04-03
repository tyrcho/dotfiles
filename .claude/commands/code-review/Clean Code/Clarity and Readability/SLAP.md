## Single Level of Abstraction (SLAP)

> "The code within a function should operate at a single level of abstraction."
> — Robert C. Martin, Clean Code

### Core Concept

Single Level of Abstraction Principle (SLAP) states that **every statement within a function should operate at the same level of abstraction**. When you mix high-level operations (like "process order") with low-level details (like "parse JSON field"), the code becomes harder to read because readers must mentally switch between abstraction levels.

**The key insight**: Switching between levels of abstraction forces mental grouping—readers must mentally construct the missing abstractions by finding which statements belong together.

### Abstraction Levels

| Level | Examples |
|-------|----------|
| **High** | `process_order()`, `authenticate_user()`, `generate_report()` |
| **Medium** | `validate_email()`, `calculate_tax()`, `format_response()` |
| **Low** | `strip().upper()`, `int(value)`, `encode('utf-8')` |

### Common Violations

```python
# ❌ Wrong - Mixed abstraction levels
def process_order(order_data: dict) -> None:
    user = get_user(order_data["user_id"])  # High-level

    # Low-level detail mixed in
    items = []
    for item in order_data.get("items", []):
        items.append({
            "sku": item["sku"].strip().upper(),
            "qty": int(item.get("quantity", 1))
        })

    validate_inventory(items)  # High-level
    charge_payment(user, calculate_total(items))
    send_confirmation(user)

# ✅ Correct - Single level of abstraction
def process_order(order_data: dict) -> None:
    user = get_user(order_data["user_id"])
    items = parse_order_items(order_data)
    validate_inventory(items)
    charge_payment(user, calculate_total(items))
    send_confirmation(user)
```

### The Stepdown Rule

Robert Martin's Stepdown Rule: code should read like a top-down narrative. Each function leads to the next level of abstraction, like a newspaper article—headline first, then summary, then details.

```python
# ✅ Reads top-down at consistent level
def generate_monthly_report(month: int, year: int) -> Report:
    data = fetch_monthly_data(month, year)
    metrics = calculate_metrics(data)
    charts = generate_visualizations(metrics)
    return compile_report(metrics, charts)
```

### Detecting Violations

**Smell #1: Loops with inline logic**
```python
# ❌ Extract the loop body
for entity in entities:
    dto = ResultDto()
    dto.shoe_size = entity.shoe_size
    dto.age = compute_age(entity.birthday)
    results.append(dto)

# ✅ Single statement in loop
for entity in entities:
    results.append(to_dto(entity))
```

**Smell #2: Comment + code block**
```python
# ❌ Comment indicates missing abstraction
# Validate email format
if not re.match(r'^[\w.-]+@[\w.-]+\.\w+$', email):
    raise ValueError("Invalid email")

# ✅ Named function replaces comment
validate_email_format(email)
```

### Caveats

- **Mental inlining**: Over-extraction forces readers to jump between many tiny functions
- **Simple code doesn't need extraction**: A 3-line function is already at one level
- **Guard clauses are OK**: An initial `if param is None: raise` at a higher-level function is acceptable
- **Performance**: Sometimes inlining is necessary for hot paths

### When NOT to Apply

- **Test code**: Explicit inline steps improve test readability
- **Single-use transformations**: Don't extract if it obscures more than clarifies
- **Trivially simple functions**: Extraction for its own sake adds noise

### Summary

1. **Every statement at the same abstraction level** — Don't mix orchestration with implementation
2. **Extract when you see mixing** — Loops with logic, comments + code blocks
3. **Use the stepdown rule** — High-level functions call medium-level, which call low-level
4. **Avoid over-extraction** — Balance SLAP against readability (see also: Small Functions, Cognitive Load, Separation of Concerns)
