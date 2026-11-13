<#
.SYNOPSIS
    Puts a project on the standard: copies the starter files from scaffold\.

.DESCRIPTION
    Copies the files in scaffold\ (not scaffold\extras\, which the agent adds
    only when a project needs one) to <Destination>\<folder-name>, fills in
    <Project name>, <project-name>, <hosting> and <standard-version>, and
    runs `git init` on main. Doesn't commit: review and commit yourself.

    <standard-version> is the newest git tag of this repo. Before v2.0.0 is
    released it is written as v2.0.0, with a warning.

    -Destination is the parent folder (default: the current folder).

    -Hosting is "local" (default: local git only) or "github" (GitHub Flow
    with PRs). It goes into AGENTS.md, where every rule and skill reads it.

    -IntoExisting adopts the standard in a repo you already cloned into
    <Destination>\<folder-name>: only missing files are copied, nothing is
    overwritten, git init is skipped.

    -ReportOnly (implies -IntoExisting) adds only portfolio.json, so the repo
    shows on the portfolio dashboard (compliance level 1) without adopting
    the rest.

    -DryRun (with -IntoExisting or -ReportOnly) lists ADD or KEEP per file
    and changes nothing.

.EXAMPLE
    .\new-project.ps1 -Name "Snack Tracker"

.EXAMPLE
    .\new-project.ps1 -Name "my-repo" -Destination D:\Projects -IntoExisting -Hosting github -DryRun

.EXAMPLE
    .\new-project.ps1 -Name "course-notes" -Destination D:\Projects -ReportOnly
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$Destination = (Get-Location).Path,

    [ValidateSet("local", "github")]
    [string]$Hosting = "local",

    [switch]$IntoExisting,

    [switch]$ReportOnly,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
if ($ReportOnly) { $IntoExisting = $true }
if ($DryRun -and -not $IntoExisting) {
    throw "-DryRun only works with -IntoExisting or -ReportOnly."
}

$scaffold = Join-Path $PSScriptRoot "scaffold"
if (-not (Test-Path $scaffold)) { throw "Starter files not found at $scaffold" }

# Folder name: lowercase, anything that isn't a letter or digit becomes a
# dash ("Snack Tracker!" -> "snack-tracker")
$folderName = ($Name.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
if (-not $folderName) { throw "Name '$Name' has no letters or digits to build a folder name from." }
$targetDir = Join-Path $Destination $folderName

# Standard version: the newest release tag. v1 tags predate the standard
# folder, so before the v2.0.0 release the project is stamped v2.0.0.
# (try/catch: Windows PowerShell turns git's error text into a terminating
# error when the folder isn't a git repo or has no tags)
try { $standardVersion = git -C $PSScriptRoot describe --tags --abbrev=0 2>$null } catch { $standardVersion = $null }
if (-not $standardVersion -or $standardVersion -notmatch '^v(\d+)\.\d+\.\d+$' -or [int]$Matches[1] -lt 2) {
    $standardVersion = "v2.0.0"
    $unreleased = $true
}

# Which starter files: everything outside extras\, or only portfolio.json
$scaffoldFull = (Resolve-Path $scaffold).Path
$files = @(Get-ChildItem -Path $scaffoldFull -Recurse -File -Force | ForEach-Object {
    $_.FullName.Substring($scaffoldFull.Length).TrimStart([char]92)
} | Where-Object { $_ -notlike 'extras\*' })
if ($ReportOnly) { $files = @('portfolio.json') }

if ($IntoExisting) {
    if (-not (Test-Path (Join-Path $targetDir ".git"))) {
        throw "-IntoExisting needs a cloned repo at $targetDir (no .git folder found)."
    }
} elseif (Test-Path $targetDir) {
    throw "$targetDir already exists - pick another name or remove it first."
}

# Copy only what's missing, so a repo's own files are never overwritten
$copied = @()
foreach ($relative in $files) {
    $dest = Join-Path $targetDir $relative
    if ($DryRun) {
        $verb = if (Test-Path $dest) { "KEEP" } else { "ADD " }
        Write-Host "$verb $relative"
    } elseif (Test-Path $dest) {
        Write-Warning "Kept existing $relative"
    } else {
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Copy-Item -Path (Join-Path $scaffoldFull $relative) -Destination $dest
        $copied += $dest
    }
}

$claudeMd = Join-Path $targetDir "CLAUDE.md"
$claudeNeedsImport = (-not $ReportOnly) -and (Test-Path $claudeMd) -and
    -not ([System.IO.File]::ReadAllText($claudeMd) -match '(?m)^@AGENTS\.md\s*$')

if ($DryRun) {
    if ($claudeNeedsImport) { Write-Host "NOTE CLAUDE.md exists: '@AGENTS.md' would need adding as its first line" }
    Write-Host ""
    Write-Host "Dry run - nothing was changed."
    return
}

# Fill in the placeholders, in the files copied just now only. Read and
# write through .NET so files stay UTF-8 without a BOM. In portfolio.json
# the name goes inside a JSON string, so escape \ and "
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$jsonName = $Name.Replace('\', '\\').Replace('"', '\"')
foreach ($path in $copied | Where-Object { $_ -like '*.md' -or $_ -like '*portfolio.json' }) {
    $text = [System.IO.File]::ReadAllText($path, $utf8NoBom)
    $projectName = if ($path -like '*.json') { $jsonName } else { $Name }
    $updated = $text.Replace('<Project name>', $projectName).Replace('<project-name>', $folderName).Replace('<hosting>', $Hosting).Replace('<standard-version>', $standardVersion)
    if ($updated -ne $text) { [System.IO.File]::WriteAllText($path, $updated, $utf8NoBom) }
}

if (-not $IntoExisting) {
    git -C $targetDir init --quiet --initial-branch=main
    if ($LASTEXITCODE -ne 0) { Write-Warning "git init failed - the files were created, but initialise git yourself." }
}

Write-Host ""
if ($ReportOnly) {
    Write-Host "Added portfolio.json to $targetDir" -ForegroundColor Green
    Write-Host "Next: fill in summary, owner, program and lifecycle, then commit."
    return
}
Write-Host "Done: $targetDir (standard $standardVersion, hosting: $Hosting)" -ForegroundColor Green
if ($unreleased) { Write-Warning "$standardVersion isn't released yet: the rules may still change." }
if ($claudeNeedsImport) {
    Write-Warning "CLAUDE.md exists. Add '@AGENTS.md' as its first line, or Claude Code won't load AGENTS.md."
}
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Fill in the vision in docs/requirements.md and the first line of AGENTS.md"
Write-Host "  2. Fill in summary, owner and program in portfolio.json"
Write-Host "  3. In Claude Code, in the project folder: /breakdown, then /stack"
