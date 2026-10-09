---
name: metrify-quality
description: Quality gate on three axes - runs make check, checks the repo against the Metrify standard and the docs against the code, reviews the diff against CLAUDE.md. Use before a commit or PR, or when asked for a quality check.
---

# Metrify quality

Three axes, each ends on a verdict: **pass**, or **fail** with findings as `file:line`.
Report only; fix when the user asks.

## 1. Checks

Run `make check`. Fail on a non-zero exit, with the failing verb and its first error.

## 2. Standard and docs

Run `bash .claude/skills/metrify-quality/scripts/check-standard.sh`: standard files, version and owned files against `../metrify-template`,
README and CLAUDE.md sections, make verbs, skills, fill markers. Its failures are findings;
a version behind ends with: run `/metrify-sync`.

Then read the docs against the code (the script cannot):

- Every path, route, command and env var named in README, CLAUDE.md and `docs/` exists.
- `docs/FEATURES.md`: the stated count matches the rows; each row points at real code.
- `CLAUDE.md` holds only this repo's facts: a line that repeats `.claude/rules/metrify-rules.md`
  is a finding.
- Words in the diff that name a domain concept are in `docs/GLOSSARY.md`.

Doc findings end with: run `/metrify-update-docs`.

## 3. Diff review

The diff is staged + unstaged changes, or `git diff $(git merge-base HEAD origin/main)` on
a branch. Review it against `.claude/rules/metrify-rules.md` and `CLAUDE.md` (Conventions, Architecture), one
finding per broken rule, plus correctness bugs you can show with a concrete input.

Done when every file of the diff has been read.

## Report

| Axis | Verdict |
|---|---|
| Checks | pass / fail |
| Standard and docs | pass / fail |
| Diff review | pass / fail |

Then the findings, most severe first.
