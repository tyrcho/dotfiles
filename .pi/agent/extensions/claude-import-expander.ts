/**
 * Claude Import Expander Extension
 *
 * Loads ~/.claude/CLAUDE.md at session start, recursively expands every
 * `@<path>` import line (Claude Code's @import syntax), and appends the
 * fully-resolved content to the system prompt on every agent turn.
 *
 * Why: Pi loads AGENTS.md/CLAUDE.md context files as raw text and does NOT
 * follow Claude Code's `@path` import syntax. This extension performs that
 * expansion so the entire ruleset is available every session, staying in
 * sync with the source files (re-read on each session start / /reload).
 *
 * Import line syntax recognized (one per line):
 *   - @~/.claude/rules/foo.md
 *   - @./relative.md
 *   - @/abs/path.md
 *   - - @~/.claude/rules/Some File.md        (markdown bullet)
 * Leading/trailing whitespace and an optional leading `- ` bullet are allowed.
 * Paths may contain spaces. Relative paths resolve against the importing
 * file's directory. `~` expands to the home directory. Cycles are guarded.
 *
 * Override the source file with PI_CLAUDE_RULES_FILE.
 */

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DEFAULT_SOURCE = path.join(os.homedir(), ".claude", "CLAUDE.md");

// Matches an @import line: optional bullet, then @, then a non-space path to EOL.
const IMPORT_RE = /^\s*-?\s*@([^\s].*?)\s*$/;

function resolveImport(ref: string, importingFile: string): string {
	let p = ref.trim();
	if (p.startsWith("~")) p = path.join(os.homedir(), p.slice(1));
	if (!path.isAbsolute(p)) p = path.resolve(path.dirname(importingFile), p);
	return p;
}

/**
 * Recursively expand @imports. Returns the file content with import lines
 * replaced by the referenced files' (expanded) contents.
 */
function expand(filePath: string, seen: Set<string>): string {
	const real = fs.realpathSync(filePath);
	if (seen.has(real)) return ""; // cycle guard
	seen.add(real);

	let content: string;
	try {
		content = fs.readFileSync(filePath, "utf-8");
	} catch {
		return "";
	}

	const out: string[] = [];
	for (const line of content.split("\n")) {
		const m = line.match(IMPORT_RE);
		if (!m) {
			out.push(line);
			continue;
		}
		const resolved = resolveImport(m[1], filePath);
		if (fs.existsSync(resolved) && fs.statSync(resolved).isFile()) {
			// Replace the import line with the expanded referenced file.
			out.push(expand(resolved, seen));
		} else {
			// Not a resolvable file path — keep the original line verbatim.
			out.push(line);
		}
	}
	return out.join("\n");
}

export default function claudeImportExpander(pi: ExtensionAPI) {
	let expandedBody = "";
	let sourceFile = DEFAULT_SOURCE;

	pi.on("session_start", async (_event, ctx) => {
		sourceFile = process.env.PI_CLAUDE_RULES_FILE
			? path.resolve(process.env.PI_CLAUDE_RULES_FILE.replace(/^~/, os.homedir()))
			: DEFAULT_SOURCE;

		if (!fs.existsSync(sourceFile)) {
			expandedBody = "";
			return;
		}

		try {
			expandedBody = expand(sourceFile, new Set<string>());
		} catch (error) {
			expandedBody = "";
			ctx.ui.notify(
				`claude-import-expander: failed to read ${sourceFile}: ${error}`,
				"error",
			);
		}
	});

	pi.on("before_agent_start", async (event) => {
		if (!expandedBody) return;
		return {
			systemPrompt:
				event.systemPrompt +
				`\n\n## Claude Rules (expanded from ${sourceFile})\n\n${expandedBody}\n`,
		};
	});
}
