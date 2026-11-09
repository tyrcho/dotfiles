#!/usr/bin/env bash
# Copy a GitLab project to a private GitHub repo, then replicate GitHub -> GitLab.
#
# Usage: ./gitlab-to-github.sh <gitlab_project_url> [github_repo_name]
#
#   ./gitlab-to-github.sh https://gitlab.com/my-group/my-project
#   ./gitlab-to-github.sh https://gitlab.example.com/my-group/sub/api my-group-api
#
# The GitLab host and project path are taken from the URL. The GitHub repo name
# defaults to the last part of the project path.
#
# Required environment:
#   GITHUB_OWNER          GitHub user or organization receiving the repo
#   GITLAB_TOKEN          GitLab token, scope "api". Used only by this script.
#   GITLAB_MIRROR_TOKEN   GitLab token, scope "write_repository", Maintainer
#                         role. Stored as a secret in the GitHub repo.
#
# Safe to run again: a finished project is not copied twice.
set -euo pipefail

readonly WORKFLOW_PATH=".github/workflows/replicate-to-gitlab.yml"
readonly SECRET_NAME="GITLAB_MIRROR_TOKEN"

GITLAB_BASE_URL=""
PROJECT_PATH=""

main() {
  (($# >= 1 && $# <= 2)) || usage
  require_setup
  parse_project_url "$1"
  check_gitlab_token
  migrate_project "$PROJECT_PATH" "${2:-${PROJECT_PATH##*/}}"
}

usage() {
  log "Usage: $0 <gitlab_project_url> [github_repo_name]"
  exit 2
}

migrate_project() {
  local path="$1" name="$2" repo project branch description
  repo="$GITHUB_OWNER/$name"
  log "Migrating $GITLAB_BASE_URL/$path to $repo"
  project="$(gitlab_api GET "projects/$(uri_encode "$path")?statistics=true")"
  check_copyable "$project"
  branch="$(jq -r .default_branch <<<"$project")"
  description="$(short_description "$project")"

  ensure_private_repo "$repo" "$description"
  if workflow_installed "$repo"; then
    log "  already copied, keeping GitHub content"
  else
    copy_repository "$path" "$repo" "$branch"
  fi
  allow_force_push "$(jq -r .id <<<"$project")"
  log "  storing $SECRET_NAME secret"
  printf '%s' "$GITLAB_MIRROR_TOKEN" | gh secret set "$SECRET_NAME" --repo "$repo" ||
    die "could not store $(describe_token GITLAB_MIRROR_TOKEN) as a secret in $repo with the 'gh auth' login"
  workflow_installed "$repo" || install_workflow "$path" "$repo" "$branch"
  log "Done: https://github.com/$repo"
}

check_copyable() {
  local project="$1"
  [[ "$(jq -r .default_branch <<<"$project")" != null ]] ||
    die "  empty repository, nothing to copy"
  [[ "$(jq -r '.statistics.lfs_objects_size // 0' <<<"$project")" == 0 ]] ||
    die "  uses Git LFS, which this script does not copy"
}

ensure_private_repo() {
  local repo="$1" description="$2" is_private
  if is_private="$(gh repo view "$repo" --json isPrivate --jq .isPrivate 2>/dev/null)"; then
    [[ "$is_private" == true ]] || die "  $repo exists and is not private"
    return 0
  fi
  log "  creating private repo $repo"
  gh repo create "$repo" --private --description "$description" >/dev/null ||
    die "could not create $repo with the 'gh auth' login (check GITHUB_OWNER and your rights on it)"
}

copy_repository() {
  local path="$1" repo="$2" branch="$3"
  work_dir="$(mktemp -d)"
  trap 'rm -rf "$work_dir"' EXIT
  log "  copying branches and tags"
  git_gitlab clone --quiet --bare "$GITLAB_BASE_URL/$path.git" "$work_dir/repo" ||
    die "$(request_failure "git clone from GitLab failed" "git clone $GITLAB_BASE_URL/$path.git" GITLAB_TOKEN \
      "" "the token needs the 'api' or 'read_repository' scope and access to the project")"
  # No --force: an unrelated repo with the same name is rejected, not overwritten.
  git_github -C "$work_dir/repo" push --quiet "https://github.com/$repo.git" \
    'refs/heads/*:refs/heads/*' 'refs/tags/*:refs/tags/*' ||
    die "git push to https://github.com/$repo.git failed, using the 'gh auth' login." \
      "If the repo already has unrelated history, remove it or pass another repo name."
  gh repo edit "$repo" --default-branch "$branch" >/dev/null ||
    die "could not set default branch '$branch' on $repo with the 'gh auth' login"
}

allow_force_push() {
  local project_id="$1" branch
  log "  allowing force push on GitLab protected branches"
  gitlab_api GET "projects/$project_id/protected_branches?per_page=100" |
    jq -r '.[].name' |
    while IFS= read -r branch; do
      gitlab_api PATCH \
        "projects/$project_id/protected_branches/$(uri_encode "$branch")?allow_force_push=true" \
        >/dev/null
    done
}

workflow_installed() {
  gh api "repos/$1/contents/$WORKFLOW_PATH" --silent 2>/dev/null
}

install_workflow() {
  local path="$1" repo="$2" branch="$3" content
  content="$(render_workflow "$GITLAB_BASE_URL/$path.git" | base64 | tr -d '\n')"
  log "  installing replication workflow"
  gh api --method PUT "repos/$repo/contents/$WORKFLOW_PATH" --silent \
    -f message="Replicate this repository to GitLab" \
    -f branch="$branch" -f content="$content" ||
    die "could not create $WORKFLOW_PATH in $repo with the 'gh auth' login" \
      "(run 'gh auth refresh -s workflow' to grant the workflow scope)"
}

require_setup() {
  local tool
  for tool in git gh jq curl base64; do
    command -v "$tool" >/dev/null || die "missing tool: $tool"
  done
  : "${GITHUB_OWNER:?set GITHUB_OWNER}"
  : "${GITLAB_TOKEN:?set GITLAB_TOKEN}"
  : "${GITLAB_MIRROR_TOKEN:?set GITLAB_MIRROR_TOKEN}"
  export GITLAB_TOKEN
}

# Sets GITLAB_BASE_URL and PROJECT_PATH from a project URL.
parse_project_url() {
  local parsed
  parsed="$(project_url_parts "$1")" || die "not a GitLab project URL: $1"
  read -r GITLAB_BASE_URL PROJECT_PATH <<<"$parsed"
}

# Credentials are read at run time, so tokens never appear in arguments or URLs.
git_gitlab() {
  # shellcheck disable=SC2016  # expanded by git's helper shell, on purpose
  git -c credential.helper= \
    -c credential.helper='!f() { echo username=oauth2; echo "password=$GITLAB_TOKEN"; }; f' "$@"
}

git_github() {
  git -c credential.helper= -c credential.helper='!gh auth git-credential' "$@"
}

# Prints the response body. On failure, explains which request failed and with
# which token, then exits.
gitlab_api() {
  local method="$1" route="$2" url response status
  url="$GITLAB_BASE_URL/api/v4/$route"
  response="$(curl --silent --show-error --request "$method" --write-out '\n%{http_code}' \
    --header @<(printf 'PRIVATE-TOKEN: %s\n' "$GITLAB_TOKEN") "$url")" ||
    die "$(request_failure "GitLab API request could not be sent" "$method $url" GITLAB_TOKEN)"
  status="${response##*$'\n'}"
  response="${response%$'\n'*}"
  [[ "$status" == 2* ]] ||
    die "$(request_failure "GitLab API returned HTTP $status" "$method $url" GITLAB_TOKEN \
      "$response" "$(gitlab_status_hint "$status")")"
  printf '%s\n' "$response"
}

# Fails early with a clear message if GITLAB_TOKEN can't reach the API.
check_gitlab_token() {
  local username
  username="$(gitlab_api GET user | jq -r .username)"
  log "GitLab user: $username"
}

request_failure() {
  local summary="$1" request="$2" token_var="$3" body="${4:-}" hint="${5:-}"
  printf '%s\n  request: %s\n  token:   %s\n' "$summary" "$request" "$(describe_token "$token_var")"
  [[ -z "$body" ]] || printf '  GitLab says: %s\n' "$(printf '%s' "$body" | head -c 300)"
  [[ -z "$hint" ]] || printf '  hint: %s\n' "$hint"
}

log() { echo "$*" >&2; }

die() {
  log "ERROR: $*"
  exit 1
}

# Pure functions

# Prints "<base_url> <project_path>" for a GitLab project URL, such as
# https://gitlab.com/group/sub/project, with an optional trailing ".git", "/"
# or GitLab page suffix ("/-/tree/main"). SSH clone URLs are read as HTTPS.
# Fails on anything else.
project_url_parts() {
  local url="$1"
  # SSH clone URL: git@host:group/project.git
  [[ "$url" =~ ^[^@/[:space:]]+@([^:/[:space:]]+):(.+)$ ]] &&
    url="https://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  [[ "$url" =~ ^(https?://[^/[:space:]]+)/([^[:space:]]+)$ ]] || return 1
  local base="${BASH_REMATCH[1]}" path="${BASH_REMATCH[2]}"
  path="${path%%/-/*}"
  path="${path%%[?#]*}"
  path="${path%/}"
  path="${path%.git}"
  [[ "$path" == */* ]] || return 1
  echo "$base $path"
}

# Names a token variable and shows only its last 4 characters.
describe_token() {
  local name="$1" value="${!1:-}"
  if [[ -z "$value" ]]; then
    echo "$name (empty)"
  else
    echo "$name (ending in ...${value: -4})"
  fi
}

gitlab_status_hint() {
  case "$1" in
    401) echo "the token is invalid, expired or revoked, or was created on another GitLab instance than" \
      "$GITLAB_BASE_URL" ;;
    403) echo "the token lacks the 'api' scope, or its user is not Maintainer on this project" ;;
    404) echo "the project does not exist at this path, or the token's user cannot see it" ;;
    *) echo "" ;;
  esac
}

uri_encode() {
  jq -rn --arg value "$1" '$value | @uri'
}

short_description() {
  jq -r '(.description // "") | gsub("[\\r\\n]+"; " ") | .[0:350]' <<<"$1"
}

render_workflow() {
  local template
  template="$(workflow_template)"
  printf '%s\n' "${template//__GITLAB_URL__/$1}"
}

workflow_template() {
  cat <<'YAML'
name: Replicate to GitLab

on:
  push:
  workflow_dispatch:
  # Catches pushes to branches created before this workflow existed.
  schedule:
    - cron: '17 3 * * *'

concurrency:
  group: replicate-to-gitlab
  cancel-in-progress: true

permissions:
  contents: read

jobs:
  replicate:
    runs-on: ubuntu-latest
    steps:
      - name: Push all branches and tags to GitLab
        env:
          GH_TOKEN: ${{ github.token }}
          GITLAB_TOKEN: ${{ secrets.GITLAB_MIRROR_TOKEN }}
          GITLAB_URL: __GITLAB_URL__
        run: |
          git -c credential.helper='!f() { echo username=x-access-token; echo "password=$GH_TOKEN"; }; f' \
            clone --quiet --bare "https://github.com/$GITHUB_REPOSITORY.git" repo
          git -C repo -c credential.helper='!f() { echo username=oauth2; echo "password=$GITLAB_TOKEN"; }; f' \
            push --quiet --force --prune -o ci.skip "$GITLAB_URL" \
            'refs/heads/*:refs/heads/*' 'refs/tags/*:refs/tags/*'
YAML
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
