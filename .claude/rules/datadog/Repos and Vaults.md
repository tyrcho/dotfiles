Where Michel's work lives. When an ask names no place, write there without asking.

## Where to write

| Output | Place |
|---|---|
| Report, comparison, analysis or draft in Markdown ("in my notes", or no place named) | notes vault `ddoghq-sandbox/michel-daviot-notes`, `notes/<Topic>/<Title Case>.md`. One folder per topic, for example `notes/Incident Effort/`, `notes/AI Token Allocation/` |
| OKR, initiative and epic drafts | notes vault `notes/Management/OKRs/<year>/<quarter or cloud>/` |
| Notes about a direct report, 1:1 prep | notes vault `notes/Management/People/<Cloud>/<Name>/` |
| AI SDLC assessment | notes vault `notes/AI SDLC Assessment/` (published at go/clobs/sdlc-ai-assess: ask before each publish) |
| Findings about cloud systems (AWS, Azure, GCP, Datadog products) | `ddoghq-sandbox/experimental` `users/michel.daviot/cloud-obs-wiki`, with `/vault-ingest` into `raw/` |
| Management knowledge | notes vault `second-brain/` (clobs-vault conventions) |
| Michel's tools, apps, treemaps, scripts | `ddoghq-sandbox/experimental` `users/michel.daviot/<project>` |
| Team plugins and skills | `ddoghq-sandbox/experimental` `teams/cloud-observability/claude-plugin-marketplace/<plugin>` |
| Team reports | `ddoghq-sandbox/experimental` `teams/cloud-observability/monthly-report` |
| Agent rules, CLAUDE.md, shared skills | `tyrcho/dotfiles`, branch `datadog` (symlinked into `~/.claude`) |

Git: the notes vault and experimental work on `main`, except the team plugins; everything else uses a branch and a draft PR. The rules are in "Repos that work on `main`" in `git-workflows.md`.

Scratch folders (`~/dogpark-scratch`, `/tmp`, `~/handoffs`) hold working data only. Never leave a deliverable only there.

Both vaults are Obsidian vaults that Michel edits by hand: re-read a file before changing it (see "Files Michel edits by hand" in `git-workflows.md`).

## Checkouts on the workspace

- `~/dd` is a symlink to `~/go/src/github.com/DataDog`. The remotes are on `ddoghq` or `ddoghq-sandbox`, whatever the path says.
- Notes vault: `~/dd/michel-daviot-notes`. Obsidian Git on the laptop auto-commits (`vault backup:`): pull before reading, and check `git log` before redoing a commit.
- experimental: `~/dd/experimental` (sparse: `users/michel.daviot`, `teams/cloud-observability`) and `~/experimental` (sparse, other folders). Add a folder with `git sparse-checkout add <folder>`. Make worktrees under `~/.cache/worktrees/`.
- Also checked out: `dd-source`, `claude-marketplace`, `datadog-pi-packages`, `devtools`, `workspaces-dotfiles`.

## Published pages

Each project publishes with its own Makefile target, which calls `users/michel.daviot/chonk-share`. On a workspace, add `CHONK_HOST=https://chonk.us1.ddbuild.io`.

- go/clobs/code-owned: `users/michel.daviot/codeowners-tools`, `make share`
- go/clobs/monthly-report: `teams/cloud-observability/monthly-report`, `make publish`
- go/clobs/okrs-treemap: `users/michel.daviot/jira-okr-treemap`, `make publish`
- go/clobs/sdlc-ai-assess: notes vault, `make sdlc-assess-publish`
