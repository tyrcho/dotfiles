## Type Hints

> "Explicit is better than implicit."
> — *PEP 20*

### Core Concept

Python has been a gradually-typed language since [PEP 484](https://peps.python.org/pep-0484/) (Python 3.5). Modern Python (3.10+) makes type hints lightweight enough that there is no excuse for leaving public APIs unannotated. Hints serve three audiences: humans reading the code, IDEs/autocomplete, and static checkers (mypy, pyright, ty).

**Annotate every public function signature.** Locals are usually inferred. Tests can stay loose. Library code aimed at downstream callers should be `mypy --strict` clean.

### Modern syntax cheatsheet

| Old (pre-3.9) | Modern (3.10+) | Source |
|---------------|----------------|--------|
| `List[int]`, `Dict[str, int]` | `list[int]`, `dict[str, int]` | [PEP 585](https://peps.python.org/pep-0585/) |
| `Optional[int]` | `int \| None` | [PEP 604](https://peps.python.org/pep-0604/) |
| `Union[int, str]` | `int \| str` | PEP 604 |
| `Tuple[int, ...]` | `tuple[int, ...]` | PEP 585 |
| `Callable[[int], str]` | `Callable[[int], str]` (from `collections.abc`) | PEP 585 |

Import `Protocol`, `TypeVar`, `Callable`, etc., from `collections.abc` and `typing` — not the deprecated capitalised forms.

### Anti-Patterns

```python
# ❌ Untyped public API
def fetch(url, retries=3, timeout=None):
    ...

# ✅ Typed, with modern syntax
def fetch(url: str, retries: int = 3, timeout: float | None = None) -> bytes:
    ...
```

```python
# ❌ Lying with Any
def process(payload: Any) -> Any:
    return payload["items"]

# ✅ TypedDict or Protocol to express the contract
from typing import TypedDict

class Payload(TypedDict):
    items: list[str]

def process(payload: Payload) -> list[str]:
    return payload["items"]
```

```python
# ❌ Nominal coupling — caller must inherit Animal
def greet(a: Animal) -> str: ...

# ✅ Structural typing with Protocol — duck typing, type-checked
from typing import Protocol

class Named(Protocol):
    name: str

def greet(a: Named) -> str:
    return f"hello {a.name}"
```

### When hints hurt

- **Throwaway scripts** (< 100 lines). The ceremony isn't worth it.
- **Decorators** that legitimately need `*args, **kwargs` passthrough — `ParamSpec` helps but is sometimes worse than `Any`.
- **Dynamic dispatch** where the type genuinely is "anything". Use `Any`, but isolate it at one boundary.

### Checker discipline

Pin a checker in CI. Treat `# type: ignore` like a code smell — every instance needs a comment justifying it (e.g., `# type: ignore[arg-type]  # mypy bug in 1.11`).

### Summary

1. **Type every public signature** — parameters and return.
2. **Use modern syntax** — `list[int]`, `int | None`, built-in generics.
3. **`Any` is escape hatch, not default** — prefer `TypedDict`, `Protocol`, `TypeVar`.
4. **Protocols for duck typing** — structural beats nominal in idiomatic Python.
5. **Run a checker in CI** — types you never verify are documentation that rots.
6. **Locals usually infer** — annotate when the type isn't obvious from the right-hand side.
