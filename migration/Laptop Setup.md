Checklist to rebuild this laptop from the `tyrcho/dotfiles` repo (branch `datadog`). Files referenced below live next to this one in `~/migration/`.

## Before leaving the old laptop

- [ ] Go through `Unpushed Work.md` (local only, not tracked): push or drop each branch, turn stashes into WIP branches (`git stash branch <name>`), commit or discard dirty files.
- [ ] Copy non-git folders you still need: `~/scripts`, `~/backups`, `~/tmp`, `~/maths`, `~/dd/knowledge-aggregation`, `~/dd/Engineering Career Path 2027`.
- [ ] Copy data (external disk or `rsync` over the network):
  - `~/.claude/projects` (session transcripts + auto memory, ~0.5 GB)
  - `~/.claude-mem` (claude-mem DB, ~1.4 GB), or set up claude-mem cloud sync
- [ ] Move secrets through 1Password (never git): `~/.secrets-env.sh`, `~/.secrets/`, `~/.google.env`, `~/.clasprc.json`, `~/.vault`. Export a GPG key only if you use one.
- [ ] Raycast: Settings > Advanced > Export (`.rayconfig`), store it in 1Password.
- [ ] Re-run `brew bundle dump --file ~/migration/Brewfile --force` and commit, if you installed anything since.

## New laptop

### 1. Base
- [ ] Install Homebrew, sign in to 1Password (also brings back the 1Password SSH agent), connect AppGate VPN.
- [ ] Create an SSH key (`ssh-keygen -t ed25519`), add it to GitHub `tyrcho` and `michel-daviot_ddog`. Re-create the commit-signing key `~/.ssh/datadog_git_commit_signing` and register it as a signing key.
- [ ] Clone the dotfiles into the non-empty home:
  ```bash
  cd ~ && git init && git remote add origin git@github.com:tyrcho/dotfiles
  git fetch origin && git checkout -f datadog
  ```

### 2. Packages and shell
- [ ] `brew bundle --file ~/migration/Brewfile`
- [ ] oh-my-zsh, then custom plugins into `~/.oh-my-zsh/custom/plugins/`:
  `djui/alias-tips`, `Aloxaf/fzf-tab`, `reegnz/jq-zsh-plugin` (as `jq`), `zsh-users/zsh-autosuggestions`
- [ ] `git clone git@github.com:z-shell/F-Sy-H ~/F-Sy-H` and `git clone git@github.com:Myzel394/zsh-copilot ~/.zsh-copilot`
- [ ] Language managers: pyenv, rbenv, sdkman, rustup, bun (their own installers).

### 3. Sign in
- [ ] `gh auth login` twice (tyrcho for `DataDog/*`, michel-daviot_ddog for `ddoghq/*`)
- [ ] `ddtool`, `aws-vault`, `gcloud auth login`, Docker/colima, kube contexts
- [ ] Restore secrets from 1Password (list above)

### 4. Repos
- [ ] Re-clone from `repos.tsv` (path + remote). Use sparse checkouts for `dd-source` and `dd-go`:
  ```bash
  while IFS=$'\t' read -r path url; do [ -n "$url" ] && [ ! -d ~/"$path" ] && git clone "$url" ~/"$path"; done < ~/migration/repos.tsv
  ```

### 5. Claude Code
- [ ] Install Claude Code. `~/.claude/{CLAUDE.md,settings.json,rules,hooks,skills,agents,commands}` come from the dotfiles.
- [ ] Add the marketplaces listed in `~/.claude/plugins/known_marketplaces.json`, then install the plugins listed in `installed_plugins.json`.
- [ ] Merge `claude-mcp-servers.json` into `~/.claude.json` (`jq -s '.[0] * .[1]' ~/.claude.json claude-mcp-servers.json`) and re-auth each MCP server on first use.
- [ ] Restore `~/.claude/projects` and `~/.claude-mem`.

### 6. Scheduled jobs
- [ ] `launchctl load ~/Library/LaunchAgents/com.michel.daviot.*.plist` (skip the `.disabled` ones). Check paths inside still match.

### 7. Apps
- [ ] VS Code: turn on Settings Sync, or `xargs -n1 code --install-extension < vscode-extensions.txt`
- [ ] iTerm2: `defaults import com.googlecode.iterm2 iterm2.plist` (iTerm closed)
- [ ] AltTab: `defaults import com.lwouis.alt-tab-macos alt-tab.plist`
- [ ] Raycast: import the `.rayconfig`
- [ ] JetBrains Toolbox + IDE Settings Sync; Obsidian vaults (git / Google Drive); Google Drive app; Recoll (`~/.recoll/recoll.conf` is tracked, rebuild the index)
