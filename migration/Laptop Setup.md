Checklist to set up a personal Mac from the `tyrcho/dotfiles` repo (branch `personal-laptop`, work config stripped).

The repo is cloned at `~/dotfiles`; config files are symlinked into `~` by `migration/link.sh`.

## 1. Base
- [ ] Install Homebrew, sign in to 1Password (enables the 1Password SSH agent used by `~/.ssh/config`).
- [ ] `git clone -b personal-laptop https://github.com/tyrcho/dotfiles ~/dotfiles && ~/dotfiles/migration/link.sh`
- [ ] Put your git email in `~/.gitconfig.local` (untracked): `git config -f ~/.gitconfig.local user.email you@example.com`

## 2. Packages and shell
- [ ] `brew bundle --file ~/dotfiles/migration/Brewfile` (optional, large)
- [ ] oh-my-zsh, plus custom plugins in `~/.oh-my-zsh/custom/plugins/`:
  `djui/alias-tips`, `Aloxaf/fzf-tab`, `reegnz/jq-zsh-plugin` (as `jq`), `zsh-users/zsh-autosuggestions`
- [ ] `git clone https://github.com/z-shell/F-Sy-H ~/F-Sy-H`

## 3. Claude Code
- [ ] `~/.claude/{CLAUDE.md,settings.json,rules,hooks,skills,agents,commands,statusline.sh}` are linked from the dotfiles.
- [ ] Plugins in `settings.json` come from the official `claude-code-plugins` / `claude-plugins-official` marketplaces.

## 4. Apps
- [ ] iTerm2: quit iTerm, then `defaults import com.googlecode.iterm2 ~/dotfiles/migration/iterm2.plist`
- [ ] AltTab: `defaults import com.lwouis.alt-tab-macos ~/dotfiles/migration/alt-tab.plist`
- [ ] Raycast: import your `.rayconfig` export (Settings > Advanced > Import). Not stored in git.
- [ ] Obsidian: open your vaults (git / Google Drive). Vault settings live in each vault's `.obsidian/` folder, not here.
