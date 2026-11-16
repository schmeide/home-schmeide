# home-schmeide

The home repo for Schmeide. Start agent sessions here. It holds the shared agent instructions and a pointer to every
Schmeide repo. Each repo keeps its own code, history, issues and AGENTS.md.

`CLAUDE.md` only imports this file. Edit `AGENTS.md`, never `CLAUDE.md`.

## Setup

Local checkouts mirror GitHub: `~/github/schmeide/<repo>`, with this repo at `~/github/schmeide/home-schmeide`.

- `make setup` installs the commit-msg hook and clones every missing public repo into `~/github/schmeide`
  (override with `SCHMEIDE_DIR=...`).
- `project` is private: `gh repo clone schmeide/project ~/github/schmeide/project`.
- `make help` lists every target.

## Working across repos

- Read a repo's AGENTS.md before changing it. Where it disagrees with this file, the repo's rules win.
- Work inside each repo on its own branch, and use worktrees for parallel work in one repo.
- File each issue in the repo where the change lands.
- Record decisions and research that cut across repos in `project`.
- When writing a ticket, state its difficulty (hard, standard or mechanical) with a one-line reason. Do not name a model.

## No AI attribution

Commits and pull requests are authored by the person running the agent, in this repo and in every repo below. No
`Co-authored-by` trailer naming Claude or an `anthropic.com` address, no "Generated with Claude Code" footer, no
`claude.ai/code` session link, and no commit authored with an `anthropic.com` address.

- `.claude/settings.json` turns off Claude Code's commit and PR attribution.
- `make setup/hooks` installs `git/hooks/commit-msg`, which rejects those lines in a commit message.
- The Attribution workflow runs `make check/attribution PR=<n>` on every pull request and fails on any of them.

## Other Repos

- project (planning and knowledge base: product, engineering, decisions; an Open Knowledge Format bundle; private):
  `~/github/schmeide/project`. Clone from `git@github.com:schmeide/project.git` if missing. Read its `index.md` first.
- schmeide.app (the software factory: React UI plus a tRPC server that builds apps from `template`):
  `~/github/schmeide/schmeide.app`. Clone from `https://github.com/schmeide/schmeide.app.git` if missing. Start with
  `docs/mvp.md`.
- template (the fixed full-stack TypeScript stack every generated project is copied from): `~/github/schmeide/template`.
  Clone from `https://github.com/schmeide/template.git` if missing. A change here reaches every future project.
- schmeide.com (marketing site, Next.js static export): `~/github/schmeide/schmeide.com`. Clone from
  `https://github.com/schmeide/schmeide.com.git` if missing. Read `docs/ARCHITECTURE.md` first; it vendors the design
  skills in `.claude/skills/`.
- iac (Azure infrastructure: Terraform, Bicep bootstrap, Argo CD): `~/github/schmeide/iac`. Clone from
  `https://github.com/schmeide/iac.git` if missing. The subscription is live: never run an apply or a mutating `az`
  command unless asked in that message.
