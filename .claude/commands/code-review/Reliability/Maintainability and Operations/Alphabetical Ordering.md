## Alphabetical Ordering

> "I know it seems pointless, but having the list be in lexicographical ordering makes diffs easier to read when reviewing."
> — *Internal code review comment*

### Core Concept

When the order of items in a list does not carry meaning, **sort alphabetically**. A reviewer should not have to scan the whole list to know what was added. Duplicates should pop out. AI-generated insertions should not be free to drop entries wherever they like.

This is the cheapest review-time improvement available. Most editors and linters can do it for you.

### Where it applies

| Construct | Why sort |
|-----------|----------|
| `const` / `enum` / `final` blocks | One canonical lookup; typos jump out |
| Import groups (after grouping by stdlib / third-party / local) | Tooling does it (`goimports`, `isort`, ESLint `sort-imports`) — accept the output |
| Configuration arrays (feature flags, scopes, allowlists) | Duplicates and near-duplicates become obvious |
| Metric / event / route registries | Lookup-by-eye works; merge conflicts shrink |
| Dependency lists in package manifests (`package.json`, `pyproject.toml`, `go.mod` requires) | Same |
| Independent `case` branches in a `switch` | When no branch depends on order |
| Struct / object field initializers when fields are independent | Free of arbitrary order |
| Test cases inside a table-driven test where order is irrelevant | Easier to add cases without diff churn |

### Where it does *not* apply

Some lists encode meaning in their order. **Don't sort these** even when they look enumerable:

- **Pipeline / workflow steps** — `["validate", "fetch", "transform", "publish"]`.
- **Precedence-sensitive rules** — auth middleware order, regex pattern fall-through.
- **External schema fields** — `proto` files, REST response shapes, serialized bytes layouts.
- **Sequence-flag tables** — `iota` Go enums where the numeric value is part of the API.
- **Performance-sorted cases** — `switch` arms ordered by hit frequency on purpose.
- **Visual / UI order** — menu items, dashboard widgets, anything a human reads in sequence.

When unsure, ask whether reordering changes behavior. If yes, leave it; if no, sort.

### Anti-Patterns

```python
# ❌ Arbitrary insertion order — duplicates hide, reviewer scans the whole list
SUPPORTED_REGIONS = [
    "us-east-1",
    "eu-west-1",
    "us-west-2",
    "ap-southeast-1",
    "us-east-1",        # duplicate, invisible at a glance
    "eu-central-1",
]

# ✅ Sorted — duplicate jumps out, new entries land in one obvious place
SUPPORTED_REGIONS = [
    "ap-southeast-1",
    "eu-central-1",
    "eu-west-1",
    "us-east-1",
    "us-east-1",        # duplicate is now visually adjacent
    "us-west-2",
]
```

```go
// ❌ Constants added as the feature grew — diff is wider than it needs to be
const (
    PermissionRead  = "read"
    PermissionAdmin = "admin"
    PermissionWrite = "write"
    PermissionList  = "list"
)

// ✅ Sorted — adding `PermissionDelete` is a one-line insert at the right place
const (
    PermissionAdmin  = "admin"
    PermissionList   = "list"
    PermissionRead   = "read"
    PermissionWrite  = "write"
)
```

### Make it mechanical

The principle only sticks if the tooling enforces it. Set up auto-sort where you can:

- **Imports**: `goimports`, `isort`, `ruff`, ESLint `sort-imports` / `import/order`.
- **Object/dict keys**: ESLint `sort-keys`, Prettier won't but many linters will.
- **Custom registries**: a project-local lint rule or a `make sort-registries` target is worth ~10 lines and saves hours of review.

When auto-sort is not available, the rule lives in code review.

### Summary

1. **Sort lists alphabetically** when order doesn't carry meaning.
2. **Duplicates become visible** — the highest-value side effect.
3. **AI insertions stop drifting** — they have one obvious place to go.
4. **Don't sort** pipelines, precedence rules, external schemas, sequence-flag enums.
5. **Automate it** — `goimports`, `isort`, ESLint plugins, project Makefile targets.
6. **Boy Scout it** — when editing a file with an unsorted enumerable, sort while you're there.
