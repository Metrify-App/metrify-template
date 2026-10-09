#!/bin/sh
# Prints the fingerprint of the owned files (see ../STANDARD.md). Run from the repo root.
# OWNED.sha256 stores this value, so it is left out of it; VERSION is in.
set -eu

if command -v sha256sum >/dev/null 2>&1; then sha() { sha256sum; }; else sha() { shasum -a 256; }; fi

{
  printf "%s\n" .claude/rules/metrify-rules.md .husky/commit-msg
  find .claude/skills -type f -path '.claude/skills/metrify-*/*' ! -name OWNED.sha256 ! -name .DS_Store
} | LC_ALL=C sort | while IFS= read -r f; do
  if [ -f "$f" ]; then printf "%s %s\n" "$f" "$(sha < "$f" | cut -d' ' -f1)"; else printf "%s missing\n" "$f"; fi
done | sha | cut -d' ' -f1
