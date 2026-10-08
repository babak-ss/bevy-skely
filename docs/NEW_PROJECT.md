# Starting a new Bevy repository

## Fast path

```powershell
git clone https://github.com/babak-ss/bevy-skely my_game
cd my_game
pwsh scripts/setup.ps1            # bash: scripts/setup.sh
```
Renames crate `bevy_skeleton` → folder name (`-Name x` to override), removes
`tools/brp_smoke`, writes a project README, deletes the setup scripts, starts fresh git history
(`-KeepHistory` to keep the skeleton's), commits, then `cargo fmt` + `cargo check`
(`-SkipBuild` to defer). Then add your own remote: `git remote add origin <url>`.
First build of Bevy takes several minutes; later builds are incremental.

Alternative: `bevy new my_game` (Bevy CLI; uses TheBevyFlock templates) then copy
`AGENTS.md`, `CLAUDE.md`, `src/dev/` and the `[features]` block from this skeleton.

## What the skeleton contains

```
Cargo.toml        bevy 0.19.1; features dev / agent-feedback / fast-compile; dev profiles
Cargo.lock        pinned, verified dependency versions
AGENTS.md         agent rules (Bevy skills, iteration loop, tooling map, verification levels)
CLAUDE.md         "@AGENTS.md" so Claude Code loads the same rules
src/main.rs       App, DefaultPlugins (1280x720 window), AppPlugin, DevPlugin (cfg dev)
src/app.rs        AppPlugin: register application plugins here
src/dev/mod.rs    DevPlugin: BrpExtrasPlugin (+ optional agent-feedback)
assets/
```
Add folders (`src/<feature>/`, `tests/`, `examples/`) only when needed.

## Feature flags

| Feature | Default | Effect |
|---|---|---|
| `dev` | on | `bevy_brp_extras` → BRP HTTP on `127.0.0.1:15702`, screenshot/input/diagnostics methods; `bevy/bevy_remote`, `bevy/png` |
| `agent-feedback` | off | adds `bevy-agent-feedback-plugin` (deterministic time, scripted driver protocol) |
| `fast-compile` | off | `bevy/dynamic_linking` for faster relinks with `cargo run` |

`dev` is default so `cargo run` and MCP `brp_launch` (which launches the built binary and cannot
pass features) always have BRP. Shipping build:
```
cargo build --release --no-default-features
```

Why not `dynamic_linking` by default: binaries then need `bevy_dylib` on the loader path, which
`cargo run` provides but a direct launch (`brp_launch`, double-click) does not.

## Adding BRP to an existing project (manual)

```toml
[dependencies]
bevy_brp_extras = { version = "0.22.10", optional = true }   # match Bevy 0.19
[features]
default = ["dev"]
dev = ["dep:bevy_brp_extras", "bevy/bevy_remote", "bevy/png"]
```
```rust
#[cfg(feature = "dev")]
app.add_plugins(bevy_brp_extras::BrpExtrasPlugin);
```
Minimum without extras (inspection/mutation only, no screenshots/input):
`app.add_plugins((bevy::remote::RemotePlugin::default(), bevy::remote::http::RemoteHttpPlugin::default()))`.

## Optional per-project build speed

- Already in skeleton: `[profile.dev] opt-level = 1`, deps at `opt-level = 3`.
- Linker (Windows MSVC), in `<project>/.cargo/config.toml`:
  ```toml
  [target.x86_64-pc-windows-msvc]
  linker = "rust-lld.exe"
  ```
- `cargo run --features fast-compile` for tight edit/run loops.
- Never put these in the global `~/.cargo/config.toml`.

## Standard commands

```
cargo run                         # dev build with BRP
cargo check --all-targets
cargo test
cargo clippy --all-targets -- -D warnings
cargo fmt --check
cargo check --release --no-default-features
```
Bevy CLI equivalents (optional): `bevy run`, `bevy build`, `bevy run web` (WASM).

## Observability conventions

- `Name::new("...")` on entities you'd want to find (player, cameras, key UI roots, spawners).
- `#[derive(Reflect)]` + `#[reflect(Component)]`/`#[reflect(Resource)]` on gameplay state.
  Bevy 0.19 auto-registers reflected types; `app.register_type::<T>()` only for generics.
- State in components/resources, not statics/closures. Use `States` for app modes.
- One plugin per feature; explicit system sets/ordering.
- Custom metrics via `Diagnostics` (skill `bevy-diagnostics-profiling`); readable over
  `brp_extras_get_diagnostics` for FPS/frame time.
- Expose app-specific debug actions as BRP methods + `register_agent_tool` (bevy_brp_extras)
  only when repeatedly useful.
