## Folder Organization - Domain Over Layer

**Organize folders by domain/feature, not by technology or layer.**

Grouping by layer (e.g., `controllers/`, `models/`, `utils/`) scatters related code across the codebase. Grouping by domain keeps everything for a feature together.

This also applies to Claude plugins: skill scripts belong in their skill's subfolder, not in a shared `pluginname/scripts/` folder.

**TypeScript:**
```
# Bad                          # Good
src/                           src/
  controllers/                   billing/
    billing.ts                     controller.ts
    users.ts                       service.ts
  services/                        model.ts
    billing.ts                   users/
    users.ts                       controller.ts
  models/                          service.ts
    billing.ts                     model.ts
    users.ts
```

**Python:**
```
# Bad                          # Good
app/                           app/
  routes/                        billing/
    billing.py                     routes.py
    users.py                       service.py
  services/                        models.py
    billing.py                   users/
    users.py                       routes.py
  models/                          service.py
    billing.py                     models.py
    users.py
```

**Go:**
```
# Bad                          # Good
internal/                      internal/
  handlers/                      billing/
    billing.go                     handler.go
    users.go                       service.go
  services/                        repository.go
    billing.go                   users/
    users.go                       handler.go
  repositories/                    service.go
    billing.go                     repository.go
    users.go
```

**Claude plugins:**
```
# Bad                                  # Good
.claude/                               .claude/
  commands/                              commands/
    analyze.md                             analyze.md
    report.md                              report.md
  scripts/                               skills/
    analyze-helper.py                      analyze/
    analyze-reference.md                     SKILL.md        # overview and navigation
    analyze-examples.md                      reference.md    # detailed docs, loaded when needed
    report-helper.py                         examples.md     # usage examples, loaded when needed
    report-reference.md                      scripts/
    report-examples.md                         helper.py     # executed, not loaded
                                           report/
                                             SKILL.md
                                             reference.md
                                             examples.md
                                             scripts/
                                               helper.py
```

## Hexagonal Architecture (Ports & Adapters)

**Separate pure business logic from I/O by defining interfaces (ports) that the core depends on, implemented by adapters.**

### The three layers

- **Core** — pure business logic. No database, no HTTP, no framework. Depends only on ports (interfaces). Fully testable in isolation.
- **Ports** — interfaces defined *by the core* that describe what it needs from the outside world (`UserRepository`, `NotificationSender`).
- **Adapters** — concrete implementations of ports that handle actual I/O (`PostgresUserRepository`, `SmtpNotificationAdapter`).

The dependency always points inward: adapters depend on ports, ports belong to the core. The core knows nothing about adapters.

### Folder structure

```
src/
  core/
    models/          # Domain entities
    services/        # Business logic — no I/O, no frameworks
    ports/           # Interfaces only (UserRepository, NotificationSender…)
  adapters/
    db/              # Implements storage ports (Postgres, Mongo, in-memory)
    http/            # Inbound: controllers, route handlers
    messaging/       # Outbound: email, queues, webhooks
```

### Pattern

```typescript
// core/ports/UserRepository.ts — interface owned by the core
export interface UserRepository {
  save(user: User): Promise<void>;
  findById(id: string): Promise<User | null>;
}

// core/services/UserService.ts — depends only on the interface
export class UserService {
  constructor(private repo: UserRepository) {}

  async register(email: string): Promise<User> {
    const user = new User(email);
    await this.repo.save(user);
    return user;
  }
}

// adapters/db/PostgresUserRepository.ts — implements the interface
export class PostgresUserRepository implements UserRepository {
  async save(user: User) { /* SQL */ }
  async findById(id: string) { /* SQL */ }
}
```

### Testing

Swap the adapter for an in-memory fake — no database, no network:

```typescript
class FakeUserRepository implements UserRepository {
  private store = new Map<string, User>();
  async save(u: User) { this.store.set(u.id, u); }
  async findById(id: string) { return this.store.get(id) ?? null; }
}

const service = new UserService(new FakeUserRepository());
```

### Key rules

- The core **never** imports from adapters. Violation: the adapter layer bleeds into domain logic.
- Ports are named by **capability**, not technology: `ForStoringUsers`, not `ForPostgres`.
- Pass adapters via **constructor injection** — never instantiate them inside the core.
- Each external system (DB, cache, queue, HTTP client) gets its own adapter.
