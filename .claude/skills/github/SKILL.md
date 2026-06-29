---
name: github
description: Interact with GitHub using the gh CLI tool. Use for viewing, creating, updating issues and PRs, repository operations, workflow management, advanced searches with date ranges and filters, analyzing engineer contributions, bulk operations, and cross-platform work analysis integrating with Jira, Confluence, or Datadog. Handles org-level searches, pagination, JSON output formatting, and large dataset analysis.
allowed-tools: Bash, Read, Write, Grep, Glob
---

# GitHub Skill

This skill provides comprehensive GitHub integration using the `gh` command-line tool, including advanced search, analysis, and cross-platform correlation capabilities.

## When to Use

Activate this skill when the user wants to:
- View, create, or manage GitHub issues and pull requests
- Search PRs/issues with advanced filters (date ranges, authors, reviewers, organizations)
- Analyze engineer contributions or work patterns
- Work with pull requests (view, create, review, merge)
- Get repository or organization information
- Manage branches, releases, and workflows
- View or trigger GitHub Actions workflows
- Perform bulk operations or data exports
- Correlate GitHub activity with other systems (Jira, Confluence, Datadog)
- Handle large result sets with pagination
- Any GitHub-related operation or analysis

## Core Capabilities

### Issues
- `gh issue list` - List issues
- `gh issue view <number>` - View issue details
- `gh issue create` - Create new issue
- `gh issue edit <number>` - Edit existing issue
- `gh issue close <number>` - Close issue
- `gh issue reopen <number>` - Reopen issue
- `gh issue comment <number>` - Add comment to issue

### Pull Requests
- `gh pr list` - List pull requests
- `gh pr view <number>` - View PR details
- `gh pr create` - Create new PR
- `gh pr checkout <number>` - Checkout PR branch
- `gh pr review <number>` - Review PR
- `gh pr merge <number>` - Merge PR
- `gh pr close <number>` - Close PR
- `gh pr diff <number>` - Show PR diff
- `gh pr checks <number>` - View PR status checks

### Repository
- `gh repo view` - View repository details
- `gh repo clone <repo>` - Clone repository
- `gh repo fork <repo>` - Fork repository
- `gh repo create` - Create new repository
- `gh repo list` - List user repositories

### Releases
- `gh release list` - List releases
- `gh release view <tag>` - View release details
- `gh release create <tag>` - Create new release
- `gh release download <tag>` - Download release assets

### Workflows (GitHub Actions)
- `gh workflow list` - List workflows
- `gh workflow view <workflow>` - View workflow details
- `gh workflow run <workflow>` - Trigger workflow
- `gh run list` - List workflow runs
- `gh run view <run-id>` - View run details
- `gh run watch <run-id>` - Watch run in real-time

### Search (Advanced)
- `gh search issues <query>` - Search issues across repos/orgs
- `gh search prs <query>` - Search pull requests with filters
- `gh search repos <query>` - Search repositories (use `fullName`, `stargazersCount` for JSON)
- `gh search code <query>` - Search code

**CRITICAL: Two Search Syntax Patterns**

The `gh search prs` command supports TWO different syntaxes. You must choose the right one:

**Pattern 1: Use FLAGS (RECOMMENDED for date ranges and author/reviewer filters)**
```bash
# Search PRs by author with date range - USE THIS SYNTAX
gh search prs --author="username" --updated=">=YYYY-MM-DD" --updated="<=YYYY-MM-DD" --json title,url,repository,createdAt,state,number

# Search PRs reviewed by user (excluding their own) - USE THIS SYNTAX
gh search prs --reviewed-by="username" --updated=">=YYYY-MM-DD" --updated="<=YYYY-MM-DD" --json title,url,repository,createdAt,state,number -- -author:"username"

# With org filter using query string
gh search prs --author="username" --updated=">=2025-06-24" --updated="<=2025-11-24" --json title,url,repository,createdAt,state,number "org:DataDog"
```

**Pattern 2: Use QUERY STRING (for complex filters, but can be flaky)**
```bash
# Organization-level search with date range (alternative syntax)
gh search prs "author:username updated:YYYY-MM-DD..YYYY-MM-DD org:DataDog"

# Repository-scoped search
gh search prs "is:merged author:username repo:owner/repo"
```

