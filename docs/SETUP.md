# Host setup (reproducible)

Machine-level install for the AI-first Bevy environment. Everything here is user-scope;
nothing is project-specific. Reference host: Windows 11, Claude Code.

## 1. Prerequisites

| Tool | Install | Notes |
|---|---|---|
| MSVC linker + Windows SDK | `winget install Microsoft.VisualStudio.2022.BuildTools --override "--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"` | Needs UAC once. Required by `x86_64-pc-windows-msvc`. |
| rustup | `winget install Rustlang.Rustup` | Installs to `~/.cargo/bin`, added to user PATH |
| Rust stable + components | `rustup default stable` / `rustup component add rustfmt clippy rust-analyzer` | |
| Node/npx | already present | only for the `skills` installer |
| Python 3 | already present | driver scripts for `bevy-feedback` |
| Linux only | `sudo apt install g++ pkg-config libx11-dev libasound2-dev libudev-dev libxkbcommon-x11-0 libwayland-dev` | see Bevy `docs/linux_dependencies.md` |

No global `~/.cargo/config.toml` changes. Build-speed settings live per project (template `Cargo.toml`).

## 2. Bevy skills (user scope)

```sh
npx -y skills add https://github.com/chrisgliddon/bevy-skills -g -a claude-code -s '*' -y --copy
npx -y skills add https://github.com/drsh4dow/bevy-agent-feedback-plugin -g -a claude-code -s driving-bevy-games -y --copy
```
Location: `~/.claude/skills/<skill>/SKILL.md`. Update: `npx skills update -g`.
`--copy` avoids Windows symlink permission issues. Other agents: `-a codex`, `-a cursor`, `-a '*'`.

Claude Code alternative: `/plugin marketplace add chrisgliddon/bevy-skills`.

## 3. bevy_brp_mcp (MCP server)

```sh
cargo install bevy_brp_mcp --version 0.22.10 --locked     # Bevy 0.19 line
claude mcp add --scope user brp -- bevy_brp_mcp
claude mcp get brp                                         # expect: Status ✔ Connected
```
Config is stored in `~/.claude.json` → `mcpServers.brp` (user scope = every project).
Tools appear as `mcp__brp__*` in new sessions (restart Claude Code after adding).

Other MCP clients (Cursor/Codex/Claude Desktop), generic JSON:
```json
{ "mcpServers": { "brp": { "type": "stdio", "command": "bevy_brp_mcp", "args": [] } } }
```

## 4. bevy-feedback CLI (optional driver)

```sh
cargo install bevy-agent-feedback-plugin --version 0.5.0 --locked
bevy-feedback doctor
```

## 5. Bevy CLI (optional convenience)

Not on crates.io. Prebuilt binary from the tagged release (no compile):
```sh
gh release download cli-v0.1.0-alpha.2 -R TheBevyFlock/bevy_cli -p 'bevy-x86_64-pc-windows-msvc-*'
# copy to ~/.cargo/bin/bevy.exe
# or: cargo install --git https://github.com/TheBevyFlock/bevy_cli --tag cli-v0.1.0-alpha.2 --locked bevy_cli
```
`bevy lint` (bevy_lint) is **not** installed: it needs a pinned nightly toolchain and its latest
release (lint-v0.6.0) predates Bevy 0.19.

## Version compatibility

| Bevy | bevy_brp_mcp / bevy_brp_extras | bevy-agent-feedback-plugin | bevy-skills |
|---|---|---|---|
| 0.19.x | 0.22.10 | 0.5 | main (pins 0.19) |
| 0.18 | 0.19.0 | — | migration skill only |
| 0.20 (rc) | 0.23.0-rc.1 | — | — |

When Bevy 0.20 ships: bump `bevy`, `bevy_brp_extras` and `cargo install bevy_brp_mcp` together,
then `npx skills update -g` and check the new migration skill.
