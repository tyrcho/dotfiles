## Data Structures

> "Bad programmers worry about the code. Good programmers worry about data structures and their relationships."
> — *Linus Torvalds*

### Core Concept

Python ships with rich data primitives — `list`, `dict`, `set`, `tuple`, plus `dataclasses`, `NamedTuple`, `Enum`, and the `collections` module. Reaching for a custom class when one of these fits is overhead. Reaching for a `dict` of `dict` of `list` when a `dataclass` fits is debt.

**Make shape explicit.** A `dataclass` says "here are the fields, here are their types"; a passed-around `dict[str, Any]` says "good luck."

### Dataclasses and NamedTuple

```python
# ❌ Anonymous tuple — meaning lives in your head
user = ("alice", "alice@example.com", 42)

# ❌ Free-form dict — typo-prone, no IDE help
user = {"name": "alice", "emial": "alice@example.com", "age": 42}

# ✅ Frozen dataclass — typed, immutable, equality + repr free
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class User:
    name: str
    email: str
    age: int
```

`@dataclass(frozen=True)` gives hashability and rules out accidental mutation. `slots=True` (3.10+) cuts memory and forbids attribute typos. Reach for `typing.NamedTuple` only when you need tuple semantics (positional unpacking, indexable).

### The mutable-default trap

The single most common Python footgun:

```python
# ❌ The default list is created ONCE, shared across all calls
def append_log(message, log=[]):
    log.append(message)
    return log

append_log("a")  # ["a"]
append_log("b")  # ["a", "b"] — surprise!

# ✅ Sentinel pattern
def append_log(message, log=None):
    if log is None:
        log = []
    log.append(message)
    return log
```

Same applies to `dict`, `set`, `dataclass`. For dataclass fields with mutable defaults, use `field(default_factory=list)`.

### Pick the right container

| Need | Container |
|------|-----------|
| Fixed-size sequence with named fields | `dataclass(frozen=True)` |
| Ordered, mutable, indexable | `list` |
| Order-irrelevant, fast `in` checks | `set` / `frozenset` |
| Key → value mapping | `dict` |
| Counting occurrences | `collections.Counter` |
| Default-value lookup | `collections.defaultdict` |
| Bounded LIFO/FIFO | `collections.deque(maxlen=...)` |
| Fixed set of named alternatives | `enum.Enum` / `enum.StrEnum` |

### Constants

```python
# ❌ Mutable globals — anyone can overwrite
SUPPORTED_EXTENSIONS = [".pdf", ".docx", ".txt"]

# ✅ Immutable, hashable, signals intent
SUPPORTED_EXTENSIONS: tuple[str, ...] = (".pdf", ".docx", ".txt")
VALID_STATUSES: frozenset[str] = frozenset({"pending", "done", "failed"})
```

For enumerated alternatives, `StrEnum` (3.11+) beats string constants because the type system rejects typos.

### Summary

1. **Frozen dataclass over `dict[str, Any]`** for any shape passed across function boundaries.
2. **Never mutable default arguments** — use `None` + sentinel or `default_factory`.
3. **`tuple`/`frozenset` for constants**, not `list`/`set`.
4. **`Enum`/`StrEnum`** for fixed alternatives, never magic strings.
5. **`collections` covers common patterns** — `Counter`, `defaultdict`, `deque` before reinventing.
6. **`slots=True`** on hot-path dataclasses for memory + typo safety.
