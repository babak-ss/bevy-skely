# Agent tooling: what to use when

Two complementary channels into a running app:

- **BRP (`bevy_brp_mcp` + `bevy_brp_extras`)** — interactive. Structured ECS/resource inspection
  and mutation, screenshots, keyboard/mouse/gamepad injection, launch/shutdown, logs. Default choice.
- **Agent feedback (`bevy-feedback` + `bevy-agent-feedback-plugin`)** — scripted. Deterministic
  (frozen) Bevy time, exact frame waits, semantic readiness predicates, completion-confirmed PNGs,
  CI-style run summaries. Use for reproducible interaction tests or animation-timing checks.

Don't use both for the same job. BRP for everything interactive; feedback only when frame/time
determinism matters.

| Capability | Tool |
|---|---|
| Launch | MCP `brp_launch {target_name}` (runs the built binary; run `cargo build` first). Or `cargo run` in background. |
| Status / stop | `brp_status`, `brp_shutdown` (graceful via extras) |
| App logs | `brp_list_logs`, `brp_read_log` |
| ECS inspection | `world_find_entities_by_name`, `world_query`, `world_get_components`, `world_list_components` |
| ECS mutation | `world_mutate_components` (path-based), `world_insert_components`, `world_spawn_entity`, `world_despawn_entity` |
| Resources | `world_list_resources`, `world_get_resources`, `world_mutate_resources` |
| Type JSON format | `brp_type_guide` / `registry_schema` |
| Watch changes | `world_get_components_watch` → log file; `brp_stop_watch` |
| Screenshot | `brp_extras_screenshot {path}` — absolute path; options `camera`, `entity`, `name`, `padding` |
| Inspect screenshot | Read the PNG with the agent's image-capable file reader |
| Keyboard | `brp_extras_send_keys {keys:["KeyW"], duration_ms}`, `brp_extras_type_text` |
| Mouse | `brp_extras_move_mouse` (absolute logical px or delta), `click_mouse`, `drag_mouse`, `scroll_mouse` |
| Gamepad | `brp_extras_connect_gamepad`, `set_gamepad_axis`, `send_gamepad_button` |
| FPS / frame time | `brp_extras_get_diagnostics` |
| Deterministic frames/time | feedback: `wait_frames`, `advance_time`, `capture_after_frames` |
| Raw BRP from shell | `curl -s -X POST http://127.0.0.1:15702 -d '{"jsonrpc":"2.0","id":1,"method":"world.query","params":{...}}'` |

## Visual verification loop

1. `cargo build` → `brp_launch` (or `cargo run` in background).
2. `brp_status` until running; wait ~1–2 s or poll `brp_extras_get_diagnostics` for frame count to
   pass a few hundred frames (assets loaded).
3. Drive into the needed state via `brp_extras_send_keys` / mouse tools, or mutate state directly.
4. `brp_extras_screenshot {path: "<abs>/target/shots/<label>.png"}`.
5. Read the PNG; compare against the request.
6. Edit → rebuild → `brp_shutdown` + relaunch → capture again.

Keep the window visible: a minimized/occluded window can yield black captures on some platforms.
Input coordinates are logical window pixels; PNGs are physical pixels. Skeleton forces scale
factor 1.0, so both are 1280x720.

## Scripted run with bevy-feedback

```sh
bevy-feedback run --require-window-size 1280x720 \
  --prepare-timeout 600000 --protocol-timeout 30000 --game-cwd "$PWD" \
  --prepare cargo build --features agent-feedback \
  --game cargo run --features agent-feedback \
  --driver python driver.py
```
Driver API and readiness rules: skill `driving-bevy-games`. Set `BEVY_FEEDBACK_REALTIME=1` to
disable frozen time (`src/dev/mod.rs` reads it).

## In-process tests (no window)

Minimal `App` + `app.update()` with `TimeUpdateStrategy` (skill `bevy-testing`). Prefer this for
logic; reserve runtime tooling for integration/visual checks.
