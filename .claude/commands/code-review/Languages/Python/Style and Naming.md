## Style and Naming

> "Readability counts."
> — *PEP 20*

### Core Concept

[PEP 8](https://peps.python.org/pep-0008/) is the de facto style guide for Python. The point is **consistency within a project** so readers can focus on logic, not formatting. Use an auto-formatter (Black, Ruff format) and a linter (Ruff, flake8) so style is enforced mechanically — review comments should be about design, not whitespace.

### Naming conventions

| Element | Convention | Example |
|---------|------------|---------|
| Variable, function, method | `snake_case` | `user_count`, `parse_payload()` |
| Class, exception | `PascalCase` | `UserRepository`, `RetryError` |
| Module, package | `lowercase` or `snake_case` | `user_service.py` |
| Constant (module-level) | `UPPER_SNAKE_CASE` | `MAX_RETRIES = 3` |
| Private / internal | `_leading_underscore` | `_cache`, `_compute_hash()` |
| Dunder (reserved) | `__double_under__` | `__init__`, `__repr__` |
| "Avoid clash" suffix | `trailing_underscore_` | `class_`, `id_` |

Avoid single-letter names except loop counters and short comprehensions. Never use `l`, `O`, or `I` (visually ambiguous with `1` and `0`).

### Layout rules

- **Indentation**: 4 spaces, never tabs.
- **Line length**: 88 (Black default) or 79 (strict PEP 8). Pick one per project and stick with it.
- **Blank lines**: two between top-level `def`/`class`; one between methods.
- **Imports**: one per line, ordered standard-library → third-party → local, each group separated by a blank line. No wildcard imports (`from x import *`).
- **Trailing commas** in multi-line collections — keeps diffs clean.

### Anti-Patterns

```python
# ❌ PEP 8 violations stacked together
import os,sys
from mymodule import *

def ProcessData( inputList,MAX=10 ):
    l=len(inputList)
    if l>0:
       return inputList[ :MAX]

# ✅ PEP 8 compliant
import os
import sys

from mymodule import process, validate

MAX_ITEMS = 10

def process_data(items: list, max_items: int = MAX_ITEMS) -> list:
    if items:
        return items[:max_items]
    return []
```

### When to ignore PEP 8

PEP 8 itself says: "do not break backwards compatibility just to comply." Don't rename public APIs to fit the style guide. Don't reformat third-party code you vendored. Consistency with the surrounding code wins.

### Summary

1. **Enforce mechanically** — Black/Ruff format + Ruff lint, configured in `pyproject.toml`.
2. **`snake_case` for callables/variables**, **`PascalCase` for classes**, **`UPPER_CASE` for constants**.
3. **Imports grouped** stdlib → third-party → local; no wildcard imports.
4. **88-char lines** (Black) or **79** (strict PEP 8) — pick one project-wide.
5. **Consistency beats the rule** — match the file you're editing.
