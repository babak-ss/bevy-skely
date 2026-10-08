# Bevy AI dev kit

Reference for the skeleton's AI tooling: what is installed on the host, versions, and verified
capabilities.

| Path | Purpose |
|---|---|
| `Cargo.toml`, `src/`, `assets/`, `AGENTS.md`, `CLAUDE.md` | The project skeleton itself |
| `scripts/setup.{ps1,sh}` | One-shot: rename crate, fresh git history, remove kit-only files |
| `docs/SETUP.md` | Reproduce host install (Rust, MSVC, skills, MCP, CLIs) |
| `docs/NEW_PROJECT.md` | Bootstrap standard, feature flags, observability conventions |
| `docs/AGENT_TOOLING.md` | Which tool for inspection, mutation, screenshots, input, determinism |
| `docs/TROUBLESHOOTING.md` | Known issues |
| `tools/brp_smoke/` | Tooling test fixture (removed by setup unless `-KeepSmoke`) |

## Default version strategy

**Bevy 0.19.x** (0.19.1) on Rust stable. Everything in the stack pins the 0.19 line:
`bevy_brp_mcp`/`bevy_brp_extras` 0.22.10, `bevy-agent-feedback-plugin` 0.5, bevy-skills (0.19).
Bevy 0.20 is in RC (2026-10); upgrade only when brp 0.23 + skills + feedback plugin all support it.

## Installed (user scope, Windows 11, verified 2026-10-08)

| Component | Version | Location |
|---|---|---|
| Rust stable (msvc) | rustc 1.99.0, cargo 1.99.0, rustfmt 1.10.0, clippy 0.1.99, rust-analyzer | `~/.cargo`, `~/.rustup` |
| VS 2022 Build Tools (C++) | 17.14 | `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools` |
| bevy-skills (31 skills) | main @ 2026-08 | `~/.claude/skills/bevy*`, `similarity-rs` |
| driving-bevy-games skill | feedback plugin repo | `~/.claude/skills/driving-bevy-games` |
| bevy_brp_mcp | 0.22.10 | `~/.cargo/bin/bevy_brp_mcp.exe`; MCP `brp` in `~/.claude.json` (user scope) |
| bevy-feedback CLI | 0.5.0 | `~/.cargo/bin/bevy-feedback.exe` |
| Bevy CLI | 0.1.0-alpha.2 | `~/.cargo/bin/bevy.exe` (optional) |
| Global agent rule | — | `~/.claude/CLAUDE.md` "Bevy projects" section |

Project-local only (per repo `Cargo.toml`): `bevy`, `bevy_brp_extras`, `bevy-agent-feedback-plugin`.

## Capability status

| Capability | Status | Tool |
|---|---|---|
| Rust build/fmt/clippy/test | verified | cargo |
| Bevy skills loadable by agent | verified | `bevy` router skill loaded in-session |
| MCP server registered + connected | verified | `claude mcp get brp` |
| Agent invokes MCP | verified | headless `claude -p` session ran full workflow |
| App launch automation | verified | `brp_launch`, `bevy-feedback run`, `cargo run` |
| ECS inspection | verified | `world_find_entities_by_name`, `world_get_components` |
| ECS mutation | verified | `world_mutate_components` (`.translation.y`) |
| Resource inspection | verified | `world_get_resources` |
| Keyboard injection | verified | `brp_extras_send_keys`; feedback `key_tap` |
| Mouse injection | verified | `brp_extras_move_mouse` + `click_mouse` |
| Screenshot capture | verified | `brp_extras_screenshot`; feedback `capture_after_frames` |
| Agent inspects screenshot | verified | Read on PNG |
| Deterministic time / frame stepping | verified | feedback `advance_time`, frozen capture identical |
| Graceful shutdown | verified | `brp_shutdown` |
| Release build without dev tooling | verified | `cargo check --release --no-default-features` |
| Bevy CLI build | verified | `bevy build` |
| `bevy lint` | intentionally omitted | needs pinned nightly; latest lint release predates 0.19 |
| Trackpad gestures | unsupported here | macOS only (extras) |
| Gamepad simulation | installed, not verified | `brp_extras_connect_gamepad` etc. |
| WASM build | not verified | skill `bevy-wasm-webgpu`; `bevy run web` |
| Headless/CI capture (Linux xvfb) | not verified | see feedback plugin `docs/ci-linux.md` |
