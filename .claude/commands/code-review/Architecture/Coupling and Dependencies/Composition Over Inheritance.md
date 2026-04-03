## Composition Over Inheritance

> "Favor object composition over class inheritance."
> — Gang of Four, *Design Patterns*

### Core Concept

**Build complex behavior by combining objects rather than extending classes.**

- **Inheritance** ("is-a"): White-box — subclass sees parent internals
- **Composition** ("has-a"): Black-box — interact via interfaces only

### Why Composition Is Preferred

| Inheritance Problem | Composition Solution |
|---------------------|---------------------|
| Tight coupling to parent | Loose coupling via interfaces |
| Changes cascade to subclasses | Changes isolated to components |
| Hierarchy fixed at compile-time | Components swappable at runtime |
| Class explosion for combinations | Mix components as needed |
| Fragile base class problem | No inherited implementation details |

### Anti-Patterns

```python
# ❌ Wrong - Class explosion via inheritance
class FileLogger: ...
class FileLoggerWithEncryption(FileLogger): ...
class FileLoggerWithCompression(FileLogger): ...
# Combinatorial explosion!

# ✅ Correct - Composition
class Logger:
    def __init__(self, writer: Writer, filters: list[Filter]):
        self.writer = writer
        self.filters = filters

logger = Logger(FileWriter(), [EncryptionFilter(), CompressionFilter()])
```

### Summary

1. **Composition = "has-a"**, Inheritance = "is-a" — choose appropriately
2. **Inheritance breaks encapsulation** — changes cascade unpredictably
3. **Class explosion** — composition avoids combinatorial hierarchies
4. **Runtime flexibility** — swap components without recompiling
