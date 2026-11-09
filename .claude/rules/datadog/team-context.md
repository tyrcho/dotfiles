# Team Context - AWS Integrations


## Team Repositories

### Core Infrastructure
- DataDog/aws-metadata
- DataDog/cloud-inventory
- DataDog/cloudops
- DataDog/service-discovery-platform

### Serverless & Lambda
- DataDog/datadog-serverless-functions
- DataDog/corpit-lambdas
- DataDog/sre-lambdas

### CloudFormation & IaC
- DataDog/cloudformation-datadog-ctblueprints
- DataDog/cloudformation-template
- DataDog/datadog-aws-controltower
- DataDog/datadog-cloudformation-resources
- DataDog/terraform-aws-log-lambda-forwarder-datadog
- DataDog/terraform-config
- DataDog/terraform-provider-datadog

### Integration Development
- DataDog/dogweb
- DataDog/integrations-internal-core
- DataDog/documentation
- DataDog/oracle-cloud-integration
- DataDog/integrations-management (owns `azure/`, `gcp/`, `scaleway/`)

### Azure Integrations
- ddoghq/azure-proxy (owns the whole repo)
- ddoghq/azureintegrations (owns the whole repo; POC mini repo)
- ddoghq/muttley (owns the whole repo; private)

### Operations & Tooling
- DataDog/consul-config
- DataDog/devtools
- DataDog/dd-go
- DataDog/dd-source
- DataDog/enclave
- ddoghq-sandbox/experimental (moved from DataDog/experimental, which is archived)
- DataDog/logs-backend
- DataDog/logs-ops
- DataDog/on-call

### Kubernetes & Operators
- DataDog/datadog-operator
- DataDog/k8s-resources

### Other
- DataDog/clobs-mini-repo
- DataDog/datadog-api-spec
- DataDog/eclair-scripts
- DataDog/web-ui

### Repos we contribute to but do not own

Checked on 2026-11-04. Source: PRs created since 2026-09-05 by the 25 direct reports (legacy and EMU handles), compared with each repo's CODEOWNERS. None has a CODEOWNERS entry for our teams, so the codeowners tool does not scan them.

| Repo | PRs (60 days) | People | Note |
|------|---------------|--------|------|
| ddoghq/workspaces-dotfiles | 24 | 3 | Developer workspace dotfiles. No CODEOWNERS file. |
| ddoghq-sandbox/leash | 16 | 1 | "Get a leash on your agents". No CODEOWNERS file. |
| ddoghq/dd-analytics | 7 | 5 | Data platform monorepo (Spark, Airflow, Flink, dbt). Large (1 GB+). |
| DataDog/documentation | 6 | 5 | Public docs site. Very large (7 GB+), do not clone for scans. |
| ddoghq/mockros | 4 | 1 | Mocks of common service dependencies, used to verify code changes. No CODEOWNERS file. |
| ddoghq-sandbox/crabber-ai-gateway | 2 | 1 | Rust library for the AI Gateway in the Crabber agent harness. No CODEOWNERS file. |
| ddoghq-sandbox/dogpark | 2 | 1 | "A place for all your good dogs!" |
| DataDog/datadog-cloudformation-resources | 2 | 1 | Listed above as a team repo, but no CODEOWNERS entry for our teams. |
| ddoghq/enclave | 1 | 1 | Listed above as a team repo, but no CODEOWNERS entry for our teams. |
| ddoghq/vault-config | 1 | 1 | |
| ddoghq/interview-questions | 1 | 1 | Private. Migrated from DataDog on 2026-10-20. |

Re-check this list when a new repo shows up in the team's PRs: query each person's PRs, then look for our team handles in the repo's CODEOWNERS.

---

## GitHub org split (DataDog ↔ ddoghq ↔ ddoghq-sandbox)

Datadog has three GitHub orgs we use:

- **`DataDog`** — open-source and legacy internal code. Uses a personal GitHub account. SSO expires daily.
- **`ddoghq`** — internal code. Uses EMU accounts provisioned via Google SSO (`*_ddog` handles). CODEOWNERS teams are `@ddoghq/<team>` there.
- **`ddoghq-sandbox`** — internal sandbox org, same EMU accounts. Hosts `experimental` since 2026-10-22 (`DataDog/experimental` is archived).

Seen once on 2026-11-04: `gh api` returned 404 for `ddoghq-sandbox/experimental` right after the move, while git over SSH worked. It cleared within hours. The cause was not confirmed.

### Mega-repo migration — earliest cutover dates

A repo lives on `ddoghq` on/after its cutover date. Compare against today before choosing the org.

| Repo | Earliest cutover | New path |
|------|-----------------|----------|
| logs-backend | 18 Jun 2026 | ddoghq/logs-backend |
| dd-source | 25 Jun 2026 | ddoghq/dd-source |
| dd-go | 9 Jul 2026 | ddoghq/dd-go |
| dogweb | 16 Jul 2026 | ddoghq/dogweb |
| web-ui | 23 Jul 2026 | ddoghq/web-ui |

### EMU handle rule (for anyone)

Take the Datadog email local-part (before `@`), replace dots with hyphens, append `_ddog`.
Example: `minglian.pan@datadoghq.com` → `minglian-pan_ddog`

The local-part is NOT always `first.last` (compound/accented surnames may differ). Always derive from the email, never from the display name.

### My handles

- Personal: **`tyrcho`** — use for `DataDog/*`
- EMU: **`michel-daviot_ddog`** — use for `ddoghq/*` (not yet logged in as of Jun 2026; run `gh auth login` for ddoghq org)

### Teammate rule

Each teammate has both a legacy handle and an EMU handle (derived from their email by the rule above). When gathering anyone's GitHub activity, query **both** handles and union/dedup results by `repo + PR number`. If someone's ddoghq (EMU) query returns 0 results, flag it: "EMU handle may be mis-derived — verify with `gh auth status`".

### Reference docs

- Org guide: https://datadoghq.atlassian.net/wiki/spaces/DEVX/pages/5750787879
- Mega-repo migration + timeline: https://datadoghq.atlassian.net/wiki/spaces/DEVX/pages/6670516629
