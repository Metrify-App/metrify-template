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

# The template keeps its fill markers on purpose
is_template=0
grep -q '<!-- template-only: start -->' README.md 2>/dev/null && is_template=1

SYNC=.claude/skills/metrify-sync
TEMPLATE=../metrify-template

printf -- "--- Standard files\n"
for f in .claude/rules/metrify-rules.md $SYNC/STANDARD.md $SYNC/VERSION $SYNC/scripts/sync.sh \
  .husky/commit-msg README.md CLAUDE.md docs/FEATURES.md docs/ARCHITECTURE.md docs/GLOSSARY.md \
  Makefile .husky/pre-commit .husky/pre-push .github/workflows/ci.yml \
  .github/pull_request_template.md .claude/settings.json package.json .gitignore; do
  if [ -f "$f" ]; then ok "$f"; else ko "$f missing"; fi
done

printf -- "\n--- Version\n"
version=$(cat $SYNC/VERSION 2>/dev/null || echo none)
if [ -f $TEMPLATE/$SYNC/VERSION ] && [ "$(pwd)" != "$(cd $TEMPLATE && pwd)" ]; then
  latest=$(cat $TEMPLATE/$SYNC/VERSION)
  if [ "$version" = "$latest" ]; then
    ok "standard $version, same as $TEMPLATE"
    # Owned files are edited in the template only
    for f in .claude/rules/metrify-rules.md .husky/commit-msg; do
      cmp -s "$f" "$TEMPLATE/$f" || ko "$f differs from $TEMPLATE (owned: edit it there)"
    done
    for dir in $TEMPLATE/.claude/skills/metrify-*/; do
      name=$(basename "$dir")
      diff -rq "$dir" ".claude/skills/$name" >/dev/null 2>&1 \
        || ko ".claude/skills/$name differs from $TEMPLATE (owned: edit it there)"
    done
  else
    ko "standard $version, $TEMPLATE is at $latest: run /metrify-sync"
  fi
else
  printf "%b-%b standard %s (no $TEMPLATE to compare with)\n" "$YELLOW" "$NC" "$version"
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
