# Datadog DORA Metrics for Cloud Observability teams

- **Team handles:** `aws-integrations`, `azureintegrations` (no hyphen), `gcp-integrations`, `emerging-cloud-integrations`, `cloud-integrations-platform` (CLOP). `integrations-platform` is an old handle with almost no deploys.
- **Per-team numbers come from the `deployment` index**, which credits each deploy to the Service Catalog team of the deployed service. Use `averaged_metrics.change_lead_time_sec`, `review_time_sec` and `time_to_deploy_sec` for lead, review and merge-to-prod times.
- **Don't group the `pull_request` index by team:** it credits a PR to every team that owns a file it touches (24,000–50,000 PRs per team in 2026 Q3). Filter by the team's paths first.
- **`change_failure:true` is a deploy later rolled back or forward in Conductor** (`remediation.type`), not an incident. Deploys count per target, not per release.
- The quarterly baseline and its query are on the Measurements page of the CLOBS AI SDLC assessment (go/clobs/sdlc-ai-assess).
