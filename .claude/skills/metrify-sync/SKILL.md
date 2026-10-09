---
name: metrify-sync
description: Brings this repo up to the latest Metrify standard from ../metrify-template - shared rules, metrify skills, commit-msg hook, and any missing seed file.
disable-model-invocation: true
---

# Metrify sync

`STANDARD.md` (next to this file) says which files the template owns and which it only
seeds. `VERSION` is the standard's version.

In `metrify-template` itself there is nothing to sync: change the owned file there and
bump `VERSION` instead.

## 1. Update the template

The template lives at `../metrify-template`. When it is missing, ask the user to clone it
(`git clone git@github.com:Metrify-App/metrify-template.git ../metrify-template`). Then
`git -C ../metrify-template pull --ff-only`.

## 2. Sync

Run the template's copy, the only up-to-date one:
`sh ../metrify-template/.claude/skills/metrify-sync/scripts/sync.sh .`

It refuses a repo with uncommitted changes: ask the user to commit or stash. Pass
`--force` only when the user says so.

## 3. Report

From `git status` and `git diff`: the version move, what changed in each owned file (in
`.claude/rules/metrify-rules.md`, the rules themselves, line by line), and the seed files
added. Leave the changes uncommitted.

When the script ends on `Next: ... /metrify-setup`, say so: the repo is not filled yet.
Otherwise suggest `/metrify-quality`.
