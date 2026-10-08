# Bevy skeleton (AI-first)

Starting point for new Bevy 0.19 projects with agent tooling wired in: BRP + `bevy_brp_extras`
(ECS inspection/mutation, screenshots, keyboard/mouse input via the `brp` MCP server), optional
`bevy-agent-feedback-plugin` (deterministic time, scripted runs), and `AGENTS.md` rules.

## New project

```powershell
git clone https://github.com/babak-ss/bevy-skely my_game
cd my_game
pwsh scripts/setup.ps1        # bash: scripts/setup.sh
cargo run
```
Setup is one-shot: renames the crate to the folder name, starts fresh git history, removes
kit-only files (`tools/brp_smoke`, the setup scripts), replaces this README, runs `cargo check`.
Options: `-Name`, `-KeepHistory`, `-KeepSmoke`, `-SkipBuild`, `-Yes`.

Host prerequisites (once per machine): [docs/SETUP.md](docs/SETUP.md). Setup warns if missing.

## Layout

```
src/main.rs      App + window (1280x720, scale 1.0) + plugins
src/app.rs       AppPlugin: your plugins go here
src/dev/         dev-only tooling (feature `dev`, default on)
assets/
AGENTS.md        agent rules; CLAUDE.md imports it
docs/            kit docs: KIT (status), SETUP, NEW_PROJECT, AGENT_TOOLING, TROUBLESHOOTING
tools/brp_smoke  tooling test fixture (kit only)
```

## Maintaining the skeleton

Edit this repo directly; don't run `scripts/setup.*` here (it asks for confirmation before
resetting git history). After bumping versions, re-verify with
`tools/brp_smoke` (see its README) and refresh `Cargo.lock`.
