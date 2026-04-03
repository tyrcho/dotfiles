## Design by Contract

> "A software system is not a bunch of components thrown together. It is a construction of interacting elements, connected by clear contracts."
> — Bertrand Meyer

### Core Concept

**Agreements between callers and routines.** Functions promise results (postconditions) **if** callers meet requirements (preconditions).

### The Three Pillars

| Element | Definition | Who Benefits | Who Obligates |
|---------|------------|--------------|---------------|
| **Precondition** | What must be true before | Supplier | Client |
| **Postcondition** | What the routine guarantees | Client | Supplier |
| **Invariant** | What must always be true | Both | Supplier |

### Inheritance Rules (Liskov Substitution)

| Contract Element | Subtype Rule |
|------------------|--------------|
| **Preconditions** | Can only be **weakened** |
| **Postconditions** | Can only be **strengthened** |
| **Invariants** | Can only be **strengthened** |

### DbC vs. Defensive Programming

| Aspect | Design by Contract | Defensive Programming |
|--------|-------------------|----------------------|
| **Philosophy** | Trust but verify at boundaries | Trust no one |
| **Responsibility** | Caller ensures preconditions | Callee handles all cases |
| **When to use** | Internal interfaces | External interfaces |

### Summary

1. **Contracts make responsibilities explicit** — Caller ensures preconditions; supplier ensures postconditions
2. **Invariants define valid object state** — Must hold after construction and every public method
3. **Assertions are executable contracts** — Document and verify simultaneously (see also: Fail-Fast)
4. **DbC complements defensive programming** — Use DbC internally, defensive at boundaries
