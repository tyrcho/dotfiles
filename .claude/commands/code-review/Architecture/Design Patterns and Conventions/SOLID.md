## SOLID Principles

> "SOLID principles are the foundation of good software design—they make code more maintainable, flexible, and testable."
> — Robert C. Martin (Uncle Bob)

### Overview

| Letter | Principle | Core Idea |
|--------|-----------|-----------|
| **S** | Single Responsibility | One reason to change |
| **O** | Open/Closed | Open for extension, closed for modification |
| **L** | Liskov Substitution | Subtypes must be substitutable for base types |
| **I** | Interface Segregation | Many specific interfaces over one general |
| **D** | Dependency Inversion | Depend on abstractions, not concretions |

### S — Single Responsibility Principle

> "A class should have one, and only one, reason to change."

**Violations**: Mixed I/O and logic, persistence in domain objects, god classes, class names with "And" or "Manager"

### O — Open/Closed Principle

> "Software entities should be open for extension but closed for modification."

**Violations**: `if/elif` chains checking types, `isinstance()` checks, modifying existing code for new variants

### L — Liskov Substitution Principle

> "Subtypes must be substitutable for their base types."

**Violations**: Subclass raises `NotImplementedError`, empty `pass` overrides, type checks before method calls

### I — Interface Segregation Principle

> "Clients should not be forced to depend on interfaces they do not use."

**Violations**: Fat interfaces (20+ methods), `raise NotImplementedError` in implementations

### D — Dependency Inversion Principle

> "High-level modules should not depend on low-level modules. Both should depend on abstractions."

**Violations**: Direct instantiation in constructors, concrete imports in business logic, can't mock for testing

### When NOT to Apply SOLID

1. **Simple scripts**: Overhead outweighs benefits
2. **Prototyping**: Flexibility over structure
3. **Performance-critical paths**: Abstractions add indirection
4. **Single implementations**: Don't create interfaces for classes that won't have alternatives
5. **Early development**: Wait for patterns to emerge (Rule of Three)

### Detection Checklist

| Principle | Code Smells |
|-----------|-------------|
| **SRP** | Class name has "And"/"Manager", methods don't use most attributes |
| **OCP** | Adding features requires modifying existing classes, `isinstance()` chains |
| **LSP** | Subclass raises `NotImplementedError`, empty overrides, type checks |
| **ISP** | Interfaces with 10+ methods, classes implement unused methods |
| **DIP** | Direct instantiation in constructors, can't mock for testing |
