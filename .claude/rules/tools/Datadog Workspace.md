# Datadog workspace (Linux only)

Applies only on a Linux Datadog workspace (`IN_WORKSPACE=1`). On the Mac, ignore this file.

- **GitHub:** the `gh` token in `~/.config/gh/hosts.yml` is invalid on the workspace, so the account switch in `git-workflows.md` does not help. Use `GH_TOKEN="$(ddtool auth github token --org ddoghq)"` in a subshell (wmux-managed, account `michel-daviot_ddog`, works for ddoghq and ddoghq-sandbox). On a 401, ask Michel to run `! ddtool auth github login --org ddoghq` once, then retry. Git over SSH needs none of this.
- **Chonk:** upload with `CHONK_HOST=https://chonk.us1.ddbuild.io`: chonk.us1.prod.dog needs AppGate. Read the published file back from the same host to check it.
- **Quartz / single-file bundles (chonk-share):** set `SINGLE_FILE_BROWSER=$(ls ~/.cache/ms-playwright/chromium-1140/chrome-linux/chrome)`. single-file-cli needs Node 23+ and the workspace has Node 22: preload a `CloseEvent` polyfill with `NODE_OPTIONS=--import=<file>.mjs`, where the file defines `globalThis.CloseEvent` as a subclass of `Event` with `code`, `reason` and `wasClean`. Recreate it when `/tmp` was cleaned.
- **Pushing to `main`** of a repo, even a personal one, is blocked by the auto-mode classifier until Michel says go in the session: ask before pushing.
