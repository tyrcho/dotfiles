## Immutability

> "Immutable types are safer from bugs, easier to understand, and more ready for change."
> — MIT 6.005 Software Construction

### Core Concept

**Once created, state cannot be modified.** Create new structures with desired changes instead.

Mutable shared state causes most concurrency and aliasing bugs. Immutability eliminates them by design.

### Benefits

- **Thread safety without locks**: Share freely between threads
- **No defensive copying**: Share directly
- **Simpler reasoning**: Only understand creation site
- **Safe hash keys**: Can be dictionary keys
- **Enables caching**: Results remain valid indefinitely

### Common Violations

```python
# ❌ Wrong - Mutates caller's data
def normalize_scores(scores: list[float]) -> list[float]:
    for i in range(len(scores)):
        scores[i] /= max(scores)  # Mutates the input!
    return scores

# ✅ Correct - Returns new list
def normalize_scores(scores: list[float]) -> list[float]:
    max_score = max(scores)
    return [score / max_score for score in scores]
```

### Python Implementation

```python
from dataclasses import dataclass

# ✅ Immutable dataclass
@dataclass(frozen=True)
class Document:
    gdrive_id: str
    file_name: str
    content_hash: str

# ✅ Use tuple instead of list for fixed data
SUPPORTED_EXTENSIONS: tuple[str, ...] = (".pdf", ".docx", ".txt")

# ✅ Use frozenset instead of set
VALID_STATUSES: frozenset[str] = frozenset({"pending", "done", "failed"})
```

### Summary

1. **Immutable objects can't change** — once created, their value is fixed
2. **Aliasing is safe** with immutable objects
3. **Thread safety is free** — no locks needed
4. **Prefer immutability** — use frozen dataclasses, tuples, frozensets (see also: Parse, Don't Validate)
