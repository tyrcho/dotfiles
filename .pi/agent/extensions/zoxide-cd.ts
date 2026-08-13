import { execSync } from "node:child_process";
import { basename } from "node:path";
import { SessionManager, type ExtensionAPI, type ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

/**
 * /z <query> — zoxide query then switch pi project context.
 *
 * Runs `zoxide query <query>` to resolve a directory, then forks the
 * current session into a new one rooted at that directory (same logic
 * as the /cd command from pi-powerline-footer).
 *
 * With no args, runs `zoxide query --list` and shows a picker.
 */
export default function (pi: ExtensionAPI) {
  pi.registerCommand("z", {
    description: "zoxide query then switch project directory",
    handler: async (args, ctx) => {
      const query = args.trim();

      let target: string;
      if (query) {
        // Resolve via zoxide: returns the best match path.
        let result: string;
        try {
          result = execSync(`zoxide query -- "${query.replace(/"/g, '\\"')}"`, {
            encoding: "utf8",
            stdio: ["ignore", "pipe", "pipe"],
          }).trim();
        } catch {
          ctx.ui.notify(`zoxide: no match for "${query}"`, "error");
          return;
        }
        if (!result) {
          ctx.ui.notify(`zoxide: no match for "${query}"`, "error");
          return;
        }
        target = result;
      } else {
        // No args: show a picker of recent zoxide entries.
        let list: string;
        try {
          list = execSync("zoxide query --list", {
            encoding: "utf8",
            stdio: ["ignore", "pipe", "pipe"],
          }).trim();
        } catch {
          ctx.ui.notify("zoxide: failed to list entries", "error");
          return;
        }
        const entries = list
          .split("\n")
          .filter(Boolean)
          .map((line) => {
            // format: "<score>\t<path>"
            const tab = line.indexOf("\t");
            return tab >= 0 ? line.slice(tab + 1) : line;
          })
          .slice(0, 30);

        if (entries.length === 0) {
          ctx.ui.notify("zoxide: no entries", "error");
          return;
        }

        const choice = await ctx.ui.select(
          "Jump to:",
          entries.map((p) => ({ value: p, label: basename(p), description: p })),
        );
        if (!choice) return;
        target = choice;
      }

      await switchToDirectory(target, ctx);
    },
  });
}

/**
 * Fork the current session into a new one rooted at `target`,
 * mirroring the /cd command from pi-powerline-footer.
 */
async function switchToDirectory(target: string, ctx: ExtensionCommandContext): Promise<void> {
  if (target === ctx.cwd) {
    ctx.ui.notify(`Already in ${ctx.cwd}`, "info");
    return;
  }

  const sessionFile = ctx.sessionManager.getSessionFile();
  if (!sessionFile) {
    ctx.ui.notify("/z requires a persisted Pi session", "error");
    return;
  }

  await ctx.waitForIdle();
  const nextSession = SessionManager.forkFrom(sessionFile, target);
  const nextSessionFile = nextSession.getSessionFile();

  try {
    const result = await ctx.switchSession(nextSessionFile!, {
      withSession: async (nextCtx) => {
        try {
          process.chdir(nextCtx.cwd);
          nextCtx.ui.notify(`Changed directory to ${nextCtx.cwd}`, "info");
          nextCtx.ui.setTitle(`pi - ${basename(nextCtx.cwd) || nextCtx.cwd}`);
        } catch (error) {
          console.debug("[z-command] Failed to update process cwd after switch:", error);
        }
      },
    });
    if (result.cancelled) {
      try {
        if (nextSessionFile) {
          const { unlinkSync } = await import("node:fs");
          unlinkSync(nextSessionFile);
        }
      } catch {
        // best-effort cleanup
      }
      ctx.ui.notify("Directory change cancelled", "warning");
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    try {
      ctx.ui.notify(`Failed to change directory: ${message}`, "error");
    } catch {
      console.debug("[z-command] Failed to report error:", error);
    }
  }
}
