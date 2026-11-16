# home-schmeide

The home repo for Schmeide. Start agent sessions here. It holds the shared agent instructions and a pointer to every
Schmeide repo. Each repo keeps its own code, history, issues and AGENTS.md.

`CLAUDE.md` only imports this file. Edit `AGENTS.md`, never `CLAUDE.md`.

## What Schmeide is

Schmeide is a software factory. A person describes an app, reviews a plain-language spec, approves it, and an agent
builds the app from a fixed template, checks it and deploys it. **schmeide.app is the main product.** The other repos
support it:

- `template` is the stack every app schmeide.app generates is copied from.
- `iac` is the Azure infrastructure it runs on.
- `schmeide.com` is the marketing site.
- `project` holds the planning: product vision, architecture decisions, research and funding.

Where to look when a question doesn't name a repo:

| The question is about                                              | Look in         |
| ------------------------------------------------------------------ | --------------- |
| The product, its UI, the server, how builds run, "the app"         | `schmeide.app`  |
| The stack, or what every generated app contains                    | `template`      |
| Hosting, Azure, Terraform, Argo CD, deploys                        | `iac`           |
| The marketing site, landing page, public copy                      | `schmeide.com`  |
| Why something was decided, the vision, research, what's planned    | `project`       |
| How agents work across Schmeide, shared skills, commit and PR rules | this repo       |

Default to `schmeide.app` when it is unclear. Read that repo's AGENTS.md first.

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

## Frontend work uses the design skills

All frontend work in Schmeide is designed and built with the skills from
[jakubkrehel/skills](https://github.com/jakubkrehel/skills). That covers every UI in `template`, the schmeide.app UI,
schmeide.com, and every app a schmeide.app worker generates. If a change touches anything a person sees (markup,
styles, components, copy, motion), use the skills for it:

| Work                                 | Skills                                                                        |
| ------------------------------------ | ----------------------------------------------------------------------------- |
| Building from a Figma file or image  | `build-design`                                                                |
| Layout, type, color and polish       | `better-layout`, `better-typography`, `better-colors`, `better-ui`            |
| Copy                                 | `better-writing`                                                              |
| Exploring directions for a component | `variant`, `state-machine`, `break`                                           |
| The accessibility pass               | `better-accessibility`                                                        |
| Reviewing a screen or flow           | `better-interface`                                                            |
| Before opening a UI pull request     | `interface-review`                                                            |

`interface-review`, `variant`, `state-machine`, `break`, `afk` and `explain-interface` only start from a slash command a
person types. An agent working on its own reads that skill's `SKILL.md` and follows it instead.

Where the skills come from:

- This repo vendors all of them in `.claude/skills/`, so every session started here has them. The upstream commit is
  in `.claude/skills/UPSTREAM_COMMIT` and the MIT license in `.claude/skills/LICENSE`. Only the Markdown is copied.
- `template` vendors them in its own `.claude/skills/`. Every generated project is copied from `template`, so every
  schmeide.app worker has them by default. The worker's tool list must include `Skill`.
- schmeide.com vendors its own subset in `.claude/skills/`.
- Update with `make skills/update REF=<commit>`. Pass `DEST=<repo>/.claude/skills` to vendor the same commit into
  another repo, then commit it there on its own branch. Keep every repo on the same commit.

## Engineering skills from mattpocock/skills

This repo vendors the skills in [mattpocock/skills](https://github.com/mattpocock/skills)' Claude Code plugin
(`skills/engineering` and `skills/productivity`) in `.claude/skills/`, next to the design skills, so every session
started here has them: `grill-me`, `grill-with-docs`, `tdd`, `to-spec`, `to-tickets`, `diagnosing-bugs`, `triage`,
`code-review`, `handoff` and the rest. `/ask-matt` says which one fits.

- The upstream commit is in `.claude/skills/UPSTREAM_COMMIT_MATTPOCOCK` and the MIT license in
  `.claude/skills/LICENSE-mattpocock`. The `misc` and `in-progress` skills and the per-agent `agents/` folders are
  left out.
- Update with `make skills/update-pocock REF=<commit>`. Pass `DEST=<repo>/.claude/skills` to vendor the same commit
  into another repo.
- Where one of these skills asks for a ticket or PR, this file's rules still win: state the ticket's difficulty, and
  add no AI attribution.
- Do not also install the `mattpocock-skills` plugin on a machine that works here, or every skill appears twice.

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
- schmeide.app (the main product; the software factory: React UI plus a tRPC server that builds apps from `template`):
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
