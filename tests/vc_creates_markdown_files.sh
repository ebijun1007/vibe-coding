#!/usr/bin/env bash
set -euo pipefail

# Verifies scripts/vc bootstraps the required markdown files without overwriting user content.

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
templates_dir="$project_root/scripts/templates"
tmp_home="$(mktemp -d -t vc-test-home-XXXXXX)"
tmp_repo="$(mktemp -d -t vc-test-repo-XXXXXX)"
stub_bin="$(mktemp -d -t vc-test-bin-XXXXXX)"
canonical_claude="$templates_dir/CLAUDE.md"
canonical_core="$templates_dir/CORE.md"
canonical_todo="$templates_dir/todo.md"
files=(AGENTS.md CLAUDE.md CORE.md CUSTOM_PROMPTS.md todo.md)

cleanup() {
  rm -rf "$tmp_home" "$tmp_repo" "$stub_bin"
}
trap cleanup EXIT

if command -v rsync >/dev/null 2>&1; then
  rsync -a --exclude '.git' "$project_root"/ "$tmp_repo"/
else
  cp -R "$project_root"/. "$tmp_repo"/
fi

cat <<'STUB' > "$stub_bin/osascript"
#!/usr/bin/env bash
cat >/dev/null
exit 0
STUB
chmod +x "$stub_bin/osascript"

pushd "$tmp_repo" >/dev/null

chmod +x scripts/vc

rm -f "${files[@]}"

PATH="$stub_bin:$PATH" \
TERM_PROGRAM="iTerm.app" \
HOME="$tmp_home" \
scripts/vc >/dev/null

missing=0
for file in "${files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "[fail] Expected $file to exist after running scripts/vc" >&2
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

# Newly created CLAUDE.md, CORE.md, and todo.md should be seeded with the canonical prompts.
if ! cmp -s "$canonical_claude" CLAUDE.md; then
  echo "[fail] CLAUDE.md was not seeded with the canonical implementation prompt" >&2
  exit 1
fi

if ! cmp -s "$canonical_core" CORE.md; then
  echo "[fail] CORE.md was not seeded with the canonical product brief" >&2
  exit 1
fi

if ! cmp -s "$canonical_todo" todo.md; then
  echo "[fail] todo.md was not seeded with the canonical plan" >&2
  exit 1
fi

if [ -s todo.md ]; then
  echo "[fail] todo.md should be empty on creation" >&2
  exit 1
fi

if [ -s CUSTOM_PROMPTS.md ]; then
  echo "[fail] CUSTOM_PROMPTS.md should be empty on creation" >&2
  exit 1
fi

# Seed custom content and ensure vc preserves it on subsequent runs.
for file in "${files[@]}"; do
  sentinel="existing content for ${file}"
  printf '%s\n' "$sentinel" > "$file"
  cp "$file" ".$file.expected"
done

PATH="$stub_bin:$PATH" \
TERM_PROGRAM="iTerm.app" \
HOME="$tmp_home" \
scripts/vc >/dev/null

for file in "${files[@]}"; do
  if ! cmp -s ".$file.expected" "$file"; then
    echo "[fail] $file was modified even though it already existed" >&2
    exit 1
  fi
done

# Simulate the original symlinked CLAUDE.md and ensure vc leaves it untouched.
rm CLAUDE.md
ln -s AGENTS.md CLAUDE.md

PATH="$stub_bin:$PATH" \
TERM_PROGRAM="iTerm.app" \
HOME="$tmp_home" \
scripts/vc >/dev/null

if [ ! -L CLAUDE.md ]; then
  echo "[fail] CLAUDE.md symlink should not be replaced when it already exists" >&2
  exit 1
fi

# When CLAUDE/CORE/todo exist but are empty, they should be reseeded.
for file in CLAUDE.md CORE.md todo.md; do
  rm -f "$file"
  touch "$file"
done

PATH="$stub_bin:$PATH" \
TERM_PROGRAM="iTerm.app" \
HOME="$tmp_home" \
scripts/vc >/dev/null

if ! cmp -s "$canonical_claude" CLAUDE.md; then
  echo "[fail] Empty CLAUDE.md was not reseeded with the canonical prompt" >&2
  exit 1
fi

if ! cmp -s "$canonical_core" CORE.md; then
  echo "[fail] Empty CORE.md was not reseeded with the canonical brief" >&2
  exit 1
fi

if ! cmp -s "$canonical_todo" todo.md; then
  echo "[fail] Empty todo.md was not reseeded with the canonical plan" >&2
  exit 1
fi

if [ -s todo.md ]; then
  echo "[fail] todo.md should be empty when reseeded" >&2
  exit 1
fi

popd >/dev/null

echo "[pass] scripts/vc bootstrapped markdown files without overwriting content"
