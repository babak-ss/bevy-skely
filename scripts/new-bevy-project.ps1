<#
.SYNOPSIS
  Create a new Bevy repository from this kit's template.
.EXAMPLE
  pwsh scripts/new-bevy-project.ps1 -Path ~/WS/my_game
#>
param(
    [Parameter(Mandatory)] [string] $Path,
    [string] $Name = (Split-Path $Path -Leaf),
    [switch] $NoGit
)
$ErrorActionPreference = 'Stop'

if (Test-Path $Path) { throw "Target exists: $Path" }
$crate = ($Name.ToLower() -replace '[^a-z0-9_]', '_')
$template = Join-Path $PSScriptRoot '..\template'

Copy-Item $template $Path -Recurse
$cargo = Join-Path $Path 'Cargo.toml'
(Get-Content $cargo -Raw) -replace 'name = "bevy_app"', "name = `"$crate`"" | Set-Content $cargo -NoNewline

Push-Location $Path
try {
    if (-not $NoGit) { git init -q; git add -A }
    cargo fmt
    cargo check
    if (-not $NoGit) { git commit -q -m "Bootstrap Bevy project from template" }
} finally { Pop-Location }

Write-Host "Created $crate at $Path. Next: cargo run"
