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

# 3. Write .envrc
cat > .envrc <<'EOF'
# Use repo-local .codex directory
# export CODEX_HOME="$PWD/.codex"

# Prevent infinite layout calls in spawned panes
if [ -n "$ITERM_LAYOUT_DONE" ]; then
  return
fi

# Only run on iTerm
if [ "$TERM_PROGRAM" = "iTerm.app" ]; then
  osascript ./scripts/iterm-3pane.scpt "$PWD"
fi
EOF

# 4. Write AppleScript for iTerm (keep existing tabs, open a new tab with 3 panes)
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
      -- split into top and bottom
      set topSession to it
      set bottomSession to (split horizontally with default profile)
    end tell

    -- split the top into left and right
    tell topSession
      set topRight to (split vertically with default profile)
      set topLeft to it
    end tell

    -- top-left: run codex
    tell topLeft
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir & "; codex"
    end tell

    -- top-right: run claude
    tell topRight
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir & "; claude"
    end tell

    -- bottom: just cd into the repo and stay there
    tell bottomSession
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir
    end tell
  end tell
end run
EOF

echo "[done] Created .envrc and scripts/iterm-3pane.scpt"
echo "Run this once in the repo:  direnv allow"
