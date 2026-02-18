# Coding Style Guidelines

## Function Length

**Maximum 25 lines per function.**

If a function exceeds 25 lines, split it into smaller, focused functions.

## DRY Principle - Rule of 3

**Identify and eliminate code duplication.**

- Code repeated **3 or more times** must be extracted into a reusable function
- Two instances: acceptable (might be coincidence)
- Three instances: pattern detected, refactor required

## Pure Functions

**Prefer pure functions when possible.**

**Pure function characteristics:**
- Same input always produces same output
- No side effects (no mutations, I/O, or state changes)
- Easier to test, reason about, and debug

**Organize code by function type:**
- Group pure functions together (data transformations, calculations)
- Separate functions with side effects (I/O, API calls, state mutations)
- Call pure functions from impure ones, not vice versa

**Example structure:**
```
# Pure functions (top of file)
def calculate_total(items): ...
def format_price(amount): ...

# Functions with side effects (below pure functions)
def save_to_database(data): ...
def send_notification(user): ...
```
