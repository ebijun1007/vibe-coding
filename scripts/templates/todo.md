Status: Ready

## Assumptions
- The `vc` command must bootstrap `AGENTS.md`, `CLAUDE.md`, `CORE.md`, `CUSTOM_PROMPTS.md`, and `todo.md` only when they are missing; if a user already has content, the command must not overwrite, truncate, or re-touch those files.
- Even legacy symlinks (e.g., `CLAUDE.md -> AGENTS.md`) count as "existing" and must not be replaced automatically — creation happens only for truly missing paths.
- When `CLAUDE.md`, `CORE.md`, or `todo.md` is missing or empty, the file should be seeded with the exact canonical content from this repo (hard-coded within `scripts/vc` is acceptable). Non-empty files remain untouched.
- `AGENTS.md` can remain empty for now; simply ensure the file exists without seeding.
- `CUSTOM_PROMPTS.md` must be created as an empty file when missing and left untouched afterward (users own its content). Agents must read it at startup (documented in AGENTS/CLAUDE prompts).

## Implementation Plan
1. **Refine pre-flight bootstrap in `scripts/vc`.** Before invoking `osascript`, loop over the markdown filenames (`AGENTS.md`, `CLAUDE.md`, `CORE.md`, `CUSTOM_PROMPTS.md`, `todo.md`) and create them only when `[ ! -e "$file" ]`.
2. **Seed canonical content when blank (excluding AGENTS/CUSTOM_PROMPTS).** For `CLAUDE.md`, `CORE.md`, and `todo.md`, detect whether the file is empty or whitespace-only. If so, write the embedded canonical content (matching the templates under `scripts/templates`). Leave `AGENTS.md` and `CUSTOM_PROMPTS.md` untouched unless missing (in which case `CUSTOM_PROMPTS.md` should be empty).
3. **Idempotent logging.** Track whether files were created and/or seeded. Emit a message indicating which files were created or seeded so users understand when auto-population occurred.
4. **Preserve runtime behavior.** Keep the AppleScript/watcher logic untouched so panes behave exactly as before; only bootstrap/seeding code changes.
5. **Documentation update.** Refresh `README.md` to describe the guaranteed bootstrap behavior (including seeded contents) and clarify that existing user edits are never overwritten. Mention the new `CUSTOM_PROMPTS.md` and the fact that AGENTS/CLAUDE prompt text now lives in `scripts/templates`.

## Test Plan
- `bash tests/vc_creates_markdown_files.sh`
  - Expand to assert that freshly created files (`AGENTS.md`, `CLAUDE.md`, `CORE.md`, `CUSTOM_PROMPTS.md`, `todo.md`) exist, that the seeded files match this repo's contents byte-for-byte, that `CUSTOM_PROMPTS.md` is created empty, existing files (including symlinks) remain untouched, and that empty files get reseeded with the canonical content where applicable.

## Implementation Notes
- Created `scripts/templates/todo.md` with canonical content matching this repo's `todo.md`
- Added seeding logic for `todo.md` in `scripts/vc` at lines 49-55, following the same pattern as AGENTS.md, CLAUDE.md, and CORE.md
- All tests pass successfully
- Documentation update (step 5) remains pending—hand off to design/test agent
