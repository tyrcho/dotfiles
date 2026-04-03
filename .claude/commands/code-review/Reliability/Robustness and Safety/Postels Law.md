## Postel's Law (Robustness Principle)

> "Be conservative in what you send, be liberal in what you accept."
> — Jon Postel, RFC 793 (1981)

### Core Concept

**Conservative output, liberal input.** Generate strictly conformant output; accept non-conformant input if meaning is clear. Instrumental in Internet's growth.

- **Conservative output** — Follow specs exactly
- **Liberal input** — Accept reasonable variations

### Real-World Examples

| System | How Postel's Law Applied | Outcome |
|--------|-------------------------|---------|
| **HTML Browsers** | Render malformed HTML gracefully | Web grew explosively; browser code became nightmarishly complex |
| **Unix Pipes** | Tools accept varied input, produce consistent output | Composable ecosystem; `cat`, `grep`, `sort` chain reliably |
| **SMTP Email** | Accept lines >998 chars despite spec limit | Pragmatic interop; many systems now depend on non-standard behavior |
| **JSON APIs** | Ignore unknown fields | Forward-compatible evolution; old clients work with new servers |

### When to Apply

| Context | Recommendation |
|---------|----------------|
| **Protocol extensions** | Ignore unknown fields; don't reject |
| **Public APIs** | Accept variations; can't control all clients |
| **Backward compatibility** | Old clients shouldn't break with new servers |
| **Security-critical input** | Validate strictly; liberal acceptance creates attack surface |
| **Internal systems** | Strict validation catches bugs early |

### The Tolerant Reader Pattern

Ignore unknown fields rather than failing:

```python
# ❌ Wrong - Strict parsing breaks when API adds fields
def parse_user(data: dict) -> User:
    if set(data.keys()) != {"id", "name", "email"}:
        raise ValueError("Unexpected fields in response")
    return User(id=data["id"], name=data["name"], email=data["email"])

# ✅ Correct - Tolerant reader ignores unknown fields
def parse_user(data: dict) -> User:
    return User(
        id=data["id"],       # Required: fail if missing
        name=data["name"],   # Required: fail if missing
        email=data["email"]  # Required: fail if missing
        # Unknown fields silently ignored - forward compatible
    )
```

### The Dark Side

Postel's Law has significant criticisms in modern hostile environments:

| Problem | Description |
|---------|-------------|
| **Specification Rot** | Receivers accept malformed input → senders never fix bugs → incorrect behavior becomes de facto standard |
| **Security Vulnerabilities** | "Reasonable" input may be crafted to exploit edge cases |
| **Hidden Bugs** | Liberal receivers mask sender bugs; problems surface years later |
| **Bug-for-Bug Compatibility** | New implementations must replicate bugs to maintain compatibility |

**HTML Lesson**: Browser tolerance enabled rapid growth but created nightmares—"incorrect" became the only way.

### Modern Balanced Approach

```python
# ✅ Balance: strict where it matters, tolerant for extensibility
def process_webhook(data: dict) -> None:
    # STRICT: Validate required fields (fail-fast)
    if "event_type" not in data:
        raise ValueError("Missing required field: event_type")
    if "timestamp" not in data:
        raise ValueError("Missing required field: timestamp")

    # TOLERANT: Ignore unknown fields (enables future extensions)
    event_type = data["event_type"]
    payload = data.get("payload", {})

    # CONSERVATIVE: Output follows strict contract
    handle_event(event_type, payload)
```

### Relationship to Other Principles

| Principle | Relationship |
|-----------|-------------|
| **Fail-Fast** | Tension: liberal acceptance delays failure detection; balance by validating *required* fields strictly |
| **Resilience** | Supportive: liberal acceptance aids graceful degradation |
| **Principle of Least Surprise** | Supportive: conservative output is predictable |
| **Defensive Programming** | Tension: strict boundary validation vs. liberal acceptance |

### Summary

1. **Conservative output, liberal input** — Generate strictly, accept generously
2. **Enables extensibility** — Unknown fields should be ignored, not rejected
3. **Has a dark side** — Masks bugs, enables specification rot, creates security risks
4. **Context matters** — Liberal for interop and extensibility; strict for security
5. **Modern balance** — Validate required fields strictly, ignore unknowns, output predictably
