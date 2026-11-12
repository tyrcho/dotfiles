# Load 1Password credentials into the current shell.
# Must be sourced (not executed) so the variables reach the calling shell:
#   source ~/.local/bin/load-creds.sh   (or the `creds` alias)
# Agents started from this shell afterwards inherit the variables.

if [[ -n "${ZSH_VERSION:-}" && "$ZSH_EVAL_CONTEXT" != *:file* ]] ||
   [[ -n "${BASH_VERSION:-}" && "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "load-creds.sh must be sourced: source ${0}" >&2
  exit 1
fi

export JIRA_API_TOKEN="$(op read 'op://Private/confluence_api_token/credential')"
export GITLAB_TOKEN="$(op read 'op://Private/gitlab_token/credential')"

echo "Loaded JIRA_API_TOKEN, GITLAB_TOKEN" >&2
