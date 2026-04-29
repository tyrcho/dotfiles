## Recommended Folder Structure

Three top-level folders separate concerns clearly:

```
src/
  domains/
    users/
      user.ts              # Data structures, entities
      user_service.ts      # Pure business logic — no I/O, no framework
      user_repository.ts   # Interface (port) owned by the domain
    billing/
      billing.ts
      billing_service.ts
      payment_gateway.ts   # Interface for payment I/O
  repositories/
    users/
      postgres_user_repo.ts     # Implements UserRepository using SQL
    billing/
      stripe_payment_adapter.ts # Implements PaymentGateway
  main/
    api/
      user_controller.ts        # HTTP entry point
    cli/
      user_cli.ts
    functions/
      gsheet_trigger.ts         # Called by Google Sheets, cron, etc.
```

**Rule:** `domains/` depends on nothing external. `repositories/` and `main/` depend on `domains/`, never on each other.

## Hexagonal Architecture (Ports & Adapters)

**The domain defines interfaces (ports) for what it needs from the outside. I/O modules implement them.**

### The three layers

- **Domain** (`domains/`) — pure business logic and data structures. No database, no HTTP, no framework. Defines the interfaces it needs. Fully testable in isolation.
- **Repositories** (`repositories/`) — concrete implementations of domain interfaces that handle storage and external services.
- **Main** (`main/`) — entry points that wire everything together and handle inbound calls (HTTP, CLI, scheduled functions).

Dependency points inward: repositories and main depend on the domain; the domain knows nothing about them.

### Pattern

```typescript
// domains/users/user_repository.ts — interface owned by the domain
export interface UserRepository {
  save(user: User): Promise<void>;
  findById(id: string): Promise<User | null>;
}

// domains/users/user_service.ts — depends only on the interface
export class UserService {
  constructor(private repo: UserRepository) {}

  async register(email: string): Promise<User> {
    const user = new User(email);
    await this.repo.save(user);
    return user;
  }
}

// repositories/users/postgres_user_repo.ts — implements the interface
export class PostgresUserRepository implements UserRepository {
  async save(user: User) { /* SQL */ }
  async findById(id: string) { /* SQL */ }
}

// main/api/user_controller.ts — wires domain + repository together
const repo = new PostgresUserRepository(db);
const service = new UserService(repo);
```

### Testing

Swap the repository for an in-memory fake — no database, no network:

```typescript
class FakeUserRepository implements UserRepository {
  private store = new Map<string, User>();
  async save(u: User) { this.store.set(u.id, u); }
  async findById(id: string) { return this.store.get(id) ?? null; }
}

const service = new UserService(new FakeUserRepository());
```

### Key rules

- `domains/` **never** imports from `repositories/` or `main/`.
- Port names describe the *capability*, not the technology: `UserRepository`, not `PostgresRepository`.
- Pass repositories via **constructor injection** — never instantiate them inside the domain.
- Each external system (DB, cache, queue, HTTP client) gets its own repository/adapter.
