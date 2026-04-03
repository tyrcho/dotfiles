## Cognitive Load

> "Cognitive load is how much a developer needs to think in order to complete a task."
> — Artem Zakirullin

### Core Concept

Mental effort to understand code. Working memory holds ~**4 chunks**; exceed this and comprehension fails. **We read code 10x more than we write it**—every clever trick forces readers to hold more in their head.

### Three Types of Load

| Type | Description | Reducible? |
|------|-------------|------------|
| **Intrinsic** | Inherent task difficulty | No |
| **Extraneous** | How info is presented | **Yes—focus here** |
| **Germane** | Builds understanding | Desirable |

### Common Violations

```python
# ❌ Wrong - Each condition fills working memory
if val > THRESHOLD and (cond_a or cond_b) and (cond_c and not cond_d):
    process(val)  # 🤯 Reader is lost

# ✅ Correct - Named intermediates free working memory
is_above_threshold = val > THRESHOLD
is_allowed = cond_a or cond_b
is_secure = cond_c and not cond_d

if is_above_threshold and is_allowed and is_secure:  # 🧠 Fresh
    process(val)
```

```python
# ❌ Wrong - Deep nesting accumulates load
if is_valid:           # 🧠+
    if is_authorized:  # 🧠++
        if has_quota:  # 🧠+++
            process()  # 🤯

# ✅ Correct - Early returns keep memory clear
if not is_valid:
    return
if not is_authorized:
    return
if not has_quota:
    return
process()  # 🧠 All preconditions met
```

### The Familiarity Trap

**Familiarity ≠ simplicity.** Code in long-term memory feels easy; newcomers face full burden.

| Symptom | Reality |
|---------|---------|
| "It makes sense once you understand our patterns" | High learning curve = high load |
| "It's not that complicated" | Your long-term memory is doing the lifting |

### Deep vs. Shallow Modules

| Type | Interface | Implementation | Cognitive Load |
|------|-----------|----------------|----------------|
| **Deep** | Simple | Complex | Low—complexity hidden |
| **Shallow** | Complex | Simple | High—overhead exceeds value |

Unix I/O: five functions (`open`, `read`, `write`, `lseek`, `close`) hiding hundreds of thousands of lines. Contrast with `MetricsProviderFactoryFactory`—the name alone is more taxing than the implementation.

### Anti-Patterns

| Anti-Pattern | Problem |
|--------------|---------|
| **Too many tiny files** | Must hold all 80 class interactions in mind |
| **Layered architecture for its own sake** | Each indirection layer adds overhead |
| **Clever one-liners** | Reader must recreate author's thought process |
| **Premature microservices** | Distributed debugging is exponentially harder |

### Relationship to Other Principles

| Principle | Connection |
|-----------|------------|
| **KISS** | Cognitive load is *why* simplicity matters |
| **Self-Documenting Code** | Good names reduce mental translation |
| **Small Functions** | Must balance: too many shallow functions *increase* load |
| **Composition Over Inheritance** | Explicit dependencies reduce hidden context |
| **Modularity** | Deep modules hide complexity behind simple interfaces |

### Summary

1. **Working memory holds ~4 chunks** — Exceed this and comprehension fails
2. **Reduce extraneous load** — Focus on how code is presented
3. **Familiarity ≠ simplicity** — Code you know feels easy; newcomers feel the burden
4. **Prefer deep modules** — Simple interfaces hiding complex implementations
5. **Write boring code** — The best code requires no mental effort to parse
