#!/usr/bin/env bash
set -e

# Check if running in iTerm
if [ "$TERM_PROGRAM" != "iTerm.app" ]; then
  echo "[error] This command only works in iTerm.app"
  exit 1
fi

# Get current working directory
WORKDIR="$PWD"

VC_TEMPLATE_REPO="${VC_TEMPLATE_REPO:-ebijun1007/vibe-in-iterm}"
VC_TEMPLATE_REF="${VC_TEMPLATE_REF:-master}"
VC_TEMPLATE_ARCHIVE_URL="https://codeload.github.com/${VC_TEMPLATE_REPO}/tar.gz/${VC_TEMPLATE_REF}"

if ! command -v curl >/dev/null 2>&1; then
  echo "[error] curl is required to download template files" >&2
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  echo "[error] tar is required to extract template files" >&2
  exit 1
fi

tmp_dir="$(mktemp -d -t vc-template.XXXXXX)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

archive_path="$tmp_dir/template.tar.gz"

if ! curl -fsSL "$VC_TEMPLATE_ARCHIVE_URL" -o "$archive_path"; then
  echo "[error] Failed to download template archive: $VC_TEMPLATE_ARCHIVE_URL" >&2
  exit 1
fi

tar -xzf "$archive_path" -C "$tmp_dir"

src_root="$(find "$tmp_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
if [ -z "$src_root" ]; then
  echo "[error] Failed to locate extracted template directory" >&2
  exit 1
fi

for path in .claude .codex .design; do
  if [ ! -d "$src_root/$path" ]; then
    echo "[error] Missing $path in template source: $VC_TEMPLATE_REPO@$VC_TEMPLATE_REF" >&2
    exit 1
  fi
done

for path in .claude .codex .design; do
  rm -rf "$WORKDIR/$path"
  cp -R -p "$src_root/$path" "$WORKDIR/$path"
done

CODEX_HOME="$WORKDIR/.codex"
env_exports=()

echo "[done] Workspace prepared for: $WORKDIR"

# Build shared environment exports for the iTerm panes
env_exports+=("CODEX_HOME=$CODEX_HOME")

env_prefix=""
for entry in "${env_exports[@]}"; do
  key=${entry%%=*}
  val=${entry#*=}
  env_prefix+="export $key=$(printf '%q' "$val"); "
done

# Run AppleScript to create iTerm layout
ENV_PREFIX="$env_prefix" osascript <<EOF
on run
  set workdir to "$WORKDIR"
  set envPrefix to (system attribute "ENV_PREFIX")

  tell application "iTerm"
    -- use current session and split it
    tell current session of current window
      -- split into top and bottom
      set topPane to it
      set bottomPane to (split horizontally with default profile)
    end tell

    -- split top pane into left and right
    tell topPane
      set topLeftPane to it
      set topRightPane to (split vertically with default profile)
    end tell

    -- top left pane: run codex in the repo
    tell topLeftPane
      write text "cd " & workdir & "; if command -v codex >/dev/null 2>&1; then " & envPrefix & " codex; else echo \"[warn] codex not found in PATH\"; fi"
    end tell

    -- top right pane: run claude code (dangerously skip permissions)
    tell topRightPane
      write text "cd " & workdir & "; if command -v claude >/dev/null 2>&1; then " & envPrefix & " claude code --dangerously-skip-permissions; else echo \"[warn] claude not found in PATH\"; fi"
    end tell

    -- bottom pane: leave as terminal (just cd to workdir)
    tell bottomPane
      write text "cd " & workdir
    end tell

  end tell
end run
EOF

echo "[done] iTerm layout created for: $WORKDIR"
