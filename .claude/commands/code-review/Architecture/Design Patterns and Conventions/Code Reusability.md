## Code Reusability

> "A little copying is better than a little dependency."
> — Rob Pike

### Core Concept

**Code usable in multiple contexts without modification.** Unlike DRY (eliminating existing duplication), reusability is forward-looking.

**The paradox**: Reusable components cost 3-10x more to develop. Payoff only materializes with actual reuse.

### Characteristics of Reusable Code

| Trait | Description |
|-------|-------------|
| **Modular** | Self-contained with minimal external dependencies |
| **Generic** | Handles a range of inputs without modification |
| **Well-documented** | Clear API, usage examples, edge cases documented |
| **Stable Interface** | Public API changes infrequently |
| **Thoroughly Tested** | Works reliably across scenarios |

### Types of Reuse

| Type | Scope | Example |
|------|-------|---------|
| **Copy-paste** | Lowest | Snippets, templates |
| **Functions** | Local | Utility functions within a project |
| **Libraries** | Organization | Shared packages across teams |
| **Frameworks** | Industry | Django, React, Rails |

### The Reusability Trap

Designing for reuse before proving need creates complexity without value. Rule of Three applies: wait until three different contexts.

**Santa Claus Problem**: A billion open source components—finding, learning, and integrating often costs more than the reuse saves.

```python
# ❌ Wrong - Premature reusability (YAGNI violation)
class GenericDataProcessor:
    """Handles any data format with any transformation."""
    def __init__(self, parser, transformer, validator, serializer):
        self.parser = parser
        self.transformer = transformer
        self.validator = validator
        self.serializer = serializer

    def process(self, data, options=None):
        options = options or {}
        parsed = self.parser.parse(data, **options.get('parse', {}))
        transformed = self.transformer.transform(parsed, **options.get('transform', {}))
        if options.get('validate', True):
            self.validator.validate(transformed)
        return self.serializer.serialize(transformed, **options.get('serialize', {}))

# ✅ Correct - Start specific, generalize when needed
def parse_user_csv(csv_data: str) -> list[dict]:
    """Parse user data from CSV format."""
    rows = csv_data.strip().split('\n')
    headers = rows[0].split(',')
    return [dict(zip(headers, row.split(','))) for row in rows[1:]]
```

### Designing for Reusability

When code has proven its need for reuse, apply these principles:

**1. Minimize Dependencies**
```python
# ❌ Wrong - Tight coupling to specific libraries
def format_date(date):
    import pandas as pd  # Heavy dependency for simple task
    return pd.Timestamp(date).strftime('%Y-%m-%d')

# ✅ Correct - Use standard library
from datetime import datetime

def format_date(date: datetime) -> str:
    return date.strftime('%Y-%m-%d')
```

**2. Accept Abstract Inputs**
```python
# ❌ Wrong - Only accepts specific type
def process_users(users: list[User]) -> None:
    for user in users:
        send_email(user.email)

# ✅ Correct - Accept any iterable of objects with email
from typing import Protocol, Iterable

class HasEmail(Protocol):
    email: str

def process_contacts(contacts: Iterable[HasEmail]) -> None:
    for contact in contacts:
        send_email(contact.email)
```

**3. Provide Sensible Defaults**
```python
# ❌ Wrong - Requires all parameters
def retry(func, max_retries, delay, backoff_factor, exceptions):
    ...

# ✅ Correct - Sensible defaults, only specify what differs
def retry(
    func,
    max_retries: int = 3,
    delay: float = 1.0,
    backoff_factor: float = 2.0,
    exceptions: tuple = (Exception,),
):
    ...
```

### Common Violations

**Code Smells**:
- Over-parameterized functions trying to handle every case
- Components that can't be tested in isolation
- Libraries that require complex configuration before basic use
- Code with implicit dependencies on global state

### When Reusability Hurts

Verbose, redundant code sometimes beats elegant abstractions:
- **Debugging**: Isolated code means problems stay isolated
- **Onboarding**: Simple duplication is easier to understand than clever abstractions
- **Change velocity**: Modifying copy-pasted code can't break other systems
- **Coupling**: "Reusable" components become coupling points across systems

### Summary

1. **Reusability is earned, not designed** — Wait for three use cases before investing
2. **Upfront cost is real** — Reusable code costs more to develop and understand
3. **Dependencies are the enemy** — Minimize external coupling; a little copying beats a little dependency
4. **Simple duplication can be better** — Isolated, obvious code often beats clever abstractions
5. **Stable interfaces enable reuse** — Public APIs should change rarely
