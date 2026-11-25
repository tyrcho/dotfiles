Where Michel's work lives. When an ask names no place, write there without asking.

## Where to write

| Output | Place | Git |
|---|---|---|
| Report, comparison, analysis or draft in Markdown ("in my notes", or no place named) | notes vault `ddoghq-sandbox/michel-daviot-notes`, `notes/<Topic>/<Title Case>.md`. One folder per topic, for example `notes/Incident Effort/`, `notes/AI Token Allocation/` | `main`, pull, push |
| OKR, initiative and epic drafts | notes vault `notes/Management/OKRs/<year>/<quarter or cloud>/` | `main` |
| Notes about a direct report, 1:1 prep | notes vault `notes/Management/People/<Cloud>/<Name>/` | `main` |
| AI SDLC assessment | notes vault `notes/AI SDLC Assessment/` (published at go/clobs/sdlc-ai-assess) | `main`, ask before each publish |
| Findings about cloud systems (AWS, Azure, GCP, Datadog products) | `ddoghq-sandbox/experimental` `users/michel.daviot/cloud-obs-wiki`, with `/vault-ingest` into `raw/` | `main` |
| Management knowledge | notes vault `second-brain/` (clobs-vault conventions) | `main` |
| Michel's tools, apps, treemaps, scripts | `ddoghq-sandbox/experimental` `users/michel.daviot/<project>` | `main`, unless a PR already exists |
| Team plugins and skills | `ddoghq-sandbox/experimental` `teams/cloud-observability/claude-plugin-marketplace/<plugin>` | branch and draft PR |
| Team reports | `ddoghq-sandbox/experimental` `teams/cloud-observability/monthly-report` | per its README |
| Agent rules, CLAUDE.md, shared skills | `tyrcho/dotfiles`, branch `datadog` (symlinked into `~/.claude`) | branch and draft PR |

Scratch folders (`~/dogpark-scratch`, `/tmp`, `~/handoffs`) hold working data only. Never leave a deliverable only there.

Both vaults are Obsidian vaults that Michel edits by hand: re-read a file before changing it (see "Files Michel edits by hand" in `git-workflows.md`).

## Checkouts on the workspace

- `~/dd` is a symlink to `~/go/src/github.com/DataDog`. The remotes are on `ddoghq` or `ddoghq-sandbox`, whatever the path says.
- Notes vault: `~/dd/michel-daviot-notes`. Obsidian Git on the laptop auto-commits (`vault backup:`): pull before reading, and check `git log` before redoing a commit.
- experimental: `~/dd/experimental` (full) and `~/experimental` (sparse: `git sparse-checkout add <folder>`). Make worktrees under `~/.cache/worktrees/`.
- Also checked out: `dd-source`, `claude-marketplace`, `datadog-pi-packages`, `devtools`, `workspaces-dotfiles`.

## Published pages

Published with `users/michel.daviot/chonk-share` (`make publish` or `make share`; on a workspace add `CHONK_HOST=https://chonk.us1.ddbuild.io`):

- go/clobs/code-owned: `users/michel.daviot/codeowners-tools`
- go/clobs/monthly-report: `teams/cloud-observability/monthly-report`
- go/clobs/okrs-treemap: `users/michel.daviot/jira-okr-treemap`
- go/clobs/sdlc-ai-assess: notes vault, `make sdlc-assess-publish`
