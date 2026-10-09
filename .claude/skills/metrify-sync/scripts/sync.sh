#!/bin/sh
# Brings a repo up to the Metrify standard from metrify-template.
#   sh ../metrify-template/.claude/skills/metrify-sync/scripts/sync.sh <repo> [--force]
# Owned files are overwritten, seeded files are copied only when missing
# (see ../STANDARD.md). Nothing is committed.
set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

SKILL=.claude/skills/metrify-sync

usage() { printf "usage: sh <metrify-template>/%s/scripts/sync.sh <repo> [--force]\n" "$SKILL"; exit 2; }

[ $# -ge 1 ] || usage
target=$1
force=${2:-}
[ -z "$force" ] || [ "$force" = "--force" ] || usage

src=$(cd "$(dirname "$0")/../../../.." && pwd)
[ -d "$target" ] || { printf "%s: no such directory\n" "$target"; exit 2; }
target=$(cd "$target" && pwd)

# A synced repo carries this script too: only the template may be the source
src_remote=$(git -C "$src" remote get-url origin 2>/dev/null || true)
if [ "$(basename "$src")" != "metrify-template" ] && ! echo "$src_remote" | grep -q 'metrify-template'; then
  printf "%b✗%b %s is not metrify-template: run the template's copy of this script.\n" "$RED" "$NC" "$src"
  exit 2
fi
[ "$src" != "$target" ] || { printf "%b✗%b source and target are the same repo.\n" "$RED" "$NC"; exit 2; }
git -C "$target" rev-parse --git-dir >/dev/null 2>&1 || { printf "%b✗%b %s is not a git repo.\n" "$RED" "$NC" "$target"; exit 2; }

# Overwriting is only safe when git can show and undo it
if [ -n "$(git -C "$target" status --porcelain)" ] && [ "$force" != "--force" ]; then
  printf "%b✗%b %s has uncommitted changes. Commit or stash them, or pass --force.\n" "$RED" "$NC" "$target"
  exit 1
fi

from=$(cat "$target/$SKILL/VERSION" 2>/dev/null || echo none)
to=$(cat "$src/$SKILL/VERSION")
printf "Syncing %s (standard %s -> %s)\n\n" "$target" "$from" "$to"

owned() {
  mkdir -p "$(dirname "$target/$1")"
  rm -rf "${target:?}/$1"
  cp -R "$src/$1" "$target/$1"
  printf "%b↻%b %s\n" "$GREEN" "$NC" "$1"
}

seeded() {
  if [ -e "$target/$1" ]; then
    printf "  %s (kept)\n" "$1"
  else
    mkdir -p "$(dirname "$target/$1")"
    cp -R "$src/$1" "$target/$1"
    printf "%b+%b %s\n" "$GREEN" "$NC" "$1"
  fi
}

printf -- "--- Owned (overwritten)\n"
owned .claude/rules/metrify-rules.md
owned .husky/commit-msg
# Skills dropped from the template go away too
for dir in "$target"/.claude/skills/metrify-*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  if [ ! -d "$src/.claude/skills/$name" ]; then
    rm -rf "$dir"
    printf "%b-%b .claude/skills/%s (removed)\n" "$YELLOW" "$NC" "$name"
  fi
done
for dir in "$src"/.claude/skills/metrify-*/; do
  owned ".claude/skills/$(basename "$dir")"
done

printf -- "\n--- Seeded (copied when missing)\n"
for f in README.md CLAUDE.md docs/FEATURES.md docs/ARCHITECTURE.md docs/GLOSSARY.md \
  Makefile .husky/pre-commit .husky/pre-push .github/workflows/ci.yml \
  .github/pull_request_template.md .claude/settings.json package.json .gitignore; do
  seeded "$f"
done
chmod +x "$target"/.husky/commit-msg "$target"/.husky/pre-commit "$target"/.husky/pre-push \
  "$target"/.claude/skills/metrify-*/scripts/*.sh

printf -- "\n--- Left to the repo\n"
todo=0
if ! grep -q '"husky"' "$target/package.json"; then
  printf "%b!%b package.json has no husky devDependency\n" "$YELLOW" "$NC"; todo=1
fi
if grep -q '<!-- template-only: start -->' "$target/README.md" "$target/CLAUDE.md"; then
  printf "%b!%b README.md / CLAUDE.md are still the template's\n" "$YELLOW" "$NC"; todo=1
fi
if [ -n "$(find "$target/.claude" -type l 2>/dev/null)" ]; then
  printf "%b!%b .claude contains symlinks; the standard wants real files\n" "$YELLOW" "$NC"; todo=1
fi
if [ "$todo" -eq 1 ]; then
  printf "\nNext: in %s, run /metrify-setup.\n" "$target"
else
  printf "Nothing. Next: review 'git diff', then /metrify-quality.\n"
fi
