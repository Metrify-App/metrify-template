# Metrify repo standard

The contract every Metrify repo follows, whatever its stack. The `metrify-*` skills read
this file. Version in `VERSION` next to it, bumped on every change to an owned file.

A **fill marker** `<!-- fill: what goes here -->` flags a part not written yet. A repo is
standard when every file below is present, its version matches the template's, its owned
files match `OWNED.sha256`, and no fill marker is left.

## Owned and seeded files

`metrify-template` is the source; `/metrify-sync` brings a repo up to date, treating files
two ways.

**Owned**: the template's copy wins; the sync overwrites them. Edit them in the template.

| File | Holds |
|---|---|
| `.claude/rules/metrify-rules.md` | The shared rules. Claude Code loads every `.claude/rules/*.md` by itself. |
| `.claude/skills/metrify-*` | The shared skills; `metrify-sync` also carries this file, `VERSION`, `OWNED.sha256` and the scripts. |
| `.husky/commit-msg` | Conventional Commits check. |

**Seeded**: copied when missing, then the repo's own.

| File | Holds |
|---|---|
| `README.md` | For humans: what the repo is, how to run it, where things are. |
| `CLAUDE.md` | For agents: the repo's stack, commands, architecture, conventions, gotchas. |
| `docs/FEATURES.md` | The inventory of what exists and works today. Nothing planned. |
| `docs/ARCHITECTURE.md` | Who owns which data, the components, how they talk, why. |
| `docs/GLOSSARY.md` | The repo's own domain words. |
| `Makefile` | The make verbs below, plus project targets. |
| `.husky/pre-commit`, `.husky/pre-push` | The hooks below, plus project checks. |
| `.github/workflows/ci.yml` | `make install check` and the standard check, on push to `main` and on pull requests. The check compares `VERSION` with the public template's `main`. |
| `.claude/settings.json` | Shared permissions: make verbs and read-only git. |
| `package.json` | husky. |
| `.gitignore` | Git basics. |

`OWNED.sha256` is the fingerprint of the owned files (`scripts/owned-hash.sh`), released
with `VERSION`. A change to an owned file ships with `sh .claude/skills/metrify-sync/scripts/bump.sh`
in the template, which bumps both; `check-standard.sh` fails until it is run. In a repo, a
mismatch means an owned file was edited locally.

A repo adds its own skills and `.claude/rules/*.md` freely; the sync touches only the
`metrify-*` ones. `.claude/` holds real files only, no symlinks: a skill installed
elsewhere (`.agents/skills/`...) is copied in. Other docs (`docs/SPEC.md`, `DEMO.md`...) are free; `CLAUDE.md` lists
them under Docs.

## README sections

In this order. Free sections (API, Gates, Rules...) go between Quick start and Layout.

1. `# <repo-name>` then a 2-3 line pitch: what it does and its place in Metrify.
2. `## Quick start`: prerequisites and the few commands to run it; ends on `make help`.
3. Free sections.
4. `## Layout`: commented tree of the top folders and key files.
5. `## Documentation`: links to `docs/` and any other doc.
6. `## Git hooks & CI`: what each hook and the CI run.

Commands live in `make help` and `CLAUDE.md`; the README shows only the Quick start ones.

## CLAUDE.md

`# <repo-name>`, a 2-3 line pitch, then these sections in order: `## Stack`,
`## Commands`, `## Architecture`, `## Conventions`, `## Gotchas`. An optional `## Docs` at
the end lists docs beyond the standard ones.

Everything shared lives in `.claude/rules/metrify-rules.md`; `CLAUDE.md` holds only what is
true of this repo. Keep it under 150 lines: cache what the agent cannot find by looking
(the reason for a choice, the gotcha), leave one-command lookups to the environment.

## Make verbs

Every repo has these targets, so the CI, the hooks and agents need one command set.

| Verb | Does |
|---|---|
| `help` | Lists targets (default goal). |
| `install` | Installs dependencies, including husky (`npm install`). |
| `dev` | Runs the project locally. |
| `format` / `format-check` | Formats / checks formatting. |
| `lint` | Lints. |
| `typecheck` | Type checks. |
| `test` | Runs the tests. |
| `fix` | `format` + autofixable lint. |
| `check` | `format-check lint typecheck test`: what the CI runs. |

A verb with nothing to do for the stack prints `<verb>: nothing to do` and exits 0.

## Hooks

- `commit-msg`: Conventional Commits, lowercase kebab-case scope, subject at most 72 chars.
- `pre-commit`: blocks files over 10 MB, then `make format-check lint`.
- `pre-push`: on `main`/`develop`, refuses when behind origin; then `make test`.

## FEATURES.md format

```markdown
# Features

What <repo> does today. Everything listed here exists and works; nothing is planned.

**<n> features**, in <m> areas.

## <Area>

| # | Feature | Where |
|---|---|---|
| 1 | <what the user or caller can do, one line> | `<path or route>` |
```

Numbers are stable: a removed feature leaves its number unused.

## GLOSSARY.md format

```markdown
# Glossary

This repo's own words. Code, UI and docs use these terms. A word another Metrify repo
already defines is linked below, not redefined.

**<Term>**: <one-sentence definition>. <Optional: what it is not, the word to avoid.>

Also used here, defined in other repos: [Campaign](https://github.com/Metrify-App/<repo>/blob/main/<glossary>#campaign), ...
```

Alphabetical. Only the repo's own words get a definition; a word another repo's glossary
already defines gets a link, so each word has one definition across Metrify.
