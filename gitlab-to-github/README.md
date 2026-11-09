# gitlab-to-github

`gitlab-to-github.sh` moves a GitLab project to GitHub in two steps:

1. It copies the project's branches, tags and Git LFS files into a private GitHub repo.
2. It installs a GitHub Actions workflow in that repo that replicates every push back to GitLab.

GitLab then stays up to date as a read-only replica of GitHub.

A workflow is used instead of a GitLab pull mirror because pull mirroring needs GitLab Premium or Ultimate, while this
works on any tier. It also replicates on each push, whereas a pull mirror updates every 30 minutes unless triggered.

## Requirements

- `git`, `gh`, `jq`, `curl` and `base64`
- [`git-lfs`](https://git-lfs.com), only for projects that use Git LFS
- Two GitLab tokens, both belonging to a user with the **Maintainer** role on the project:
  - `GITLAB_TOKEN`: scope `api`, used only by the script.
  - `GITLAB_MIRROR_TOKEN`: scope `write_repository`, stored as a secret in the GitHub repo and used by the workflow.

## Usage

```bash
gh auth login
gh auth refresh -s workflow   # required to create the workflow file; checked at start

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

The script stops if the target GitHub repo already exists and isn't private. You can safely run it again, for example after fixing an error. Once the GitHub repo has the
default branch, the copy is skipped (branches are pushed atomically, so that means the copy finished), and only the
GitLab settings, the secret and the workflow are checked and completed.

On success, the script prints how to point an existing clone at GitHub:

```bash
git remote set-url origin https://github.com/OWNER/REPO.git   # or git@github.com:OWNER/REPO.git
git fetch --prune origin
```

Branches keep tracking `origin/<branch>`, so nothing else changes. Do this in every clone, since pushes to GitLab are
overwritten by the next replication.

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
- **Empty projects are refused**, since there is nothing to copy.
- **Replication has one gap.** A push only triggers the workflow if that branch contains the workflow file. Older
  branches catch up at the daily 03:17 UTC run.
- **Private repos use Actions minutes.** GitHub Free for personal accounts includes 2,000 minutes per month, and usage is
  rounded up to the minute. The daily run costs about 30 minutes per repo per month, plus about one per push.
- **Replication stops when the token expires.** GitLab tokens must have an expiry date. To rotate it, export the new
  `GITLAB_MIRROR_TOKEN` and run the script again for each project, which refreshes the secret.

## Git LFS

Projects that use Git LFS are supported:

- The script downloads every LFS file from GitLab and uploads it to GitHub before pushing the branches.
- The workflow uploads LFS files to GitLab before pushing the branches, because GitLab rejects a push that points to
  LFS files it doesn't have.
- The workflow keeps LFS files in the GitHub Actions cache between runs, so each run downloads only new files from
  GitHub. Without it, every run would download all of them. The cache is limited to 10 GB per repo; past that, runs
  still work but download more.
- LFS storage and bandwidth on GitHub count against your account's Git LFS quota, which is separate from Actions
  minutes. Check it in your GitHub billing settings before migrating large projects.
- Git LFS is detected from the repo content on each run, so a project that starts using it later is handled too, as
  long as LFS is enabled on the GitLab project.

## Troubleshooting

The script first checks that `GITLAB_TOKEN` works by asking GitLab who it belongs to. When a request fails, the error
names the request, which token it used (only its last 4 characters are shown), GitLab's reply and a likely cause:

```
ERROR: GitLab API returned HTTP 401
  request: GET https://gitlab.com/api/v4/user
  token:   GITLAB_TOKEN (ending in ...ABCD)
  GitLab says: {"message":"401 Unauthorized"}
  hint: the token is invalid, expired or revoked, or was created on another GitLab instance than https://gitlab.com
```

GitHub steps use your `gh auth` login; their errors say which step failed.

## Testing status

The script was tested with real git on local repos and stubbed GitHub and GitLab APIs. It has not yet run against the
real services, so try one project first.
