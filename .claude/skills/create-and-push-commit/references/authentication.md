# GitHub authentication for pushes

Commit signing and GitHub authentication are separate. Use token-authenticated
HTTPS when a push to the selected remote fails to authenticate.

Resolve `OWNER_REPO` from the selected remote's push URL, including workspace
SSH aliases such as `git@ddoghq.github.com:ddoghq/repo.git`. Set `AUTH_ORG` to
`ddoghq` for ddoghq or ddoghq-sandbox repositories, or `DataDog` for DataDog
repositories. Use the intended destination branch as `BRANCH` and the inspected
commit SHA as `PUSH_SHA`.

Use ddtool's saved credentials and on-demand refresh. The subshell below keeps
the token in the process environment; never print it or enable shell tracing.
The explicit HTTPS helper URL bypasses workspace HTTPS-to-SSH URL rewrites, and
command-scoped settings leave shared Git configuration unchanged.

```bash
(
  export GH_HOST=github.com
  GH_TOKEN="$(ddtool auth github token --org "$AUTH_ORG")" || exit
  export GH_TOKEN
  export GIT_TERMINAL_PROMPT=0 GIT_ALLOW_PROTOCOL=https
  git -c credential.helper= -c credential.helper='!gh auth git-credential' \
    push "https::https://github.com/$OWNER_REPO.git" \
    "$PUSH_SHA:refs/heads/$BRANCH" || exit
  git -c credential.helper= -c credential.helper='!gh auth git-credential' \
    ls-remote "https::https://github.com/$OWNER_REPO.git" "refs/heads/$BRANCH" || exit
  gh api "repos/$OWNER_REPO/commits/$PUSH_SHA" --jq '.commit.verification'
)
```

Compare the remote SHA with `PUSH_SHA` and require GitHub's `verified` field to
be true before reporting verified success. For URL-based pushes, update the
selected remote's tracking ref to the published SHA and set the branch's
upstream if needed; do not reset the local branch or include concurrent commits.

If ddtool reports missing or expired credentials, existing `gh` credentials for
the intended human account may be used instead. Obtain them with
`gh auth token --hostname github.com --user <login>` without printing the token,
verify the returned account and target repository access, and use the token with
the same HTTPS commands.

If no usable credentials exist, follow `ddtool auth github login --org <org>`
or the existing gh account's login instructions. Network errors, rate limits,
and repository permission errors require diagnosis rather than another login.
Never put tokens in remote URLs, command arguments, or persistent Git config.