**Key Differences:**
- **Flags** (`--author`, `--reviewed-by`, `--updated`): More reliable, required for excluding authors with `-- -author:"username"`
- **Query string**: More flexible for complex boolean logic, but date ranges can fail
- **Date fields**: Use `--updated` flag (not `--merged` or `--created`) for broad date filtering
- **ALWAYS use exact JSON fields**: `--json title,url,repository,createdAt,state,number`

**Date Range Calculations:**
```bash
# Calculate date N months ago (cross-platform)
(date -d "6 months ago" "+%Y-%m-%d" 2>/dev/null || date -j -v-6m "+%Y-%m-%d")

# Calculate timestamp for URLs (milliseconds since epoch)
date -d "2025-01-01" "+%s000"
```

## Instructions

1. **Determine the operation**: Based on user request, identify which GitHub operation to perform

2. **Check repository context**: Use `gh repo view` to confirm you're in a git repository when needed

3. **Use appropriate flags**:
   - `--json` for structured output when parsing is needed (CRITICAL for analysis)
   - `--web` to open in browser when user wants visual interface
   - `--repo <owner/repo>` to specify repository explicitly
   - `org:OrgName` in search queries for organization-level searches

4. **Handle JSON output consistently**:
   - **CRITICAL**: For PR searches, ALWAYS use exact JSON fields: `--json title,url,repository,createdAt,state,number`
   - For issue searches, use: `--json number,title,labels,assignees,state,createdAt`
   - For bulk analysis, pipe to `jq` for advanced filtering and aggregation
   - Never vary the JSON fields - consistency is required for reliable parsing

5. **Handle common patterns**:
   - When creating PRs/issues, use interactive mode or provide all required fields
   - For viewing items, use formatted output with `--json` when you need to extract specific data
   - For large result sets, handle pagination or break down queries by time period/repository
   - Separate authored vs reviewed PRs using `-- -author:"username"` filter
   - Always check command success and provide user-friendly feedback

6. **Advanced analysis workflows**:
   - **ALWAYS use flag syntax** for author/reviewer date-bounded searches: `--author="user" --updated=">=DATE"`
   - Calculate date ranges for time-bounded searches using cross-platform date commands
   - Aggregate results across multiple queries (e.g., by author + by reviewer)
   - Use `-- -author:"username"` at end of command to exclude author from reviewed PRs
   - Create summary statistics and generate markdown reports
   - Generate URLs for result sets that users can bookmark
   - Correlate PR titles with Jira ticket IDs or epic references

7. **Pagination and limits**:
   - GitHub search returns max 100 results per query by default
   - For large datasets, break down by repository or time period
   - Use `--limit` flag to control result count (max varies by command)
   - If hitting API limits, refine search scope or add incremental delays

8. **Error handling**:
   - If `gh` is not installed, inform user to install it
   - If authentication fails, guide user to run `gh auth login`
   - For permission errors, explain required access level
   - For API rate limits, suggest narrowing search scope or waiting

## Examples

### Basic Operations

#### View Current Repository PRs
```bash
gh pr list --state all --limit 20
```

#### Create an Issue with Labels
```bash
gh issue create --title "Bug: Login fails" --body "Description here" --label bug,priority-high
```

#### Checkout and Review a PR
```bash
gh pr checkout 123
gh pr diff 123
gh pr review 123 --approve
```

#### View Workflow Status
```bash
gh workflow list
gh run list --workflow=ci.yml --limit 5
```

### Advanced Search & Analysis

#### Analyze Engineer's PR Activity Over Time Period
```bash
# Calculate date 6 months ago (cross-platform)
START_DATE=$(date -d "6 months ago" "+%Y-%m-%d" 2>/dev/null || date -j -v-6m "+%Y-%m-%d")
END_DATE=$(date "+%Y-%m-%d")

# Search authored PRs - USE FLAG SYNTAX
gh search prs --author="username" --updated=">=$START_DATE" --updated="<=$END_DATE" --json title,url,repository,createdAt,state,number

# Search reviewed PRs (excluding authored) - CRITICAL: use -- -author at end
gh search prs --reviewed-by="username" --updated=">=$START_DATE" --updated="<=$END_DATE" --json title,url,repository,createdAt,state,number -- -author:"username"

# Optional: filter by org (add as query string)
gh search prs --author="username" --updated=">=$START_DATE" --updated="<=$END_DATE" --json title,url,repository,createdAt,state,number "org:DataDog"
```

