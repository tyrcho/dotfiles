## Orthogonality

> "Eliminate effects between unrelated things. Design self-contained components: independent, and with a single, well-defined purpose."
> — Andy Hunt & Dave Thomas

### Core Concept

**Changes in one component don't affect others.** Like a helicopter with coupled controls: fix one bug, two more pop up elsewhere.

### Common Violations

- **Global State**: Becomes a coupling point between different parts
- **Database-Coupled Business Logic**: SQL dialects leak into business logic
- **Presentation Mixed with Logic**: Changing display requires changing computation
- **Feature Creep in Objects**: Objects accumulate responsibilities

### Summary

1. **Two components are orthogonal if changes in one don't affect the other**
2. **Coupling is viral** — a little leads to more
3. **Measure orthogonality** by how many places change when one requirement changes
4. **Techniques that help**: dependency injection, abstract interfaces, avoiding global state
