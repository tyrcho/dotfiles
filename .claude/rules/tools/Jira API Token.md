# Jira / Confluence API token

- The same Atlassian API token works for Jira and Confluence. Its source is 1Password: `op read "op://Private/confluence_api_token/credential"`.
- On the Mac: `source ~/.local/bin/load-creds.sh` (the `creds` alias) exports `JIRA_API_TOKEN` in the current shell.
- On a Linux workspace: it is stored in `~/.jira.env` (chmod 600), which exports `JIRA_API_TOKEN` and `ATLASSIAN_USER_EMAIL`. No shell rc file sources it: run `source ~/.jira.env` before scripts that need it.
- If a script expects `JIRA_USER`, set `JIRA_USER=$ATLASSIAN_USER_EMAIL`.
- Never print the token value.