#### Organization-Level PR Search with Links
```bash
# Generate searchable PR link
# https://github.com/pulls?q=is:pr+author:username+merged:2025-05-01..2025-11-01+org:DataDog

gh search prs "is:pr author:username merged:2025-05-01..2025-11-01 org:DataDog"
```

#### Count PRs by Repository
```bash
# Use flag syntax for date filtering
gh search prs --author="username" --updated=">=2025-01-01" --json title,url,repository,createdAt,state,number | \
  jq -r '.[].repository.nameWithOwner' | sort | uniq -c | sort -rn
```

#### Extract PR Statistics
```bash
# Get PR titles, URLs, and dates for reporting - use consistent JSON fields
gh search prs --author="username" --updated=">=2025-01-01" --json title,url,repository,createdAt,state,number | \
  jq -r '.[] | "[\(.title)](\(.url)) - \(.repository.nameWithOwner) - \(.createdAt[:10])"'
```

#### Search Issues with Complex Filters
```bash
# Find high-priority bugs assigned to team
gh search issues "is:open label:bug label:priority-high team:backend-team"

# Find stale issues
gh search issues "is:open updated:<2025-01-01"
```

#### Search Repositories with JSON
```bash
# Search repos with correct JSON fields (fullName and stargazersCount)
gh search repos "datadog" --limit 10 --json name,fullName,stargazersCount,description

# Filter and format with jq
gh search repos "machine-learning stars:>1000" --limit 20 --json fullName,stargazersCount | \
  jq -r '.[] | "\(.fullName) - \(.stargazersCount) stars"'
```

## Cross-Platform Integration Patterns

### Linking to Jira
```bash
# Extract Jira ticket IDs from PR titles and correlate
gh search prs --author="username" --json title,url | \
  jq -r '.[] | select(.title | test("JIRA-[0-9]+")) | "\(.title): \(.url)"'
```

### Generating Report Links
When generating reports or summaries:
- **Format**: `[descriptive count](full-url)`
- **Examples**:
  - `[40 authored PRs](https://github.com/pulls?q=is:pr+author:username+merged:2025-05-01..2025-11-01+org:DataDog)`
  - `[30 reviewed PRs](https://github.com/pulls?q=is:pr+reviewed-by:username+-author:username+merged:2025-05-01..2025-11-01+org:DataDog)`
- Always include org-level or repo-specific search URLs for user reference

## Datadog dual-org search

Datadog has two GitHub orgs. Check the migration table in `team-context.md` to know which org a repo belongs to today.

**EMU handle derivation** (for any Datadog employee): take their email local-part (before `@`), replace dots with hyphens, append `_ddog`. Example: `minglian.pan` → `minglian-pan_ddog`. Always derive from the email — never guess from the display name.

**Dual-handle search pattern** for any engineer activity query:

```bash
# Step 1: legacy handle in DataDog org
gh search prs --author="<legacy-handle>" --updated=">=DATE" --updated="<=DATE" \
  --json title,url,repository,createdAt,state,number "org:DataDog"

# Step 2: EMU handle in ddoghq org
gh search prs --author="<emu-handle>" --updated=">=DATE" --updated="<=DATE" \
  --json title,url,repository,createdAt,state,number "org:ddoghq"

# Step 3: union both results, dedup by (repository.nameWithOwner + number)
# If ddoghq returns 0 results: flag "EMU handle may be mis-derived — verify"
```

**Auth-switch trigger:** if any `gh` command returns `HTTP 404`, `403`, `Bad credentials`, `SAML enforcement`, or `Not Found` on a known repo, apply the recovery protocol from `git-workflows.md` before retrying.

## Tips

- Use `--help` with any command to see all available options
- **Critical**: For analysis work, always use `--json` with specific fields for consistency
- Use `--web` to quickly open items in browser
- Combine with `jq` for complex JSON parsing and aggregation
- Check `gh status` to see pending notifications and review requests
- For large datasets (>100 items), break queries by repository or time period
- Generate clickable GitHub search URLs for users to explore results further
- Use `-- -author:"username"` pattern to exclude author from reviewed-by searches
- Calculate relative dates using platform-specific commands for cross-platform compatibility
