# AGENTS.md

Bevy project. Engine version: see `bevy = ...` in `Cargo.toml` (kit default: **0.19.x**).

## Bevy knowledge
- Before non-trivial Bevy work, load the `bevy` router skill, then the specific sibling skill
  (`bevy-ecs-*`, `bevy-cameras`, `bevy-ui`, `bevy-pbr-materials`, `bevy-testing`, ...).
- Do not trust remembered Bevy APIs. Training data is dominated by older versions
  (`EventReader`, `Trigger<E>`, `SceneBundle`, bundles...). Check skills / docs.rs for the pinned version.
- If `Cargo.toml` pins a Bevy version different from the skills' version, say so before applying their patterns.

## Iteration loop
1. Inspect relevant code; confirm the Bevy version.
2. Load relevant Bevy skills.
3. Make the smallest coherent change.
4. `cargo fmt`
5. `cargo check`
6. `cargo test` (relevant tests)
7. Runtime behavior matters → launch the app (`brp_launch` or `cargo run`).
8. Inspect state through BRP rather than adding temporary logs.
9. Visual/interactive change → screenshot + input tooling.
10. Compare observed behavior with the request; iterate until verified.
11. Shut the app down (`brp_shutdown`) when done.

## Tooling map
| Need | Tool |
|---|---|
| Launch / stop app | MCP `brp_launch` (builds must exist: `cargo build` first) / `brp_shutdown` |
| Logs of launched app | `brp_list_logs`, `brp_read_log` |
| Find entities | `world_find_entities_by_name`, `world_query` |
| Read / change components | `world_get_components`, `world_mutate_components`, `world_insert_components` |
| Read / change resources | `world_get_resources`, `world_mutate_resources` |
| JSON shape for a type | `brp_type_guide` (call before mutating/inserting unfamiliar types) |
| Screenshot | `brp_extras_screenshot` (absolute `path`; whole window, `camera`, or `name`/`entity` crop) → then Read the PNG |
| Keyboard | `brp_extras_send_keys` (KeyCode names, e.g. `KeyW`, `Space`), `brp_extras_type_text` |
| Mouse | `brp_extras_move_mouse`, `brp_extras_click_mouse`, `brp_extras_drag_mouse`, `brp_extras_scroll_mouse` |
| FPS / frame time | `brp_extras_get_diagnostics` |
| Deterministic time, frame-exact waits, scripted runs | `bevy-feedback run` + `--features agent-feedback` (skill: `driving-bevy-games`) |
| Unit / system tests | `cargo test` with a minimal `App` + `app.update()` (skill: `bevy-testing`) |

BRP listens on `127.0.0.1:15702` (override `BRP_EXTRAS_PORT`). Dev tooling lives in `src/dev/`
behind the `dev` Cargo feature (default on).

## Runtime observability
- Give important entities a `Name` (`Name::new("Player")`). Unnamed entities are hard to find over BRP.
- Derive `Reflect` with `#[reflect(Component)]` / `#[reflect(Resource)]` on state you may want to inspect;
  BRP only sees reflected types.
- Keep important state in components/resources, not in locals, statics, or closures.
- Use clear type names; group systems in plugins with explicit ordering.

## Visual work
Compiling ≠ done. For rendering, cameras, lighting, materials, UI, animation, layout:
**launch → wait for stable frame → capture → inspect image → adjust → capture again.**
Window is fixed at 1280x720 in `main.rs` so captures compare across runs.

## Architecture
- Simple, explicit, modular: one plugin per feature area, registered from `src/app.rs`.
- No large abstractions or generic frameworks without a demonstrated need.
- Keep dev/debug tooling in `src/dev/`; never reference it from app code.
- No `.unwrap()` in systems; use `let ... else { return; }`.

## Verification
Report which level was reached, and never claim a higher one without evidence:
1. compiles (`cargo check`)
2. tests pass (`cargo test`)
3. runs (launched, no errors in log)
4. behavior verified (BRP state / input-driven checks)
5. visuals inspected (screenshot viewed)

Quality gate before finishing:
```
cargo fmt --check
cargo check --all-targets
cargo clippy --all-targets -- -D warnings
cargo test
cargo check --release --no-default-features   # proves app builds without dev tooling
```
Runtime/visual checks only when they add value for the change.
