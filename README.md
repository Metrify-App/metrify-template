<!-- template-only: start -->
> **Metrify template.** Create a repo from it ("Use this template" on GitHub), or bring an
> existing repo in with `sh ../metrify-template/.claude/skills/metrify-sync/scripts/sync.sh <repo>`.
> Then in Claude Code run `/metrify-setup`: it scans the code, asks what it cannot deduce,
> and fills README, CLAUDE.md, `docs/`, the Makefile and the CI. The standard every repo
> follows is [.claude/skills/metrify-sync/STANDARD.md](.claude/skills/metrify-sync/STANDARD.md). After changing an owned file here, run
> `sh .claude/skills/metrify-sync/scripts/bump.sh` (the CI fails until you do); each repo
> picks it up with `/metrify-sync`. Repos' CI compares their version with this repo's `main`,
> read publicly: keep it public.
<!-- template-only: end -->

# <!-- fill: repo-name -->

<!-- fill: 2-3 line pitch: what it does and its place in Metrify -->

## Quick start

<!-- fill: prerequisites (Node for the git hooks, Docker, uv...) -->

```bash
make install   # dependencies and git hooks
make dev
```

`make help` lists every target.

<!-- fill: free sections (API, Rules, Gates...), or delete -->

## Layout

<!-- fill: add the project's top folders and key files to the tree -->

```
.claude/          shared rules and Metrify skills (synced from metrify-template), settings
docs/             FEATURES, ARCHITECTURE, GLOSSARY
.husky/           git hooks
```

## Documentation

- [docs/FEATURES.md](docs/FEATURES.md): what exists today.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): components, data ownership, why.
- [docs/GLOSSARY.md](docs/GLOSSARY.md): the domain's words.
- [CLAUDE.md](CLAUDE.md): rules for agents working here.

## Git hooks & CI

Hooks are installed by `make install` (husky):

- `commit-msg`: Conventional Commits (`type(scope): subject`, at most 72 characters).
- `pre-commit`: blocks files over 10 MB, then `make format-check lint`.
- `pre-push`: on `main`/`develop`, refuses when behind origin; then `make test`.

CI (`.github/workflows/ci.yml`) runs `make install check` through
[metrify-workflows](https://github.com/Metrify-App/metrify-workflows) and the Metrify standard
check on every push to `main` and on pull requests.
