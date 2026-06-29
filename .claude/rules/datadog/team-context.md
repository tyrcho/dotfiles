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

### Operations & Tooling
- DataDog/consul-config
- DataDog/devtools
- DataDog/dd-go
- DataDog/dd-source
- DataDog/enclave
- DataDog/experimental
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

---

## GitHub org split (DataDog ↔ ddoghq)

Datadog has two GitHub orgs:

- **`DataDog`** — open-source and legacy internal code. Uses a personal GitHub account. SSO expires daily.
- **`ddoghq`** — internal code. Uses EMU accounts provisioned via Google SSO (`*_ddog` handles).

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
