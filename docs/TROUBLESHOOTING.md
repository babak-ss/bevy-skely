# Troubleshooting

| Symptom | Fix |
|---|---|
| `link.exe` not found / links with Git's `link.exe` | Install VS Build Tools C++ workload (docs/SETUP.md). Git's `usr/bin/link.exe` on PATH is harmless when MSVC is installed (rustc locates MSVC via registry). |
| `mcp__brp__*` tools missing | Restart Claude Code after `claude mcp add`. Check `claude mcp get brp`. Ensure `~/.cargo/bin` is on the PATH Claude Code was started with. |
| `brp_status` says not running / connection refused | App built without `dev` feature, or port in use. Check `brp_read_log`; set `BRP_EXTRAS_PORT` and pass `port` to tools. |
| `brp_launch` can't find target | Run `cargo build` first; pass `path` for multi-project workspaces. It cannot pass Cargo features — keep `dev` default or launch with `cargo run --features ...` instead. |
| `brp_launch` app dies with missing DLL | Built with `fast-compile` (`dynamic_linking`). Rebuild without it. |
| Component not visible to BRP | Type lacks `Reflect` + `#[reflect(Component)]`. |
| Mutation rejected / wrong JSON | `brp_type_guide` for exact paths and value shapes (e.g. `.translation.y`, Vec3 as `[x,y,z]`). |
| Screenshot black | Window minimized/occluded, or captured before first render. Keep window visible; wait for frames. |
| Screenshot fails "png" | Bevy `png` feature missing (template `dev` enables it). |
| Keys not received | App code reads `ButtonInput<KeyCode>`: injected keys work. Use `KeyCode` names (`KeyA`, `ArrowUp`, `Space`). Hold long enough (`duration_ms` ≥ 100) for systems gated on `FixedUpdate`. |
| Mouse position off | Tool coordinates are logical px; screenshots are physical px (multiply by scale factor). |
| `bevy-feedback run` times out | Increase `--prepare-timeout` (first Bevy build is slow); confirm `--features agent-feedback`. |
| `bevy_brp_mcp --version` errors `ConnectionClosed` | Expected: binary is a stdio MCP server with no version flag. Version: `cargo install --list`. |
| Skills not offered | `ls ~/.claude/skills`; reinstall via `npx skills add ... -g -a claude-code --copy`; restart session. |
| First build very slow | Normal (~5–10 min clean). Subsequent incremental builds are fast; shared `CARGO_TARGET_DIR` across projects is optional. |
| First `--features agent-feedback` build rebuilds all of Bevy | The plugin enables extra Bevy (`keyboard`, `mouse`) and `log` max-level features, changing the feature hash. One-time cost; Cargo keeps both artifact sets, so toggling afterwards is fast. |
| Screenshot size ≠ 1280x720 | Display scaling. Template sets `with_scale_factor_override(1.0)`; remove it if you want native DPI and convert coordinates by scale factor. |
