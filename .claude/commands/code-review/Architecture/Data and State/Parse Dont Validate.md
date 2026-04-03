## Parse, Don't Validate

> "A parser is just a function that consumes less-structured input and produces more-structured output."
> — Alexis King

### Core Concept

**Transform data into precise types that make illegal states unrepresentable.** Validation checks then forgets. Parsing checks and *remembers* in the type system.

### Validation vs. Parsing

```python
# ❌ Wrong - Validation: checks then discards knowledge
def validate_non_empty(items: list) -> None:
    if not items:
        raise ValueError("List cannot be empty")
    # Returns nothing—knowledge is lost

def process(items: list) -> None:
    validate_non_empty(items)
    first = items[0]  # Caller must trust validation happened

# ✅ Correct - Parsing: checks and returns proof
from typing import NewType, TypeVar
T = TypeVar('T')
NonEmptyList = NewType('NonEmptyList', list)

def parse_non_empty(items: list[T]) -> NonEmptyList[T]:
    if not items:
        raise ValueError("List cannot be empty")
    return NonEmptyList(items)  # Type proves non-emptiness

def process(items: NonEmptyList[T]) -> None:
    first = items[0]  # Type guarantees safety—no trust needed
```

### The Shotgun Parsing Anti-Pattern

Checks spread everywhere hoping to catch bad data:
1. **Redundant checks**: Same validation repeated
2. **Inconsistent coverage**: Easy to miss checks
3. **Rollback hell**: Invalid data after partial processing
4. **Silent corruption**: Invalid state if check forgotten

```python
# ❌ Wrong - Shotgun parsing
def get_user(user_id: str) -> User:
    if not user_id:
        raise ValueError("user_id required")
    ...

def update_user(user_id: str, data: dict) -> None:
    if not user_id:  # Repeated check!
        raise ValueError("user_id required")
    ...

# ✅ Correct - Parse once at the boundary
UserId = NewType('UserId', str)

def parse_user_id(raw: str) -> UserId:
    if not raw or not raw.strip():
        raise ValueError("user_id required")
    return UserId(raw.strip())

def get_user(user_id: UserId) -> User: ...      # No validation needed
def update_user(user_id: UserId, data: dict): ...  # Type guarantees validity
```

### Primitive Obsession

Over-reliance on `str`, `int`, `dict` for domain concepts. Primitives carry no context—validation knowledge is lost.

```python
# ❌ Wrong - Primitive obsession
def create_order(customer_id: str, product_id: str, quantity: int, price: float): ...
# Easy to swap customer_id/product_id; negative quantity allowed; what currency?

# ✅ Correct - Domain types encode constraints
def create_order(customer_id: CustomerId, product_id: ProductId,
                 quantity: PositiveInt, price: Money): ...
```

### Make Illegal States Unrepresentable

```python
# ❌ Wrong - Invalid states representable
@dataclass
class Order:
    status: str  # "pending", "shipped", "delivered"
    shipped_at: datetime | None  # Bug: can be None when status="shipped"

# ✅ Correct - Invalid states unrepresentable
@dataclass
class PendingOrder:
    items: list[Item]

@dataclass
class ShippedOrder:
    items: list[Item]
    shipped_at: datetime  # Required—impossible to forget

Order = PendingOrder | ShippedOrder | DeliveredOrder
```

### Parse at the Boundary

```python
# ❌ Wrong - Raw data flows through system
def handle_request(request: dict) -> Response:
    user_id = request.get("user_id")
    if not user_id:
        raise ValueError("user_id required")
    # More validation scattered deeper...

# ✅ Correct - Parse at boundary, use typed data internally
@dataclass(frozen=True)
class CreateUserRequest:
    user_id: UserId
    email: Email
    age: PositiveInt

def parse_request(raw: dict) -> CreateUserRequest:
    return CreateUserRequest(
        user_id=parse_user_id(raw.get("user_id", "")),
        email=parse_email(raw.get("email", "")),
        age=parse_positive_int(raw.get("age", 0)),
    )

def handle_request(request: CreateUserRequest) -> Response:
    ...  # All data already validated
```

### Lightweight Parsing with NewType

`NewType` marks validated data without runtime overhead:

```python
from typing import NewType

UserId = NewType('UserId', str)  # Still a str at runtime

def parse_user_id(raw: str) -> UserId:
    if not raw or not raw.startswith("U"):
        raise ValueError("Invalid user ID")
    return UserId(raw)

def load_user(user_id: UserId) -> User: ...

load_user(parse_user_id(url))  # ✅ OK
load_user("U6789679")  # ❌ Type checker error
```

### Common Violations

- **Functions returning `None` after validation** — Return the proof instead
- **Boolean flags instead of types** — `is_valid: bool` vs. `ValidatedData` type
- **Re-validating inside trusted code** — Parse at boundaries only
- **Passing raw dicts through layers** — Parse to domain types at the edge
- **Using `str` for everything** — Email, phone, SSN as `str` is primitive obsession

### When NOT to Apply

- **Quick scripts**: Overhead of custom types may not pay off
- **Performance-critical paths**: Sometimes primitives are faster
- **Prototyping**: Over-engineering types slows exploration
- **Simple CRUD**: Not every field needs a custom type

### Summary

1. **Parsers return proof, validators return nothing** — Transform data into types that encode validity
2. **Parse at the boundary** — Convert external data to domain types immediately
3. **Make illegal states unrepresentable** — Design types where invalid combinations can't exist
4. **Eliminate shotgun parsing** — Centralize validation, then trust the types
5. **Avoid primitive obsession** — Use domain types instead of raw `str`/`int`
6. **Choose parsing depth** — `NewType` for lightweight, classes for rich, Pydantic for full (see also: Fail-Fast, Design by Contract, Encapsulation, Immutability)
