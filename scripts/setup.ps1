<#
.SYNOPSIS
  Turn a fresh clone of the Bevy skeleton into a new project. Run once, from the repo root.
.EXAMPLE
  git clone <skeleton> my_game; cd my_game; pwsh scripts/setup.ps1
.PARAMETER Name         Crate name (default: folder name).
.PARAMETER KeepHistory  Keep the skeleton's git history/remote instead of starting fresh.
.PARAMETER KeepSmoke    Keep tools/brp_smoke (tooling test fixture).
.PARAMETER SkipBuild    Skip the initial `cargo check` (first Bevy build takes minutes).
.PARAMETER Yes          Don't ask for confirmation.
#>
param(
    [string] $Name,
    [switch] $KeepHistory,
    [switch] $KeepSmoke,
    [switch] $SkipBuild,
    [switch] $Yes
)
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $root

$cargo = Join-Path $root 'Cargo.toml'
if ((Get-Content $cargo -Raw) -notmatch 'name = "bevy_skeleton"') {
    throw 'Cargo.toml no longer names "bevy_skeleton": project already set up.'
}

if (-not $Name) { $Name = Split-Path $root -Leaf }
$crate = ($Name.ToLower() -replace '[^a-z0-9_]', '_').Trim('_')
if ($crate -notmatch '^[a-z]') { $crate = "app_$crate" }

$historyNote = if ($KeepHistory) { 'keep git history' } else { 'DELETE .git and start fresh history' }
if (-not $Yes) {
    $answer = Read-Host "Set up project '$crate' in $root ($historyNote)? [y/N]"
    if ($answer -notmatch '^[yY]') { Write-Host 'Aborted.'; exit 1 }
}

# Prerequisites: warn only, so setup still works on a partially provisioned machine.
function Warn($msg) { Write-Warning "$msg (see docs/SETUP.md)" }
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) { throw 'cargo not found: install rustup first.' }
if (-not (Get-Command bevy_brp_mcp -ErrorAction SilentlyContinue)) { Warn 'bevy_brp_mcp not installed' }
if (-not (Test-Path (Join-Path $HOME '.claude/skills/bevy/SKILL.md'))) { Warn 'Bevy skills not installed' }
if (Get-Command claude -ErrorAction SilentlyContinue) {
    claude mcp get brp *> $null
    if ($LASTEXITCODE -ne 0) { Warn 'MCP server "brp" not registered: claude mcp add --scope user brp -- bevy_brp_mcp' }
}

(Get-Content $cargo -Raw) -replace 'name = "bevy_skeleton"', "name = `"$crate`"" | Set-Content $cargo -NoNewline
$lock = Join-Path $root 'Cargo.lock'
if (Test-Path $lock) {
    (Get-Content $lock -Raw) -replace 'name = "bevy_skeleton"', "name = `"$crate`"" | Set-Content $lock -NoNewline
}

if (-not $KeepSmoke) { Remove-Item tools/brp_smoke -Recurse -Force -ErrorAction SilentlyContinue }
if (-not (Get-ChildItem tools -Force -ErrorAction SilentlyContinue)) { Remove-Item tools -Force -ErrorAction SilentlyContinue }

Set-Content README.md @"
# $crate

Bevy 0.19 project. Agent rules: [AGENTS.md](AGENTS.md). Tooling docs: [docs/](docs/KIT.md).

``````
cargo run                                   # dev build, BRP on 127.0.0.1:15702
cargo test
cargo build --release --no-default-features # shipping build without dev tooling
``````
"@

# One-shot: remove setup scripts so they can't be re-run against the real project.
Remove-Item scripts/setup.ps1, scripts/setup.sh -Force -ErrorAction SilentlyContinue
if (-not (Get-ChildItem scripts -Force -ErrorAction SilentlyContinue)) { Remove-Item scripts -Force }

if (-not $KeepHistory) {
    Remove-Item .git -Recurse -Force -ErrorAction SilentlyContinue
    git init -q
}
git add -A
git commit -q -m "Initial commit from Bevy skeleton"

if (-not $SkipBuild) {
    cargo fmt
    cargo check
}

Write-Host "Ready: $crate. Next: cargo run"
