## Small Functions

> "The first rule of functions is that they should be small. The second rule of functions is that they should be smaller than that."
> — Robert C. Martin (Uncle Bob), *Clean Code*

### Core Concept

Small Functions is the principle that **functions should be short, focused, and do one thing well**. Decompose logic into small, named units that can be understood at a glance.

**The key insight**: If you spend effort figuring out what code does, extract it into a function and name it after that "what." The name becomes documentation.

**Guideline sizes** (not rigid rules):
- **Ideal**: 5-15 lines
- **Warning**: 20-30 lines
- **Smell**: 50+ lines

### Why Small Functions Work

| Large Functions | Small Functions |
|-----------------|-----------------|
| Hard to name (does too many things) | Easy to name (does one thing) |
| Multiple levels of abstraction | Single level of abstraction |
| Difficult to test in isolation | Easy to unit test |
| Changes risk breaking unrelated logic | Changes are localized |

### The Stepdown Rule

Code should read like a top-down narrative, descending one level of abstraction at a time:

```python
# ✅ Correct - Reads like a story
def process_order(order: Order) -> Receipt:
    validate_order(order)
    apply_discounts(order)
    charge_payment(order)
    send_confirmation(order)
    return create_receipt(order)
```

### Common Violations

**Code Smells**:
- Functions over 30 lines
- Multiple `# Section` comments within one function
- Deeply nested conditionals (3+ levels)
- Functions with "And" in the name (`validateAndSave`)

**Verbal Cues**:
- "This function is long but it's all related"
- "Let me add a comment to explain this section"
- "I'll refactor it later when we have time"

### When NOT to Apply

**The Counterargument** (Cindy Sridharan's "Small Functions Considered Harmful"):
- **Loss of locality**: Jumping across many files increases cognitive load
- **Naming explosion**: More functions = more names to invent and remember
- **Shallow modules**: Many trivial functions can be worse than fewer deep ones

**When larger functions are acceptable**:
- Sequential logic that must share context
- State machines hard to decompose without passing lots of state
- Performance-critical code where call overhead matters
- One-off scripts that won't be maintained

**The test**: Can a newcomer understand this function in one read? If yes, it's fine—regardless of line count.

### Anti-Patterns

```python
# ❌ Too shallow - interface complexity exceeds implementation
def is_empty(collection): return len(collection) == 0
def is_not_empty(collection): return len(collection) > 0

# ✅ Better - meaningful abstraction hiding complexity
def get_active_users(user_ids: list[int]) -> list[User]:
    """Fetches users, filters inactive, sorts by last_active."""
    users = fetch_users_batch(user_ids)
    active = [u for u in users if u.is_active]
    return sorted(active, key=lambda u: u.last_active, reverse=True)
```

### Relationship to Other Principles

| Principle | Connection |
|-----------|------------|
| **Single Responsibility** | Small Functions is the *how*, SRP is the *what* |
| **Separation of Concerns** | Decompose by concern, then make each piece small |
| **DRY** | Extract duplicated code into small reusable functions |
| **Self-Documenting Code** | Function names replace comments when functions are small |
| **KISS** | Small functions are simpler to understand |

### Summary

1. **Keep functions short** — 5-20 lines is a good target, 50+ is a smell
2. **One level of abstraction** — Don't mix high-level flow with low-level details
3. **Name the "what"** — Extract code and name the function after its purpose
4. **Balance depth vs. breadth** — Avoid shallow modules with trivial functions
5. **Optimize for the reader** — Newcomers should understand the code quickly
