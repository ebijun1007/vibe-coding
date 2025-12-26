---
name: Refactor
description: Find dead / unneccesary / deprecated code from git diff
author: codex
---

## Goal
Review the current `git diff` and remove dead code, unnecessary code, redundant logic, and deprecated usage.

## Important override for this run
AGENTS.md may prohibit editing files, but **this prompt explicitly authorizes code edits for this refactoring task only**. Keep the scope strictly limited to the refactor described here.

## Process
1. Inspect the full `git diff` and identify changes that introduced:
   - Unused code paths, variables, methods, or modules
   - Redundant checks, duplicated logic, or needless indirection
   - Temporary/debug code (logs, comments, feature flags) that should not ship
   - Deprecated APIs, methods, or patterns (and their safe replacements)
2. Prefer **deleting code** over reorganizing it. Keep the simplest working version.
3. Keep behavior stable:
   - Do not change external interfaces (public methods, endpoints, outputs, data formats) unless the diff already requires it
   - Avoid broad rewrites; refactor only what is necessary to remove waste
4. When replacing deprecated usage, use the project’s standard approach and keep the change minimal.
5. Remove related leftovers:
   - Unused imports
   - Dead branches
   - Unreachable code
   - Commented-out code blocks
6. Validate the result:
   - Run the smallest relevant test/verification step available (tests, lint, or a quick smoke path)
   - If a test needs adjustment because of removal, update it with the smallest change

## Output requirements
- Produce the actual code edits.
- Provide a short summary of what was removed and why.
- If you decide not to remove something, briefly state the reason (e.g., still referenced, unclear behavior risk).

## Guardrails
- Do not introduce new abstractions “just in case”.
- Do not rename broadly or reformat unrelated areas.
- Keep changes local to the diff and its immediate dependencies.
