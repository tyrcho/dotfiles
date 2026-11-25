Pick the skill from the ask. Michel should not have to name it or give its path.

| Ask | Skill |
|---|---|
| Review a PR or a doc, "clobs-review" | `/clobs-review:review`. Apply the fixes and handle PR comments when asked. |
| Save what this session found, "ingest", "raw file" | `/vault-ingest` (clobs-vault) into `cloud-obs-wiki`. From a URL: `/vault-snapshot`. Run `/vault-digest` only when asked. |
| Create or review a Jira epic, initiative, CPFM goal, team OKRs | clobs-jira: `/create-jira-epic`, `/review-jira-epic`, `create-cpfm-initiative`, `create-cpfm-goal`, `plan-team-okrs`, `apply-team-okrs`, `publish-team-okrs`. Dry run first: list what you will create and wait for a go. |
| CLOBS operational report | `clobs-reporting:operational-reporting` |
| On-call report, monthly update email, SLI numbers | `clobs-reporting:oncall-report`, `clobs-reporting:monthly-update-email`, `clobs-slis:sli-numbers` or `sli-monthly-readout` |
| Analyze an engineer's or a team's work, 1:1 prep | `work-analyzer:global-report` or `team-report`. Output goes to the notes vault People folder. |
| Team year-end recap | `team-wrapped:wrapped` |
| Export a Google Doc, Sheet or Slides to Markdown | `gworkspace-export` |
| Publish an HTML page behind a go link | `users/michel.daviot/chonk-share` |
| Find a past session | `find-session` |

The clobs plugins live in `ddoghq-sandbox/experimental` under `teams/cloud-observability/claude-plugin-marketplace/`. When one is not installed, pull main and follow its `SKILL.md` from there instead of asking for the path.
