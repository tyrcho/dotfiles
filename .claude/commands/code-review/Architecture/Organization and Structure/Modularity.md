## Modularity

> "Every module is characterized by its knowledge of a design decision which it hides from all others."
> — David Parnas

### Core Concept

Modularity is **dividing software into independent components** where each module encapsulates a specific responsibility and hides implementation details behind a well-defined interface.

**The Parnas Principle**: Decompose systems by **design decisions likely to change**. Each module hides one decision.

**Two measures:**
1. **Cohesion** — How strongly elements within a module belong together (aim: high)
2. **Coupling** — How much modules depend on each other's internals (aim: low)

### Deep vs. Shallow Modules

| Type | Characteristics |
|------|-----------------|
| **Deep** | Simple interface, complex implementation |
| **Shallow** | Complex interface, little hidden |

**Aim for depth**: Hide significant complexity behind minimal APIs.

### Common Violations

**Code Smells**: God Class, Feature Envy, Shotgun Surgery, Utilities junk drawer

### Summary

1. **Hide design decisions** — Each module encapsulates one decision likely to change
2. **High cohesion** — Elements within a module belong together
3. **Low coupling** — Modules depend only on interfaces
4. **Deep over shallow** — Simple interface, complex implementation
5. **No God modules** — If it does "everything," it encapsulates nothing
