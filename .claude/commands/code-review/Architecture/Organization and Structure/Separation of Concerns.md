## Separation of Concerns

> "The separation of concerns, even if not perfectly possible, is yet the only available technique for effective ordering of one's thoughts."
> — Edsger W. Dijkstra

### Core Concept

**Decompose systems into distinct parts, each addressing one concern.** A "concern" = any aspect of functionality (business logic, persistence, UI, etc.).

**Measures:** High cohesion (related things together) · Low coupling (unrelated things independent)

### Types of Concerns

| Type | Examples |
|------|----------|
| **Functional** | Authentication, data processing, payment |
| **Non-functional** | Performance, security, scalability |
| **Cross-cutting** | Logging, error handling, caching |

### Common Violations

**Code Smells**: DB queries in UI handlers, business rules in CSS, validation scattered across layers, formatting in business classes.

**SoC-Specific Anti-Patterns:**

| Anti-Pattern | Description | Fix |
|--------------|-------------|-----|
| **Blob/God Object** | One class centralizes most functionality | Split into single-purpose classes |
| **Divergent Change** | One class changes for multiple reasons | Extract class per reason |
| **Shotgun Surgery** | One change modifies many places | Consolidate related logic |

### Anti-Patterns

```python
# ❌ Wrong - Mixed concerns: business logic + presentation + I/O
def process_order(order_id):
    order = db.query(f"SELECT * FROM orders WHERE id = {order_id}")
    if order.total > 100:
        order.discount = order.total * 0.1
    print(f"<div class='order'>Order #{order.id}: ${order.total}</div>")
    send_email(order.customer, "Your order is ready")

# ✅ Correct - Separated concerns
class OrderRepository:
    def get_by_id(self, order_id: int) -> Order:
        return self.db.query(Order).get(order_id)

class OrderService:
    def apply_discount(self, order: Order) -> Order:
        if order.total > 100:
            order.discount = order.total * 0.1
        return order

class OrderPresenter:
    def to_html(self, order: Order) -> str:
        return f"<div class='order'>Order #{order.id}: ${order.total}</div>"
```

### Summary

1. **One concern per component** — functions, classes, modules, layers
2. **High cohesion, low coupling** — related together, unrelated separate
3. **Natural boundaries** — separate where concerns genuinely differ
4. **Avoid over-separation** — don't fragment for its own sake
