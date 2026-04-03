## Principle of Least Surprise

> "In interface design, always do the least surprising thing."
> — Eric S. Raymond

### Core Concept

Components behave as users expect. Never surprise the user.

### Strategies

1. **Command-Query Separation**: Separate state-changing methods from queries
2. **Names match behavior**: Naming conventions communicate intent
3. **Consistent return types**: Similar methods return similar types
4. **Sensible defaults**: Most common, safest choice
5. **No hidden side effects**: Methods do only what signatures imply

### Common Anti-Patterns

- **Inconsistent Error Handling**: Different methods handle errors differently
- **Misleading Method Names**: Name implies query, actually mutates
- **Surprising Parameter Order**: Non-standard parameter order
- **Spooky Action at a Distance**: Unexpected effects on unrelated parts

### Summary

1. **Think like your user**: Design based on what users expect
2. **Separate commands from queries**: Methods that return values shouldn't change state
3. **Names must match behavior**: If you can't name it accurately, the design may be wrong
4. **Consistency over cleverness**: Use established patterns
5. **No hidden side effects**: Every behavior explicit in the signature and name
