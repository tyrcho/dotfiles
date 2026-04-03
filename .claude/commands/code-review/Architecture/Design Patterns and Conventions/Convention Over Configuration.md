## Convention Over Configuration

> "You're not a beautiful and unique snowflake. By giving up vain individuality, you can leapfrog the toils of mundane decisions, and make faster progress in areas that really matter."
> — David Heinemeier Hansson, The Rails Doctrine

### Core Concept

**Sensible defaults that work out of the box.** Explicit configuration only when deviating from norm. Core insight: most decisions aren't worth making—if 90% use `id` as primary key, don't force specification.

### The Power of Defaults

| Without CoC | With CoC |
|------------|----------|
| Specify database table name for every model | `User` class → `users` table automatically |
| Configure primary key column | `id` assumed unless overridden |
| Define foreign key naming | `user_id` derived from `User` association |
| Set up file locations manually | `app/models/`, `app/views/`, etc. by convention |

Conventions compose: `has_many :posts` resolves `Post` → `posts` table → `user_id` FK automatically.

### Real-World Examples

| Framework | Convention | Override When Needed |
|-----------|-----------|---------------------|
| **Rails** | `User` → `users` table | `self.table_name = "legacy_accounts"` |
| **Spring Boot** | Auto-configure from classpath | `@Configuration` for custom beans |
| **Django** | `model_name` → `appname_modelname` table | `class Meta: db_table = "custom"` |
| **Next.js** | `pages/about.js` → `/about` route | Custom routing configuration |
| **pytest** | `test_*.py` files auto-discovered | `pytest.ini` for custom patterns |

### When to Apply

| Good Fit | Poor Fit |
|----------|----------|
| Repeated patterns across projects | Highly unique domain requirements |
| Reducing boilerplate for common cases | Legacy systems with established conventions |
| Framework/library design | When explicitness aids understanding |
| Lowering barriers for beginners | Security-critical configurations |

### Common Violations

```python
# ❌ Wrong - Forcing configuration for obvious defaults
class UserService:
    def __init__(
        self,
        table_name: str,
        id_column: str,
        created_at_column: str,
        updated_at_column: str,
    ):
        self.table_name = table_name
        self.id_column = id_column
        # ... exhausting

# Usage requires specifying everything
service = UserService(
    table_name="users",
    id_column="id",
    created_at_column="created_at",
    updated_at_column="updated_at"
)

# ✅ Correct - Sensible defaults with escape hatches
class UserService:
    def __init__(
        self,
        table_name: str = "users",
        id_column: str = "id",
        timestamps: bool = True,
    ):
        self.table_name = table_name
        self.id_column = id_column
        self.timestamps = timestamps

# Usage: zero config for common case
service = UserService()  # Just works

# Override only what differs
legacy_service = UserService(table_name="legacy_accounts")
```

### The Dark Side

1. **Hidden Magic** — implicit behavior hard to debug
2. **Learning Cliff** — must learn convention to deviate
3. **Rigidity at Scale** — common-case optimizations may not scale

### Explicit vs. Implicit Trade-off

| Approach | Advantages | Disadvantages |
|----------|-----------|---------------|
| **Explicit (Configuration)** | Clear, searchable, no surprises | Verbose, repetitive, decision fatigue |
| **Implicit (Convention)** | Concise, consistent, fast start | Hidden behavior, learning curve |

**Python's "Explicit > implicit"** seems contradictory. Resolution: conventions must be *discoverable* and well-documented.

### Relationship to Other Principles

| Principle | Relationship |
|-----------|-------------|
| **KISS** | Both reduce unnecessary complexity; CoC removes decision complexity |
| **YAGNI** | Don't configure what you don't need to configure |
| **DRY** | Conventions eliminate repetitive configuration |
| **Cognitive Load** | Fewer decisions = lower mental burden |
| **Principle of Least Surprise** | Good conventions match developer expectations |

### Summary

1. **Provide sensible defaults** — Common cases should require zero configuration
2. **Allow overrides** — Escape hatches for when convention doesn't fit
3. **Conventions compose** — Build deeper abstractions from consistent patterns
4. **Document the magic** — Implicit behavior must be discoverable
5. **Know when to deviate** — Convention serves you until it doesn't; then configure explicitly
