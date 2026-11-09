# gitlab-to-github

`gitlab-to-github.sh` moves a GitLab project to GitHub in two steps:

1. It copies the project's branches and tags into a private GitHub repo.
2. It installs a GitHub Actions workflow in that repo that replicates every push back to GitLab.

GitLab then stays up to date as a read-only replica of GitHub.

A workflow is used instead of a GitLab pull mirror because pull mirroring needs GitLab Premium or Ultimate, while this
works on any tier. It also replicates on each push, whereas a pull mirror updates every 30 minutes unless triggered.

## Requirements

- `git`, `gh`, `jq`, `curl` and `base64`
- Two GitLab tokens, both belonging to a user with the **Maintainer** role on the project:
  - `GITLAB_TOKEN`: scope `api`, used only by the script.
  - `GITLAB_MIRROR_TOKEN`: scope `write_repository`, stored as a secret in the GitHub repo and used by the workflow.

## Usage

```bash
gh auth login
gh auth refresh -s workflow   # required to create the workflow file

export GITHUB_OWNER=your-user-or-org
export GITLAB_TOKEN=...
export GITLAB_MIRROR_TOKEN=...

./gitlab-to-github.sh <gitlab_project_url> [github_repo_name]
```

The GitLab host and project path are read from the URL, so self-hosted GitLab works the same way. The GitHub repo name
defaults to the last part of the project path; pass a second argument to choose another one.

```bash
./gitlab-to-github.sh https://gitlab.com/my-group/my-project
./gitlab-to-github.sh https://gitlab.example.com/my-group/sub/api my-group-api
```

Any of these URL forms work: the project page (`https://gitlab.com/group/project`), a page inside it
(`.../-/tree/main`), the HTTPS clone URL (`.../project.git`) or the SSH clone URL (`git@gitlab.com:group/project.git`,
which is accessed over HTTPS).

The script stops if the target GitHub repo already exists and isn't private. You can safely run it again: a project
whose workflow is already installed is not copied twice, but the secret and GitLab branch settings are refreshed.

### Migrating a whole group

The script handles one project per run. To migrate a group, list its projects and loop:

```bash
# Returns 100 projects at most, so add &page=2 if needed
curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "https://gitlab.com/api/v4/groups/MY-GROUP/projects?include_subgroups=true&archived=false&per_page=100" \
  | jq -r '.[].web_url' > projects.txt

while read -r url; do ./gitlab-to-github.sh "$url" || echo "FAILED: $url"; done < projects.txt
```

Check first that no two projects share the same last path segment, since they would map to the same GitHub repo name.
Try a single project before running a whole group.

## What to expect afterwards

- **GitLab becomes a read-only replica.** Replication force-pushes and prunes, so anything pushed directly to GitLab
  gets overwritten or deleted. The script allows force push on GitLab's protected branches for this.
- **GitLab CI won't run on replicated pushes** because of `-o ci.skip`. Remove that flag from the workflow if GitLab
  pipelines must still run, such as for deployments.
- **Only branches and tags are copied.** Issues, merge requests, wikis, releases and CI config don't move.
- **Projects using Git LFS are refused** with a clear error, rather than copied incompletely. Empty projects are refused
  too.
- **Replication has one gap.** A push only triggers the workflow if that branch contains the workflow file. Older
  branches catch up at the daily 03:17 UTC run.
- **Private repos use Actions minutes.** GitHub Free for personal accounts includes 2,000 minutes per month, and usage is
  rounded up to the minute. The daily run costs about 30 minutes per repo per month, plus about one per push.
- **Replication stops when the token expires.** GitLab tokens must have an expiry date. To rotate it, export the new
  `GITLAB_MIRROR_TOKEN` and run the script again for each project, which refreshes the secret.

## Testing status

The script was tested with real git on local repos and stubbed GitHub and GitLab APIs. It has not yet run against the
real services, so try one project first.
