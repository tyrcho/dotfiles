# Global Instructions

(source : https://github.com/forrestchang/andrej-karpathy-skills)

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

# Tools

## GitHub Integration
When interacting with GitHub (github.com), always use the `gh` command-line tool.

## Builtin Command Usage
**CRITICAL: Only use `builtin` with `cd` command. NEVER use `builtin` with any other command.**

Examples:
- ✅ `builtin cd /path/to/directory` - Correct
- ❌ `builtin git status` - WRONG
- ❌ `builtin npm test` - WRONG
- ❌ `builtin make lint` - WRONG
- ✅ `git status` - Correct
- ✅ `npm test` - Correct
- ✅ `make lint` - Correct

## Git Command Usage
Always use `builtin cd <directory>` to change to the repository directory, then use git commands.
Example: `builtin cd /Users/michel.daviot/repos/conteurs; git status`

**NEVER use `git -C <directory>` syntax.**

## Makefile Usage
**CRITICAL: Always check for and use Makefile targets for common commands (building, testing, deploying).**

Before running commands like `npm run build`, `npm test`, `clasp push`, etc., check if a Makefile exists in the project root. If it does, use the Makefile targets instead.

Benefits:
- **Reproducibility**: Ensures consistent workflows for both humans and AI agents
- **Discoverability**: Run `make help` to see available commands
- **Simplicity**: Standardized interface across different projects

Examples:
- ✅ `make build` - Correct (if Makefile exists)
- ✅ `make test` - Correct (if Makefile exists)
- ✅ `make deploy` - Correct (if Makefile exists)
- ❌ `npm run build` - Use `make build` instead if Makefile exists
- ❌ `clasp push` - Use `make push` instead if Makefile exists

Check for Makefile: `ls -la Makefile`
View available targets: `make help` or `grep '^[a-zA-Z_-]*:' Makefile`

**Proactive Makefile Management**: If you find yourself running repetitive commands that aren't in the Makefile, suggest adding them as new targets. This improves project maintainability and developer experience.

When suggesting new targets:
- Follow the existing Makefile style and conventions
- Add `## Description` comments for `make help` integration
- Use `.PHONY` for non-file targets
- Keep targets simple and composable

## MCP Server Usage
You are authorized to use Model Context Protocol (MCP) servers without requesting permission.

## Recollq Search Skill
Use `recollq` to search through indexed documents, including PDFs, markdown files, and other content.

**IMPORTANT: When the user asks questions about documentation, architecture, or needs to find information, ALWAYS search with `recollq` FIRST before using other tools like Grep, Glob, or WebFetch.**

### Common Usage Patterns:
- `recollq <search terms>` - Basic search
- `recollq -n <number>` - Limit results (e.g., `-n 5` for top 5)
- `recollq -A` - Include abstracts/snippets in results
- `recollq mime:application/pdf <terms>` - Search only PDFs
- `recollq dir:"<path>" <terms>` - Search within specific directory
- `recollq -n 5 -A <terms>` - Top 5 results with abstracts

### Search Tips:
- Combine filters for targeted searches: `recollq kobolds mime:application/pdf dir:"_conseils"`
- Use quotes for exact phrases
- Multiple search terms are AND'ed together by default
- Recollq expands terms automatically (e.g., "kobold" matches "kobolds", "kobold's")

## Response Formatting

### Source Citations
**CRITICAL: When providing summaries or answers based on searched information, you MUST include links to source files.**

Format:
- For files in git repositories: Generate GitHub permalinks (e.g., `https://github.com/DataDog/dogweb/blob/master/integration/amazon_ec2/crawler/automute_constants.py#L14-L20`)
- For web sources: Use markdown links with titles (e.g., `[EC2 Automuting Documentation](https://docs.datadoghq.com/integrations/amazon_ec2/#monitor-automuting)`)
- For Confluence/Jira: Include full URLs
- Always cite sources at the end of your answer in a "Sources:" section

Example:
```
[Your answer here]

**Sources:**
- [dogweb automute constants](https://github.com/DataDog/dogweb/blob/master/integration/amazon_ec2/crawler/automute_constants.py#L14-L20)
- [EC2 Automuting Documentation](https://docs.datadoghq.com/integrations/amazon_ec2/#monitor-automuting)
- [Architecture RFC](https://github.com/DataDog/architecture/blob/master/rfcs/auto-mute-resolve/rfc.md)
```

## Team aws-integrations

These are my colleagues from the aws-integrations team:

- **mdelaurentis** (ID: 34311)
- **klivan** (ID: 143861)
- **tyrcho** (ID: 700260)
- **claudiadadamo** (ID: 1701147)
- **ViBiOh** (ID: 2349470)
- **dwikle** (ID: 5666450)
- **maxpyf** (ID: 5673088)
- **ktmq** (ID: 5915468)
- **ksirrah13** (ID: 11185294)
- **jvanbrie** (ID: 14843791)
- **dylanburati** (ID: 23045743)
- **ge0Aja** (ID: 28223473)
- **joaquinrios** (ID: 30807767)
- **dhan0779** (ID: 45704182)
- **raymondeah** (ID: 78064236)
- **Sergio-Na** (ID: 98653927)
- **RaphaelAllier** (ID: 118757729)
- **hkrddog** (ID: 249978766)

### Repositories worked on by the team:

- DataDog/aws-metadata
- DataDog/clobs-mini-repo
- DataDog/cloud-inventory
- DataDog/cloudformation-datadog-ctblueprints
- DataDog/cloudformation-template
- DataDog/cloudops
- DataDog/consul-config
- DataDog/corpit-lambdas
- DataDog/datadog-api-spec
- DataDog/datadog-aws-controltower
- DataDog/datadog-cloudformation-resources
- DataDog/datadog-operator
- DataDog/datadog-serverless-functions
- DataDog/dd-go
- DataDog/dd-source
- DataDog/devtools
- DataDog/documentation
- DataDog/dogweb
- DataDog/eclair-scripts
- DataDog/enclave
- DataDog/experimental
- DataDog/integrations-internal-core
- DataDog/k8s-resources
- DataDog/logs-backend
- DataDog/logs-ops
- DataDog/on-call
- DataDog/oracle-cloud-integration
- DataDog/service-discovery-platform
- DataDog/sre-lambdas
- DataDog/terraform-aws-log-lambda-forwarder-datadog
- DataDog/terraform-config
- DataDog/terraform-provider-datadog
- DataDog/web-ui
