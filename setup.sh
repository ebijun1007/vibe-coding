#!/usr/bin/env bash
set -e

# 1. Install direnv if missing (Homebrew assumed)
if ! command -v direnv >/dev/null 2>&1; then
  echo "[info] direnv not found. installing..."
  brew install direnv
  echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc 2>/dev/null || true
fi

# 2. Create scripts directory
mkdir -p scripts

# 3. Create AGENTS.md and symbolic link
touch AGENTS.md
ln -sf AGENTS.md CLAUDE.md

# 4. Write .envrc
cat > .envrc <<'EOF'

# Prevent infinite layout calls in spawned panes
if [ -n "$ITERM_LAYOUT_DONE" ]; then
  return
fi

# Only run on iTerm
if [ "$TERM_PROGRAM" = "iTerm.app" ]; then
  osascript ./scripts/iterm-3pane.scpt "$PWD"
fi
EOF

# 5. Write AppleScript for iTerm (keep existing tabs, open a new tab with 4 panes)
cat > scripts/iterm-3pane.scpt <<'EOF'
on run argv
  set workdir to item 1 of argv

  tell application "iTerm"
    -- keep current window, just add a new tab
    set theWindow to current window
    tell theWindow
      create tab with default profile
      set theTab to current tab
    end tell

    -- first session in the new tab
    tell current session of theTab
      -- set a flag so .envrc doesn't run again in this tab
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir
      -- split into left and right
      set leftPane to it
      set rightPane to (split vertically with default profile)
    end tell

    -- split the right pane into 3 sections (top, middle, bottom)
    tell rightPane
      set topRight to it
      set middleBottomPane to (split horizontally with default profile)
    end tell

    tell middleBottomPane
      set middleRight to it
      set bottomRight to (split horizontally with default profile)
    end tell

    -- left pane: watch todo.md (create if not exists)
    tell leftPane
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir & "; [ ! -f todo.md ] && touch todo.md; while true; do clear; cat todo.md; sleep 1; done"
    end tell

    -- top-right: run codex
    tell topRight
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir & "; codex"
    end tell

    -- middle-right: run claude with --dangerously-skip-permissions
    tell middleRight
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir & "; claude --dangerously-skip-permissions"
    end tell

    -- bottom-right: just cd into the repo and stay there
    tell bottomRight
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir
    end tell
  end tell
end run
EOF

echo "[done] Created .envrc and scripts/iterm-3pane.scpt"
echo "Run this once in the repo:  direnv allow"
