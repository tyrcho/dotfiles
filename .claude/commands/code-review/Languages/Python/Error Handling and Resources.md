## Error Handling and Resources

> "Errors should never pass silently. Unless explicitly silenced."
> — *PEP 20*

### Core Concept

Python's exception model is built on two ideas: **be specific about what you catch**, and **let context managers handle cleanup**. A bare `except:` swallows `KeyboardInterrupt` and bugs alike — it's almost always a defect. A `try`/`finally` that forgets to close a resource is unnecessary in modern Python: `with` does it correctly every time.

### The bare-except rule

```python
# ❌ Catches KeyboardInterrupt, SystemExit, MemoryError, and every bug
try:
    process(payload)
except:
    pass

# ❌ Slightly less bad but still catches anything inheriting from Exception
try:
    process(payload)
except Exception:
    pass

# ✅ Specific exception, log it, and re-raise unless the recovery is real
try:
    process(payload)
except ValidationError as exc:
    log.warning("invalid payload: %s", exc)
    raise
```

If you genuinely need to log-and-continue, scope the `except` as narrowly as possible and never to a blanket `Exception`.

### Context managers

Anything that needs cleanup — files, locks, DB connections, subprocesses, temp directories — should be acquired through `with`. Hand-rolled `try`/`finally` is the C-style fallback; reach for it only when no context manager exists.

```python
# ❌ Forgotten close on the exception path
f = open(path)
data = json.load(f)  # if this raises, file leaks
f.close()

# ✅ Cleanup guaranteed
with open(path) as f:
    data = json.load(f)

# ✅ Multiple resources in one statement
with open(src) as in_f, open(dst, "w") as out_f:
    out_f.write(in_f.read())
```

For one-shot resources without a built-in CM, write your own with `@contextlib.contextmanager`. For mocking out cleanup in tests, `contextlib.ExitStack` composes them.

### Pathlib over `os.path`

```python
# ❌ String-juggling paths
import os
config = os.path.join(os.path.dirname(__file__), "..", "config", "app.yml")
if os.path.exists(config):
    with open(config) as f: ...

# ✅ pathlib reads naturally
from pathlib import Path
config = Path(__file__).parent.parent / "config" / "app.yml"
if config.exists():
    with config.open() as f: ...
```

`pathlib.Path` carries methods (`read_text`, `write_bytes`, `glob`, `is_dir`) that beat the scattered `os.path`/`os`/`shutil` equivalents.

### Logging, not print

`print` to stdout pollutes data pipelines and can't be routed, filtered, or silenced. Use `logging` — it goes to stderr by default and integrates with whatever the host process is doing.

```python
# ❌ Untraceable, mixes with data on stdout
print(f"processed {n} items")

# ✅ Levelled, timestamped, redirectable
import logging
log = logging.getLogger(__name__)
log.info("processed %d items", n)
```

Use `%`-style formatting in `log.*` calls so the format string is not evaluated when the level is filtered out.

### Summary

1. **Never bare `except:`** — name the exception or fix the bug.
2. **`with` for cleanup**, always. Hand-rolled `try`/`finally` is a smell.
3. **`pathlib.Path`** for filesystem work, not string concatenation on `os.path`.
4. **`logging`, not `print`**, for anything that survives past the next minute.
5. **Re-raise** when you've only logged — don't pretend the error didn't happen.
6. **Chain context** with `raise NewError(...) from exc` when wrapping, so the original traceback survives.
