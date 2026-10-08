#!/usr/bin/env bash
# Create a new Bevy repository from this kit's template.
# Usage: scripts/new-bevy-project.sh <path> [crate_name]
set -euo pipefail

path="$1"
name="${2:-$(basename "$path")}"
crate="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g')"
template="$(cd "$(dirname "$0")/../template" && pwd)"

[ -e "$path" ] && { echo "Target exists: $path" >&2; exit 1; }
cp -r "$template" "$path"
sed -i.bak "s/^name = \"bevy_app\"/name = \"$crate\"/" "$path/Cargo.toml" && rm "$path/Cargo.toml.bak"

cd "$path"
git init -q && git add -A
cargo fmt
cargo check
git commit -q -m "Bootstrap Bevy project from template"
echo "Created $crate at $path. Next: cargo run"
