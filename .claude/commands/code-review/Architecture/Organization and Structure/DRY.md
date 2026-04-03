## DRY: Don't Repeat Yourself

> "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system."
> — Andy Hunt & Dave Thomas, *The Pragmatic Programmer*

### Core Concept

DRY is about **knowledge**, not code. Avoid duplication of *meaning*, not syntax.

**Two types:**
1. **Knowledge Duplication** — Same business rule in multiple places. **Always fix.**
2. **Incidental Duplication** — Code *looks* similar but represents *different* concepts. **Leave it.** Merging couples unrelated concerns.

### The Rule of Three

> **First time**: Write it. **Second time**: Note it. **Third time**: Abstract it.

Patience to find the *right* abstraction. Two occurrences can't distinguish true duplication from incidental similarity. Three reveal the pattern.

### The Wrong Abstraction

> "Duplication is far cheaper than the wrong abstraction."
> — Sandi Metz

**The sunk cost trap**: Developer A creates an abstraction. Developer B needs similar functionality but not quite—adds a parameter. Developer C adds another. Developer D adds conditionals. Eventually the abstraction becomes incomprehensible, but no one deletes it because of the investment already made.

**The fix**: When an abstraction accumulates conditionals or parameters to handle "just one more case," inline it back into all callers, delete the unnecessary parts, and start fresh. It's cheaper to re-extract than to maintain the wrong abstraction.

### Recognizing True vs. Incidental Duplication

| True Knowledge Duplication (FIX) | Incidental Similarity (LEAVE) |
|---------------------------------|------------------------------|
| Same business rule/concept | Different business concepts |
| Changes *must* affect all instances | Instances will evolve independently |
| 3+ occurrences confirm the pattern | 1-2 occurrences—pattern unclear |
| Abstraction simplifies | Abstraction requires conditionals |
| Single source of truth needed | Coupling would be harmful |

### Common Violations

**Obvious**: Copy-pasted functions, duplicated validation, repeated magic numbers

**Hidden**: Inconsistent business rules across apps, divergent type definitions, scattered config, parallel data structures (DB columns in SQL strings AND ORM models)

### Anti-Patterns

```python
# ❌ Over-DRY: Merged with conditionals
def get_user_by_something(identifier, by_type):
    if by_type == "id": ...
    elif by_type == "email": ...

# ✅ Separate functions with clear responsibilities
def get_user_by_id(user_id: int) -> User: ...
def get_user_by_email(email: str) -> User: ...
```

```python
# ❌ Premature abstraction (Student/Teacher trap)
class Person:
    def get_full_name(self): return f"{self.first} {self.last}"
class Student(Person): pass
class Teacher(Person): pass  # Later needs middle name—abstraction wasted

# ✅ Keep separate until pattern proven
class Student:
    def get_full_name(self): return f"{self.first} {self.last}"
class Teacher:
    def get_full_name(self): return f"{self.first} {self.middle} {self.last}"
```

### Refactoring Techniques

| Technique | When to Use |
|-----------|-------------|
| **Extract Method** | Duplicated logic in same class |
| **Extract Class** | Duplication spans multiple methods |
| **Extract Superclass** | Multiple classes share behavior (Template Method) |
| **Parameterize Method** | Methods differ only in values |
| **Composition** | Complex inheritance hierarchies |

### DRY Beyond Code

- **Database**: Define constraints once in schema, not duplicated in app
- **API**: Generate OpenAPI from code (FastAPI/Pydantic), don't maintain separately
- **Config**: Centralize in one module, import everywhere
- **Docs**: Single source of truth, reference elsewhere
- **Infrastructure**: Similar infrastructure components may warrant deduplication.

### Summary

1. **Knowledge duplication is always a code smell**—always fix it
2. **Incidental similarity is not duplication**—don't merge different concepts
3. **Rule of Three**: Patience to find the *right* abstraction, not permission to ignore duplication
4. **Wrong abstractions**: Delete and start over—they merged incidental similarity
5. **Beyond code**: Databases, APIs, config, documentation (see also: Single Source of Truth)
