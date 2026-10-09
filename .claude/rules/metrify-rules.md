# Metrify rules

Shared by every Metrify repo, loaded with its `CLAUDE.md`. Owned by `metrify-template`:
edit it there, never in a repo (`/metrify-sync` overwrites it).

## Working rules

- Stage and commit only when asked.
- When a point is ambiguous or a structural choice comes up (folders, data model, new
  dependency, API shape), ask options and a recommendation with the question tool before
  acting, also mid-task.
- A task is done when it ran for real: `make check` green, page loaded, request answered.

## Commands

Always through `make`; `make help` lists every target. Every repo has `install`, `dev`,
`format`, `format-check`, `lint`, `typecheck`, `test`, `fix`, and `check`, which is
everything the CI runs.

## Conventions

- Comments say *why*, in one line where possible; the code says what.
- Name things in code, UI and replies with the terms of `docs/GLOSSARY.md`.
- Commits follow Conventional Commits, enforced by `.husky/commit-msg`: lowercase
  kebab-case scope, subject of at most 72 characters, e.g. `feat(auth): add service tokens`.

## Docs

Trust the code over the docs, and say when they disagree.

- `README.md`: running the repo and its layout.
- `docs/FEATURES.md`: what exists. A shipped feature gets its line there.
- `docs/ARCHITECTURE.md`: data ownership, components, why they are split that way.
- `docs/GLOSSARY.md`: the repo's own words; words of another repo link to its glossary.
- After shipping a feature or changing the architecture, run `/metrify-update-docs`.
  Before a commit or PR, run `/metrify-quality`.
