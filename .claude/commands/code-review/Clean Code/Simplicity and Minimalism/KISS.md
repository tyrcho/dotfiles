## KISS: Keep It Simple, Stupid

> "Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away."
> — Antoine de Saint-Exupéry

### Core Concept

KISS is the discipline of **avoiding unnecessary complexity**. Coined by Kelly Johnson at Lockheed Skunk Works (1960), the principle states systems work best when kept simple.

**Two sins of complexity:**
1. **Too many parts** in the system
2. **Too many interconnected parts** coupling the system together

**Simple ≠ Easy:** Simple systems have few interconnected parts. Easy tasks require little effort.

### Measuring Complexity

| Metric | Measures | Threshold | Use Case |
|--------|----------|-----------|----------|
| **Cyclomatic Complexity** | Independent paths through code | ≤10/function | Test planning |
| **Cognitive Complexity** | Mental effort to understand | ≤15/function | Readability |

### Common Violations

**Code Smells**: Single-implementation interfaces, factories of factories, deep inheritance, "clever" one-liners.

**Verbal Cues**: "This pattern will be useful when...", "Let me make this more flexible...", "This is the proper enterprise way..."

### Four Classes of Violations

| Class | Example |
|-------|---------|
| **Cleverness Over Clarity** | Nested ternaries, regex golf |
| **Premature Optimization** | Caching before profiling |
| **Unnecessary Abstraction** | Interface for single implementation |
| **Speculative Generality** | Calculator with plugin architecture |

### Anti-Patterns

```python
# ❌ Wrong - Over-engineered calculator
class OperationInterface(ABC):
    @abstractmethod
    def execute(self, a: float, b: float) -> float: ...

class AddOperation(OperationInterface):
    def execute(self, a, b): return a + b

class OperationFactory:
    def create(self, op: str) -> OperationInterface: ...

# ✅ Correct - Direct solution
def calculate(a: float, b: float, op: str) -> float:
    if op == '+': return a + b
    if op == '-': return a - b
    if op == '*': return a * b
    if op == '/': return a / b
    raise ValueError(f"Unknown operation: {op}")
```

### The Simplicity Test

Before adding complexity: **Can a junior understand this?** — **Does it solve a problem we have today?** — **Am I trying to impress or communicate?**

### Summary

1. **Fewer parts, fewer connections** — complexity kills maintainability
2. **Simple ≠ Easy** — simple systems may require skill to build
3. **Junior-readable code** — if they can't understand it, it's too complex
4. **Hardcode first** — add configurability when proven necessary (see also: YAGNI)
5. **Measure complexity** — cyclomatic ≤10, cognitive ≤15 per function
6. **Simplest sufficient code** — not incomplete, not over-engineered
