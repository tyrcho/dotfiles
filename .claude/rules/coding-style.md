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

## Markdown File Naming

**Use explicit, human-readable names rather than snake_case or kebab-case.**

- Use spaces and Title Case: `Git Workflows.md`, `Coding Style.md`
- Avoid underscores and hyphens: ~~`git_workflows.md`~~, ~~`coding-style.md`~~

Content should start immediately without repeating the filename as a heading. The filename is the title.

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

## Script Output - stderr vs stdout

**Log progress to stderr, output data to stdout.**

- `stderr`: progress messages, status updates, warnings, logs
- `stdout`: structured output (JSON, CSV, results meant for piping)

This allows scripts to be composed with pipes without mixing logs into data.

**Python:** use `logging` (logs to stderr by default), never `print` for progress.
```python
import logging, json

logging.basicConfig(level=logging.INFO, format="%(message)s")
log = logging.getLogger(__name__)

log.info("Fetching records...")
results = fetch_data()
log.info(f"Found {len(results)} records")

json.dump(results, sys.stdout)
```

For same-line progress (e.g. counters), use `\r` with `end=""` and flush:
```python
for i, item in enumerate(items):
    print(f"\rProcessing {i+1}/{len(items)}...", end="", flush=True, file=sys.stderr)
print(file=sys.stderr)  # newline when done
```

**Shell:** wrap `echo >&2` in a `log` function.
```bash
log() { echo "$*" >&2; }

log "Processing files..."
find . -name "*.json" | jq '.'  # stdout for data
log "Done"
```

For same-line progress in shell, use `\r` with `printf`:
```bash
for i in $(seq 1 "$total"); do
    printf "\rProcessing %d/%d..." "$i" "$total" >&2
done
printf "\n" >&2
```

## Python Projects - Hooks

When working in a Python project, suggest adding a `postEdit` hook to auto-check syntax after every file edit:

```json
// .claude/settings.json
{
  "hooks": {
    "postEdit": {
      "command": "cd $PROJECT_DIR && python -m py_compile $FILEPATH 2>&1 | head -5",
      "description": "Syntax check Python files after editing"
    }
  }
}
```

Suggest this once at the start of a Python session if no hook is already configured.
