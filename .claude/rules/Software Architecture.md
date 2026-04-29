## Folder Organization - Domain Over Layer

**Organize folders by domain/feature, not by technology or layer.**

Grouping by layer (e.g., `controllers/`, `models/`, `utils/`) scatters related code across the codebase. Grouping by domain keeps everything for a feature together.

**TypeScript:**
```
src/
  billing/
    controller.ts
    service.ts
    model.ts
  users/
    controller.ts
    service.ts
    model.ts
```

**Python / Go:** same principle — domain folder at the top, files inside by responsibility.

## Hexagonal Architecture (Ports & Adapters)

**Separate pure business logic from I/O by defining interfaces (ports) that the core depends on, implemented by adapters.**

### The three layers

- **Core** — pure business logic. No database, no HTTP, no framework. Depends only on ports. Fully testable in isolation.
- **Ports** — interfaces defined *by the core* describing what it needs from the outside (`UserRepository`, `NotificationSender`).
- **Adapters** — concrete implementations of ports that handle actual I/O (`PostgresUserRepository`, `SmtpNotificationAdapter`).

Dependency points inward: adapters depend on ports; the core knows nothing about adapters.

### Folder structure

Combine with domain-over-layer: domain at the top, then `core/` and `adapters/` inside each domain.

```
src/
  users/
    core/
      UserService.ts         # Business logic — no I/O
      ports/
        UserRepository.ts    # Interface owned by the core
    adapters/
      db/
        PostgresUserRepository.ts   # Implements UserRepository
      http/
        UserController.ts           # Inbound entry point
  billing/
    core/
      BillingService.ts
      ports/
        PaymentGateway.ts
    adapters/
      http/
        BillingController.ts
      payment/
        StripePaymentAdapter.ts
```

### Pattern

```typescript
// users/core/ports/UserRepository.ts — interface owned by the core
export interface UserRepository {
  save(user: User): Promise<void>;
  findById(id: string): Promise<User | null>;
}

// users/core/UserService.ts — depends only on the interface
export class UserService {
  constructor(private repo: UserRepository) {}

  async register(email: string): Promise<User> {
    const user = new User(email);
    await this.repo.save(user);
    return user;
  }
}

// users/adapters/db/PostgresUserRepository.ts — implements the interface
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

- The core **never** imports from adapters.
- Port names describe the *capability*, not the technology: `UserRepository`, not `PostgresRepository`.
- Pass adapters via **constructor injection** — never instantiate them inside the core.
- Each external system (DB, cache, queue, HTTP client) gets its own adapter.
