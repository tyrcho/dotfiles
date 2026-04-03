## Dependency Injection

> "The key benefit of Dependency Injection is that it removes the dependency that a class has on a concrete implementation."
> — Martin Fowler

### Core Concept

Dependencies "injected" from outside rather than created internally. A class declares what it needs, not how to get it.

### Three Forms

1. **Constructor Injection** (Preferred): Through constructor
2. **Setter Injection**: Through setters after construction
3. **Interface Injection**: Dependency provides injector method

### Anti-Patterns

```python
# ❌ Wrong - Hardcoded dependency
class MovieLister:
    def __init__(self):
        self._finder = ColonDelimitedMovieFinder("movies.txt")  # Coupled!

# ✅ Correct - Injected dependency
class MovieLister:
    def __init__(self, finder: MovieFinder):
        self._finder = finder
```

### Service Lifetimes

| Lifetime | Instance Created | Use Case |
|----------|------------------|----------|
| **Transient** | Every time requested | Lightweight, stateless services |
| **Scoped** | Once per scope/request | Request-specific state |
| **Singleton** | Once for application lifetime | Expensive to create, shared state |

### Summary

1. **DI decouples classes from dependencies** — clients declare needs, not solutions
2. **Constructor injection is preferred** — explicit, immutable, testable
3. **Too many dependencies = SRP violation** — DI makes this visible
4. **Testability is the primary benefit** — swap real dependencies for test doubles
