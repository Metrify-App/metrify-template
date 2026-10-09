#!/bin/sh
# Checks the repo against .claude/skills/metrify-sync/STANDARD.md: the mechanical part only.
# Run from the repo root. Exits 1 when any check fails.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

failures=0

ok() { printf "%b✓%b %s\n" "$GREEN" "$NC" "$1"; }
ko() { printf "%b✗%b %s\n" "$RED" "$NC" "$1"; failures=$((failures + 1)); }

# The template keeps its fill markers on purpose and releases the standard (same test as sync.sh)
is_template=0
if [ "$(basename "$(pwd)")" = "metrify-template" ] \
  || git remote get-url origin 2>/dev/null | grep -q 'metrify-template'; then
  is_template=1
fi

SYNC=.claude/skills/metrify-sync
TEMPLATE=../metrify-template

printf -- "--- Standard files\n"
for f in .claude/rules/metrify-rules.md $SYNC/STANDARD.md $SYNC/VERSION $SYNC/OWNED.sha256 $SYNC/scripts/sync.sh \
  .husky/commit-msg README.md CLAUDE.md docs/FEATURES.md docs/ARCHITECTURE.md docs/GLOSSARY.md \
  Makefile .husky/pre-commit .husky/pre-push .github/workflows/ci.yml \
  .claude/settings.json package.json .gitignore; do
  if [ -f "$f" ]; then ok "$f"; else ko "$f missing"; fi
done

printf -- "\n--- Version\n"
version=$(cat $SYNC/VERSION 2>/dev/null || echo none)

# Owned files must match the fingerprint released with VERSION
stored=$(cat $SYNC/OWNED.sha256 2>/dev/null || echo none)
if [ "$(sh $SYNC/scripts/owned-hash.sh 2>/dev/null)" = "$stored" ]; then
  ok "owned files match standard $version"
elif [ "$is_template" -eq 1 ]; then
  ko "owned files changed since standard $version: run sh $SYNC/scripts/bump.sh"
else
  ko "owned files edited here: edit them in metrify-template, then /metrify-sync"
fi

# The latest standard: the local template, else the public one on GitHub (the CI's case)
latest=""
if [ "$is_template" -eq 1 ]; then
  :
elif [ -f $TEMPLATE/$SYNC/VERSION ]; then
  latest=$(cat $TEMPLATE/$SYNC/VERSION); source=$TEMPLATE
else
  source=Metrify-App/metrify-template
  # Network trouble only warns: a GitHub hiccup should not turn the CI red
  if ! latest=$(curl -fsSL --max-time 10 \
    "https://raw.githubusercontent.com/$source/main/$SYNC/VERSION" 2>/dev/null); then
    latest=""
    msg="standard $version not compared: could not read $SYNC/VERSION from $source"
    printf "%b-%b %s\n" "$YELLOW" "$NC" "$msg"
    [ -z "${GITHUB_ACTIONS:-}" ] || printf "::warning::%s\n" "$msg"
  fi
fi
if [ -n "$latest" ]; then
  if [ "$version" = "$latest" ]; then
    ok "standard $version, same as $source"
  elif [ "$version" -gt "$latest" ] 2>/dev/null; then
    ko "standard $version, ahead of $source at $latest (local template behind? git -C $TEMPLATE pull)"
  else
    ko "standard $version, $source is at $latest: run /metrify-sync"
  fi
fi

# $1 file, then the expected ## headings in order; extra headings in between are allowed
check_sections() {
  file="$1"; shift
  [ -f "$file" ] || return 0
  actual=$(grep -E '^## ' "$file" | sed 's/^## //')
  last=0
  for section in "$@"; do
    line=$(printf "%s\n" "$actual" | grep -nxF "$section" | head -n1 | cut -d: -f1)
    if [ -z "$line" ]; then
      ko "$file: section '## $section' missing"
    elif [ "$line" -lt "$last" ]; then
      ko "$file: section '## $section' out of order"
    else
      ok "$file: ## $section"
      last=$line
    fi
  done
}

printf -- "\n--- README sections\n"
check_sections README.md "Quick start" "Layout" "Documentation" "Git hooks & CI"

printf -- "\n--- CLAUDE.md sections\n"
check_sections CLAUDE.md "Stack" "Commands" "Architecture" "Conventions" "Gotchas"
if [ -f CLAUDE.md ]; then
  lines=$(wc -l < CLAUDE.md)
  if [ "$lines" -le 150 ]; then ok "CLAUDE.md: $lines lines"; else ko "CLAUDE.md: $lines lines (max 150)"; fi
fi

printf -- "\n--- Make verbs\n"
for verb in help install dev format format-check lint typecheck test fix check; do
  if grep -qE "^$verb:" Makefile 2>/dev/null; then ok "make $verb"; else ko "make $verb missing"; fi
done

printf -- "\n--- Skills\n"
for dir in .claude/skills/*/; do
  [ -d "$dir" ] || continue
  if [ -f "$dir/SKILL.md" ]; then ok "$dir"; else ko "$dir has no SKILL.md"; fi
done

printf -- "\n--- No symlinks in .claude\n"
links=$(find .claude -type l 2>/dev/null)
if [ -z "$links" ]; then
  ok "no symlink"
else
  ko "symlinks in .claude (copy their target in instead):"
  printf "%s\n" "$links" | sed 's/^/    /'
fi

printf -- "\n--- Fill markers\n"
markers=$(grep -rn --include='*.md' --include='Makefile' --include='*.yml' '<!-- fill:' \
  README.md CLAUDE.md docs Makefile .github 2>/dev/null)
if [ -z "$markers" ]; then
  ok "no fill marker left"
elif [ "$is_template" -eq 1 ]; then
  printf "%b-%b template repo: %s fill markers expected\n" "$YELLOW" "$NC" "$(printf "%s\n" "$markers" | wc -l)"
else
  ko "fill markers left:"
  printf "%s\n" "$markers" | sed 's/^/    /'
fi
if [ "$is_template" -eq 0 ] && grep -rlq 'template-only: start' README.md CLAUDE.md 2>/dev/null; then
  ko "template-only block left in README.md or CLAUDE.md"
fi

printf "\n"
if [ "$failures" -eq 0 ]; then
  printf "%bStandard: pass%b\n" "$GREEN" "$NC"
else
  printf "%bStandard: %d failure(s)%b\n" "$RED" "$failures" "$NC"
  exit 1
fi
