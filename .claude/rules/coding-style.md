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

## Code Structure - Top to Bottom

**Files should flow from high-level to low-level.**

**Function ordering:**
- **Top of file:** High-level functions (entry points, orchestrators)
- **Bottom of file:** Utility functions (helpers, low-level operations)
- **Functions called before they are defined** (read top-down like a narrative)

This creates a natural reading flow where you understand what the code does before seeing implementation details.

**Example:**
```python
# High-level entry point
def process_user_request(request):
    data = extract_data(request)
    result = transform_data(data)
    return format_response(result)

# Mid-level orchestration
def transform_data(data):
    validated = validate_data(data)
    return apply_business_logic(validated)

# Low-level utilities
def validate_data(data):
    # validation logic

def apply_business_logic(data):
    # business logic
```
