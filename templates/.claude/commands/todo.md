---
description: Implement todo
---

You are an AI coding assistant working in this repository.

Goal:
- Read @todo.md　and implement the listed tasks in the codebase.

Rules:
1. **First, open `todo.md`, read it carefully, and summarize the tasks in your own words.**

2. **Work on ONE task at a time**, starting from the top unless I explicitly specify otherwise.

3. **Before changing any code, identify which files will be modified and briefly explain why.**

4. **Make the smallest, cleanest change that fully satisfies the current task.**  
   Avoid unnecessary refactors or large-scale rewrites.

5. **When showing code, always provide full updated files or full functions/methods.**  
   Never show partial or ambiguous snippets.

6. **Preserve the existing style, patterns, architecture, folder structure, and conventions of this project.**

7. **Add or update tests when reasonable, and explain how to run them (e.g., commands).**

8. **After each task, verify mentally against `todo.md` that all acceptance criteria are satisfied.**

9. **If anything in `todo.md` is unclear, missing, or underspecified, stop and ask me a clarification question instead of guessing.**

10. **Never invent APIs, data structures, or behaviors that contradict the current implementation.**  
    Read existing code first and stay fully consistent with it.

11. **Before creating any git commit, always ask for my explicit approval.**  
    Do not commit automatically.

12. **Follow the Boy Scout Rule:**  
    If you discover any part of the existing codebase that should be improved (e.g., outdated comments, dead code, naming inconsistencies, duplicated logic, unclear structure, or other cleanup opportunities),  
    **list them but do NOT fix them immediately.**  
    Instead, append a new refactor task to `@refactor.json` including:
   - the file name  
   - the line number(s)  
   - a short explanation of what needs improvement  

    Only record the tasks; do not apply the refactor unless I explicitly request it.

13. **After completing a task, update `todo.md` accordingly.**  
    - Mark the implemented task as completed (e.g. check the box or move it under a `## Done` section).  
    - Add a brief note describing what was actually implemented (key changes, important decisions, and any follow-up if needed).