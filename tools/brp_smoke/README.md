# brp_smoke — tooling test fixture

Not an application. Template + one named cube, camera, light, a spinning system and a reflected
`InputProbe` resource that counts injected keys/clicks. Use it to re-verify the environment after
upgrading Bevy, `bevy_brp_mcp`/`bevy_brp_extras` or the feedback plugin.

## 1. BRP / MCP (through a real agent session)

```sh
cargo build
claude -p "Use only brp MCP tools and Read. Launch brp_smoke (brp_launch), find TestCube,
read its Transform, mutate .translation.y to 0.75 and re-read, read InputProbe, send key KeyA,
move mouse to (640,360) and left-click, re-read InputProbe, screenshot to <ABS_PATH>/shot.png,
Read it and describe it, then brp_shutdown. Report PASS/FAIL per step." \
  --allowedTools "mcp__brp__*" "Read"
```
Expected: translation becomes `[0,0.75,0]`; InputProbe `keys_pressed=1, last_key="KeyA",
mouse_clicks=1, cursor=[640,360]`; 1280x720 PNG of an orange cube (note: the cube spins).

## 2. Scripted feedback run (deterministic time)

```sh
bevy-feedback run --require-window-size 1280x720 --prepare-timeout 900000 --protocol-timeout 60000 \
  --game-cwd "$PWD" --prepare cargo build --features agent-feedback \
  --game cargo run --features agent-feedback --driver python driver.py
```
Expected: `frozen_identical: true`, `advance_changed: true`, `keys_after > keys_before`,
`bevy-feedback ok`.
