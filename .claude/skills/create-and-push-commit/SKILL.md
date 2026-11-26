---
name: create-and-push-commit
description: >-
  Creates signed commits in a Datadog workspace and pushes only when authorized
  by the user or applicable agent configuration. Preserves human authorship,
  adds agent attribution, and supports pushes without a laptop SSH connection.
  Use for commit or push requests when IN_WORKSPACE=1.
model: sonnet
argument-hint: "[commit | push | commit and push] [files or scope]"
---

# create-and-push-commit

Restored from `ddoghq/claude-marketplace` (removed upstream on 2026-11-18, commit `9d8174168`) because the workspace's managed SessionStart hook still says to use it. Personal repos (`tyrcho/*`) are not covered by the ddtool token below: see `rules/tools/Datadog Workspace.md`.

Use ordinary Git with the workspace's configured signing key. Require
`IN_WORKSPACE=1`. Signing works without a laptop connection once the workspace
has been enrolled and its key unlocked.

## Commit

Stage only the requested changes and preserve other work. Keep the configured
human Git name and email. Resolve the actual agent and model from runtime
context; use its known attribution email, otherwise `noreply@localhost`.
Do not invent an agent identity if it is unknown.

Write the commit message to a temporary file outside the repository:

```text
<subject>

<useful body>

Environment: Datadog workspace

Co-Authored-By: <Agent> <Model> <attribution-email>
```

```bash
git commit -S -F "$MESSAGE_FILE"
```

Remove the message file afterward. A commit-only request ends here: no GitHub
authentication or push is needed.

If signing fails, stop and follow the signer's recovery instructions. The owner
may need to run `workspaces ssh-config <workspace-name>` on their Mac with the
latest CLI. Do not disable signing, use `commit-headless`, or retrieve the
1Password passphrase yourself.

## Push

Push only when authorized by the user or applicable agent configuration; an
explicit “do not push” takes precedence. A push-only request does not authorize
creating or amending a commit, or including staged changes.

Confirm the intended remote and destination branch. Inspect
`git remote get-url --push --all <remote>`; do not guess between multiple push
URLs or silently switch repositories. Record the commit SHA to publish and push
that exact SHA to the destination branch. If outgoing commits are unsigned,
stop; rewriting existing commits requires authorization.

Push to the selected remote first, even without a forwarded SSH agent. Use
[GitHub authentication](references/authentication.md) over HTTPS only if that
push fails to authenticate. After pushing, verify that the destination points
to the recorded SHA and GitHub reports the commit as verified. Local SSH
signature verification may be unavailable when `allowedSignersFile` is unset;
that alone does not mean a commit is unsigned.

Report the commit SHA, branch, and whether the push and verification succeeded.
If an operation fails, inspect local and remote state before retrying: a commit
or push may already have succeeded. Do not force-push or reset work to resolve a
rejection without authorization.
