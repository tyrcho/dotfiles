## Self-Documenting Code

> "Any fool can write code that a computer can understand. Good programmers write code that humans can understand."
> — Martin Fowler

### Core Concept

Code that **conveys purpose** through names, structure, and organization—without relying on comments. Comments explain *why*, code shows *what*.

**Reveals:** What/how (through naming and structure) · **Cannot reveal:** Why/context (requires comments/docs)

### The Three Pillars

#### 1. Intention-Revealing Names

Names express purpose, not implementation. **Spell words out completely**—abbreviations force mental translation.

```python
# ❌ Wrong
def proc(d, w):
    return d * w * 8

# ✅ Correct
def calculate_billable_hours(days_worked: int, weeks: int) -> int:
    hours_per_day = 8
    return days_worked * weeks * hours_per_day
```

#### 2. Eliminate Magic Values

Replace hardcoded numbers with named constants.

```python
# ❌ Wrong                    # ✅ Correct
if retry_count > 3:           MAX_RETRIES = 3
    time.sleep(0.5)           RETRY_DELAY_SECONDS = 0.5
                              if retry_count > MAX_RETRIES:
                                  time.sleep(RETRY_DELAY_SECONDS)
```

#### 3. Structured Organization

Each function has one clear purpose. Structure tells the story.

### Naming Conventions

| Element | Convention | Examples |
|---------|------------|----------|
| **Variables** | Nouns, fully spelled out | `user_count`, `retry_delay_seconds` |
| **Functions** | Verbs/verb phrases | `calculate_total()`, `validate_input()` |
| **Predicates** | `is_`, `has_`, `can_` prefix | `is_active`, `has_permission` |
| **Classes** | Nouns, PascalCase | `UserAccount`, `OrderProcessor` |
| **Constants** | UPPER_SNAKE_CASE | `MAX_RETRIES`, `DEFAULT_TIMEOUT` |

### Common Violations

**Code Smells:** Abbreviations (`usr`, `cnt`), single-letter variables outside tiny scopes, boolean parameters without names, vague function names (`process`, `handle`, `do`).

### The Comment Balance

Self-documenting handles **what/how**. Comments handle **why/why not**.

```python
# ✅ Correct - Comment explains why
# Exponential backoff: upstream API rate-limits during peak hours (ISSUE-1234)
for attempt in range(MAX_RETRIES):
    time.sleep(2 ** attempt)
```

### Summary

1. **Spell out names completely** — `user_count` not `usr_cnt` (reduces Cognitive Load)
2. **Eliminate magic values** — named constants explain meaning
3. **Structure tells story** — one function, one purpose
4. **Code shows what/how** — comments explain why/why not (see also: Documentation Discipline)
