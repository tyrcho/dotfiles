## Pythonic Idioms

> "There should be one — and preferably only one — obvious way to do it."
> — *PEP 20, The Zen of Python*

### Core Concept

Pythonic code uses the language's built-in idioms rather than transliterations from C, Java, or JavaScript. The Zen of Python (`import this`) is the guiding aesthetic: explicit over implicit, simple over complex, readability over cleverness.

**EAFP over LBYL.** "Easier to Ask Forgiveness than Permission" is the Python convention: `try`/`except` is cheaper and more accurate than `if`-checking everything up front. Use LBYL ("Look Before You Leap") only when failure is expected and frequent.

### Common Violations

| Smell | Replace With |
|-------|--------------|
| `for i in range(len(xs)):` | `for x in xs:` or `for i, x in enumerate(xs):` |
| `if len(xs) > 0:` | `if xs:` |
| `x == None` / `x != None` | `x is None` / `x is not None` |
| `list(map(lambda x: x*2, xs))` | `[x*2 for x in xs]` |
| Manual zipped loops | `for a, b in zip(xs, ys):` |
| `if x == True:` | `if x:` |
| `temp = a; a = b; b = temp` | `a, b = b, a` |

### Anti-Patterns

```python
# ❌ LBYL with race conditions and noise
if os.path.exists(path):
    with open(path) as f:
        data = f.read()
else:
    data = ""

# ✅ EAFP — atomic, no TOCTOU race
try:
    with open(path) as f:
        data = f.read()
except FileNotFoundError:
    data = ""
```

```python
# ❌ C-style indexed loop
result = []
for i in range(len(users)):
    if users[i].active:
        result.append(users[i].email)

# ✅ Comprehension over the iterable
emails = [u.email for u in users if u.active]
```

```python
# ❌ Reinventing built-ins
found = False
for item in items:
    if item.id == target:
        found = True
        break

# ✅ any() expresses the intent
found = any(item.id == target for item in items)
```

### Truthiness

Empty containers, `0`, `None`, and `""` are falsy. Lean on this — `if items:` reads better than `if len(items) > 0:`. The exception is when the distinction between "missing" and "empty" matters: there, test `is None` explicitly.

### Summary

1. **Iterate directly** — `for x in xs`, not `for i in range(len(xs))`.
2. **Use comprehensions** for filter+map; reserve loops for side effects.
3. **EAFP** when failure is rare; **LBYL** only when failure is the expected path.
4. **`is None`** for sentinel checks, never `== None`.
5. **Lean on truthiness** for emptiness checks; use `is None` to distinguish missing from empty.
6. **Built-ins first** — `any`, `all`, `zip`, `enumerate`, `sorted`, `min`/`max(..., key=...)` replace most hand-written loops.
