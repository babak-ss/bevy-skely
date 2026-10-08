#!/usr/bin/env bash
# Turn a fresh clone of the Bevy skeleton into a new project. Run once, from anywhere in the repo.
# Usage: scripts/setup.sh [--name NAME] [--keep-history] [--keep-smoke] [--skip-build] [--yes]
set -euo pipefail

name="" keep_history=0 keep_smoke=0 skip_build=0 yes=0
while [ $# -gt 0 ]; do
    case "$1" in
        --name) name="$2"; shift ;;
        --keep-history) keep_history=1 ;;
        --keep-smoke) keep_smoke=1 ;;
        --skip-build) skip_build=1 ;;
        --yes|-y) yes=1 ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

cd "$(dirname "$0")/.."
grep -q 'name = "bevy_skeleton"' Cargo.toml || { echo 'Cargo.toml no longer names "bevy_skeleton": project already set up.' >&2; exit 1; }

[ -n "$name" ] || name="$(basename "$PWD")"
crate="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g; s/^_*//; s/_*$//')"
case "$crate" in [a-z]*) ;; *) crate="app_$crate" ;; esac

if [ "$yes" = 0 ]; then
    note="DELETE .git and start fresh history"; [ "$keep_history" = 1 ] && note="keep git history"
    read -r -p "Set up project '$crate' in $PWD ($note)? [y/N] " answer
    case "$answer" in [yY]*) ;; *) echo "Aborted."; exit 1 ;; esac
fi

# Prerequisites: warn only.
warn() { echo "warning: $1 (see docs/SETUP.md)" >&2; }
command -v cargo >/dev/null || { echo "cargo not found: install rustup first." >&2; exit 1; }
command -v bevy_brp_mcp >/dev/null || warn "bevy_brp_mcp not installed"
[ -f "$HOME/.claude/skills/bevy/SKILL.md" ] || warn "Bevy skills not installed"
if command -v claude >/dev/null; then
    claude mcp get brp >/dev/null 2>&1 || warn 'MCP server "brp" not registered: claude mcp add --scope user brp -- bevy_brp_mcp'
fi

sed -i.bak "s/name = \"bevy_skeleton\"/name = \"$crate\"/" Cargo.toml && rm Cargo.toml.bak
[ -f Cargo.lock ] && sed -i.bak "s/name = \"bevy_skeleton\"/name = \"$crate\"/" Cargo.lock && rm Cargo.lock.bak

[ "$keep_smoke" = 1 ] || rm -rf tools/brp_smoke
rmdir tools 2>/dev/null || true

cat > README.md <<EOF
# $crate

Bevy 0.19 project. Agent rules: [AGENTS.md](AGENTS.md). Tooling docs: [docs/](docs/KIT.md).

\`\`\`
cargo run                                   # dev build, BRP on 127.0.0.1:15702
cargo test
cargo build --release --no-default-features # shipping build without dev tooling
\`\`\`
EOF

# One-shot: remove setup scripts so they can't be re-run against the real project.
rm -f scripts/setup.ps1 scripts/setup.sh
rmdir scripts 2>/dev/null || true

if [ "$keep_history" = 0 ]; then rm -rf .git; git init -q; fi
git add -A
git commit -q -m "Initial commit from Bevy skeleton"

if [ "$skip_build" = 0 ]; then cargo fmt; cargo check; fi
echo "Ready: $crate. Next: cargo run"
