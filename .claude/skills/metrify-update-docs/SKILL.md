---
name: metrify-update-docs
description: Brings README, CLAUDE.md and docs/ (FEATURES, ARCHITECTURE, GLOSSARY) back in line with the code, asking the user what the code cannot tell. Use after shipping a feature, changing the architecture or commands, introducing a domain word, or when docs drift from code.
---

# Metrify update docs

Read `.claude/skills/metrify-sync/STANDARD.md` first: it gives each doc's job and format.

## 1. Find the change

The baseline is the last commit touching the docs:
`git log -1 --format=%H -- README.md CLAUDE.md docs/`. The change is
`git diff <baseline>` plus untracked files, or the range the user names.

Done when you hold the list of changed files and what each change does.

## 2. Map every change to its doc

For each change, decide where it lands:

| Change | Doc |
|---|---|
| Something a user or caller can now do, or no longer can | `docs/FEATURES.md` row (stable numbers, update the count) |
| A component, data owner, contract or flow | `docs/ARCHITECTURE.md` |
| A new domain word, or a word used two ways | `docs/GLOSSARY.md` (a definition if the word is this repo's, a link if another repo's glossary has it) |
| A command, env var, port, gotcha, convention | `CLAUDE.md` (and README Quick start if a human needs it to run the repo) |
| A top folder or key file | README `## Layout` |
| None of the above (refactor, test, fix) | no doc impact |

Also read each doc against the code it describes: a path, command or feature that no
longer exists is drift too.

Done when every change and every drift has a doc, or an explicit "no doc impact".

## 3. Ask

One question-tool round, at most 4 questions: the proposed edits grouped by doc, each with
your wording as the recommended option, plus what the code cannot tell (why a choice was
made, what a new term means to the domain). Skip the round when every edit is mechanical.

## 4. Apply

Edit the docs. `CLAUDE.md` holds only what is true of this repo: a rule every repo should
follow is a change to `.claude/rules/metrify-rules.md` in metrify-template, so propose it to the
user instead. Keep `CLAUDE.md` under 150 lines.

Done when `bash .claude/skills/metrify-quality/scripts/check-standard.sh` is green and
each item from step 2 is in a doc. Report the edits per file.
