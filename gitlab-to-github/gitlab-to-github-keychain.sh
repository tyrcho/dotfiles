#!/usr/bin/env bash
# Runs gitlab-to-github.sh with tokens read from the macOS keychain.
# Variables already set in the environment win over the keychain.
#
# Store each token once (the value is prompted, not echoed):
#   security add-generic-password -U -a "$USER" -s GITLAB_TOKEN -w
#   security add-generic-password -U -a "$USER" -s GITLAB_MIRROR_TOKEN -w
#   security add-generic-password -U -a "$USER" -s GITHUB_OWNER -w   # optional, defaults to your gh login
set -euo pipefail

main() {
  local name
  for name in GITLAB_TOKEN GITLAB_MIRROR_TOKEN GITHUB_OWNER; do
    [[ -n "${!name:-}" ]] || export "$name=$(keychain_get "$name")"
  done
  [[ -n "$GITHUB_OWNER" ]] || export GITHUB_OWNER="$(gh api user --jq .login 2>/dev/null || true)"
  exec "$(dirname "$(realpath "$0")")/gitlab-to-github.sh" "$@"
}

keychain_get() {
  security find-generic-password -a "$USER" -s "$1" -w 2>/dev/null || true
}

main "$@"
