## YAGNI: You Aren't Gonna Need It

> "Always implement things when you actually need them, never when you just foresee that you need them."
> — Ron Jeffries, XP co-founder

### Core Concept

YAGNI is the discipline of **not building functionality until it's required**. Every feature has costs: development, testing, maintenance, cognitive load. Features you don't need yet carry these costs without delivering value.

**The trap**: "While I'm here, I'll just add..." — **The reality**: ⅔ of speculative features fail to improve their target metrics.

### Four Costs of YAGNI Violations

| Cost | Description |
|------|-------------|
| **Build** | Time developing, testing, debugging unused code |
| **Delay** | Value lost by not building needed features instead |
| **Carry** | Complexity slowing all future development |
| **Repair** | Fixing when requirements differ from predictions |

### When YAGNI Applies

| Apply YAGNI | Don't Apply YAGNI |
|-------------|-------------------|
| Speculative features | Security (build in from start) |
| "Just in case" abstractions | Logging/observability |
| Unused configuration options | API versioning (public APIs) |
| Premature optimization | CI/CD and testing infrastructure |
| Generic frameworks for single use | Data migration paths |

### Common Violations

**Code Smells**: Config options no one uses, ABC with one implementation, extensibility points never extended, commented "future" code, unused API endpoints.

**Verbal Cues**: "We might need this later", "Just in case", "While we have the hood open...", "For future flexibility..."

### Anti-Patterns

```python
# ❌ Wrong - Speculative abstraction
class DataExporter(ABC):
    @abstractmethod
    def export(self, data): ...

class JSONExporter(DataExporter):
    def export(self, data): return json.dumps(data)
# CSVExporter, XMLExporter never built...

# ✅ Correct - Build what you need
def export_to_json(data):
    return json.dumps(data)
# Add abstraction when second exporter is needed
```

### The Delete Test

Before adding code: **Who needs this today?** (not "might need") — **What breaks without it?** (if nothing, skip it) — **Can we add it later?** (usually yes, with better understanding)

### Summary

1. **Build only what's needed now** — ⅔ of speculative features fail
2. **Delete speculative code** — git has history
3. **Hardcode first** — configure when needed (see also: KISS)
4. **Concrete over abstract** — until third occurrence (see also: DRY's Rule of Three)
5. **Keep code malleable** — YAGNI requires easy-to-change code
