#!/bin/sh
# Releases a change to the owned files: VERSION + 1 and a new OWNED.sha256.
#   sh .claude/skills/metrify-sync/scripts/bump.sh   (from the metrify-template root)
set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

SYNC=.claude/skills/metrify-sync

# Repos carry this script too: only the template releases a standard
remote=$(git remote get-url origin 2>/dev/null || true)
if [ "$(basename "$(pwd)")" != "metrify-template" ] && ! echo "$remote" | grep -q 'metrify-template'; then
  printf "%b✗%b run from the metrify-template root: owned files are edited there.\n" "$RED" "$NC"
  exit 2
fi

if [ "$(sh $SYNC/scripts/owned-hash.sh)" = "$(cat $SYNC/OWNED.sha256 2>/dev/null)" ]; then
  printf "%b✗%b owned files unchanged since standard %s: nothing to bump.\n" "$RED" "$NC" "$(cat $SYNC/VERSION)"
  exit 1
fi

from=$(cat $SYNC/VERSION)
echo $((from + 1)) > $SYNC/VERSION
sh $SYNC/scripts/owned-hash.sh > $SYNC/OWNED.sha256
printf "%b✓%b standard %s -> %s\n" "$GREEN" "$NC" "$from" "$((from + 1))"
