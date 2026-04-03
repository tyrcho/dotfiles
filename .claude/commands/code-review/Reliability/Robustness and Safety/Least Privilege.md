## Principle of Least Privilege

> "Every program and every user of the system should operate using the least set of privileges necessary to complete the job."
> — Jerome Saltzer, *Protection and the Control of Information Sharing in Multics* (1974)

### Core Concept

**Minimum permissions necessary for intended function—nothing more.**

1. **Minimize Attack Surface** — Fewer permissions = fewer entry points
2. **Limit Blast Radius** — Contain damage when breaches occur

74% of breaches start with privileged credential abuse.

### Application at Every Level

| Level | Example |
|-------|---------|
| **Function** | A function that reads config shouldn't have write access |
| **Class** | A `ReportGenerator` shouldn't have user deletion capabilities |
| **Service** | A payment microservice shouldn't access user profile data |
| **Account** | A database user for reads shouldn't have DROP TABLE privileges |

### Real-World Failures

| Breach | What Happened | PoLP Failure |
|--------|---------------|--------------|
| **Equifax (2017)** | 143M records stolen; attackers executed 9,000 DB queries | Permissive access controls; no network segmentation |
| **Target (2013)** | 40M credit cards via HVAC vendor | Third-party had excessive network access |

### Common Violations

**Code Smells**: Service accounts with `*` wildcard permissions, database connections with admin privileges, shared credentials across services, functions that accept more capabilities than needed.

**Verbal Cues**: "Just give it admin access, it's easier", "We'll lock it down later", "It needs these permissions for debugging"

### Anti-Patterns

```python
# ❌ Wrong - Over-privileged database connection
def get_user_email(user_id: int) -> str:
    conn = get_admin_connection()  # Has DELETE, DROP, etc.
    return conn.execute("SELECT email FROM users WHERE id = ?", user_id)

# ✅ Correct - Minimal privileges for the task
def get_user_email(user_id: int) -> str:
    conn = get_readonly_connection()  # Only SELECT privilege
    return conn.execute("SELECT email FROM users WHERE id = ?", user_id)
```

```python
# ❌ Wrong - Function accepts overly broad context
def send_notification(user: User, db: DatabaseAdmin):
    email = db.query(f"SELECT email FROM users WHERE id = {user.id}")
    # db could delete the entire users table!

# ✅ Correct - Function receives only what it needs
def send_notification(email: str):
    send_email(email, "Your notification...")  # Cannot access database
```

```yaml
# ❌ Wrong - IAM policy with wildcard
Effect: Allow
Action: "s3:*"
Resource: "*"

# ✅ Correct - Scoped to specific actions and resources
Effect: Allow
Action: ["s3:GetObject", "s3:PutObject"]
Resource: "arn:aws:s3:::my-bucket/uploads/*"
```

### Implementation Strategies

| Strategy | Description |
|----------|-------------|
| **Default deny** | Start with no access, explicitly grant what's needed |
| **Separate accounts by function** | Different credentials for read vs. write operations |
| **Time-bounded access** | Temporary elevated privileges that expire |
| **Audit unused permissions** | Regularly review and remove permissions not being used |

### Privilege Creep

Permissions accumulate beyond current needs: role changes without revocation, temporary access becoming permanent, misleading role names.

**Prevention**: Regular access reviews, automated permission expiration, minimal scope at design time.

### Relationship to Zero Trust

| Framework | Focus |
|-----------|-------|
| **Zero Trust** | Verify identity ("never trust, always verify") |
| **Least Privilege** | Limit access ("need to know") |

Partners: Zero Trust authenticates requests; PoLP limits authenticated access. Defense in depth.

### Summary

1. **Grant minimum necessary permissions** — Start with nothing, add only what's required
2. **Scope permissions tightly** — Specific resources, specific actions, specific time windows
3. **Separate credentials by function** — Read-only users for reads, write users for writes
4. **Audit and prune regularly** — Permissions accumulate; actively remove unused access
5. **Design for minimal access** — Functions, classes, and services should request only what they need
