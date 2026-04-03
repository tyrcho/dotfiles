## Single Source of Truth

> "There should be one—and preferably only one—obvious way to store a piece of information."

### Core Concept

**Every piece of data has exactly one authoritative location.** All other references derive from that source. The problem: when data exists in multiple places, which is correct?

### SSoT vs. DRY

| Aspect | DRY | SSoT |
|--------|-----|------|
| **Focus** | Code and logic duplication | Data storage duplication |
| **Scope** | Within a codebase | Across systems and databases |
| **Violation** | Copy-pasted functions | Same field in multiple tables |
| **Fix** | Extract to shared function | Designate authoritative source |

### Common Violations

1. **Storing Foreign Keys in Multiple Databases**
2. **Duplicating User Data Across Services**
3. **Storing Derived Data Without Clear Ownership**

### When Duplication Is Acceptable

1. **Intentional Caching** with TTL
2. **Read Model Denormalization** (CQRS)
3. **Computed/Derived Values**
4. **Cross-Region Replication**

### Summary

1. **Every piece of data needs exactly one authoritative source**
2. **Other systems should reference, not duplicate** authoritative data
3. **Derived/computed values are acceptable** — they don't need synchronization
4. **Ask "which is correct?"** — if you can't answer immediately, fix the design
