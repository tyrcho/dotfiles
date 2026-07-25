# Global Instructions

(source : https://github.com/forrestchang/andrej-karpathy-skills)

## General Guidelines

- Always complete the full scope of requested changes before stopping. If a task has multiple parts, confirm all are done before reporting completion.

## MCP & Integrations

- @~/.claude/rules/tools/mcp-integrations.md

### Google Workspace MCP
- @~/.claude/rules/tools/Google Workspace MCP.md

## Core Principles

1. **Think Before Coding**: State assumptions explicitly, surface tradeoffs, ask when unclear
2. **Simplicity First**: Minimum code that solves the problem - no speculative features
3. **Surgical Changes**: Touch only what's necessary, match existing style
4. **Goal-Driven**: Define success criteria, verify each step

For details: See auto memory files below.

## Code Quality

### Coding Style
- @~/.claude/rules/code/coding-style.md

### Software Architecture
- @~/.claude/rules/code/Software Architecture.md

### Claude Plugins
- @~/.claude/rules/code/Claude Plugins.md

## Tool Guidelines

### Git & GitHub
- @~/.claude/rules/process/git-workflows.md

### Development Tools
- @~/.claude/rules/tools/dev-tools.md

### Worktree Isolation
- @~/.claude/rules/tools/Worktree Isolation.md

### Development Process
- @~/.claude/rules/process/dev-process.md

### Approval / Snapshot Tests
- @~/.claude/rules/process/Approval Tests.md

### Observer & Memory Writing
- @~/.claude/rules/process/Observer Memory.md

## Writing & Communication

### Datadog Style Guide
- @~/.claude/rules/writing-style.md

### Confluence Pages
- @~/.claude/rules/process/Confluence Writing.md

### Jira Descriptions
- @~/.claude/rules/tools/Jira Writing.md

## User Lookup & Identity Resolution

- @~/.claude/rules/tools/user-lookup.md

## Visualization & Plotly

- @~/.claude/rules/tools/visualization.md

## Team & Codebase Context

### Direct Reports
- @~/.claude/rules/datadog/direct-reports.md

### AWS Integrations Team + GitHub org split (DataDog ↔ ddoghq)
- @~/.claude/rules/datadog/team-context.md

### Datadog Patterns
- @~/.claude/rules/datadog/datadog-patterns.md
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
