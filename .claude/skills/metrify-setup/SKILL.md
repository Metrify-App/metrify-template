---
name: metrify-setup
description: Turns a repo created from metrify-template (or synced into from it) into a standard Metrify repo - scans the code, asks what it cannot deduce, fills README, CLAUDE.md, docs/, Makefile and CI.
disable-model-invocation: true
---

# Metrify setup

Run once per repo. Read `.claude/skills/metrify-sync/STANDARD.md` first: it defines every file, section and make verb
this skill fills. When it is missing, the repo was never synced: ask the user to run
`sh ../metrify-template/.claude/skills/metrify-sync/scripts/sync.sh .` and commit, then
start.

**Never ask what the scan can deduce. Have the deduced facts confirmed. Ask only for the
undeducible.** Budget: three question-tool rounds.

## 1. Scan

Collect, without asking:

- Manifests and their stack: `pyproject.toml`, `package.json`, `go.mod`, `Dockerfile`,
  `docker-compose.yml`, lockfiles, tool configs (ruff, eslint, tsconfig, mypy...).
- Existing commands: Makefile targets, `package.json` scripts, CI steps, husky hooks.
- Existing docs: README, CLAUDE.md, anything in `docs/`, root `*.md`. In an existing
  repo this content is the raw material: move it into the standard sections, drop none,
  and drop only lines `.claude/rules/metrify-rules.md` already says.
- Layout: top two folder levels, entry points, routers, models, migrations.
- `git log --oneline -50` for the domain's words and recurring fixes.
- Neighbour repos, when `../metrify-*` exist: their `docs/GLOSSARY.md` (or
  `../metrify-orchestrator/GLOSSARY.md`) for words already defined, and how they call this
  repo.

Done when every make verb has a candidate command (or "nothing to do") and every filled
section of the standard has either a deduced fact or a question for step 3.

## 2. Confirm the deduced facts

One question-tool round: present the repo name, the stack, the command per make verb, the
CI toolchain, each as a recommended option, so the user corrects
rather than answers.

## 3. Ask the undeducible

One question-tool round, at most 4 questions, each with your best guess as the first option:

- The pitch: what the repo is for and its place in Metrify.
- The fragile areas and gotchas.
- The decisions an agent would otherwise undo, and why.
- Any feature area or term the scan could not name.

## 4. Fill

In this order, replacing every fill marker:

1. `Makefile`: each standard verb runs the confirmed command; `install` keeps
   `npm install` for the hooks; project targets go under `##@ Project`. Existing targets
   stay.
2. `.github/workflows/ci.yml`: the toolchain step(s) for the stack; uncomment the
   `docker` job when the repo has a `Dockerfile`. `.claude/settings.json`: the project targets agents run often.
3. Hooks: an existing repo's own checks in `pre-commit`/`pre-push` stay, next to
   `make format-check lint` and `make test`.
4. `CLAUDE.md`: pitch, then the standard's sections
   from the confirmed facts. Only what is true of this repo.
5. `README.md`: the standard sections, the existing README content moved into them.
6. `docs/FEATURES.md`, `docs/ARCHITECTURE.md`, `docs/GLOSSARY.md`: from the code, in the
   formats of the standard. Every feature line points at a real path or route; a word
   another repo already defines gets a link, not a definition.
7. `package.json`: the repo's name and description, `husky` in devDependencies.
   Each symlink in `.claude/` (`find .claude -type l`) is replaced by a copy of its target
   (`cp -RL`); ask before deleting the target folder it pointed to.
8. Delete every `<!-- template-only: start -->...<!-- template-only: end -->` block.

A fact neither deduced nor confirmed stays a fill marker: a marker is honest, a guess is
not.

## 5. Verify

Run `make install`, `bash .claude/skills/metrify-quality/scripts/check-standard.sh` and
`make check`. Done when all are green, or each remaining failure is a fill marker the user
chose to leave. Report what was filled, what is left, and that `/metrify-quality` and
`/metrify-update-docs` now keep the repo standard.
