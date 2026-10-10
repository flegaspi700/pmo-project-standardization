<#
.SYNOPSIS
    Creates a new project from the project-template folder.

.DESCRIPTION
    Copies D:\Projects\Template\project-template to <Destination>\<folder-name>,
    replaces the <Project name>, <project-name> and <hosting> placeholders, and
    runs `git init`. Doesn't commit - review and commit yourself.

    -Hosting says where the project lives: "local" (default - local git only,
    no GitHub steps) or "github" (GitHub Flow with PRs). It's written into
    AGENTS.md, and every workflow doc and skill reads it from there.

    -IntoExisting adds the template to a repo you already cloned into
    <Destination>\<folder-name>: files that don't exist yet are copied, files
    that do are left alone, and git init is skipped.

    Lives outside project-template on purpose, so it isn't copied into every
    new project.

.EXAMPLE
    .\new-project.ps1 -Name "Snack Tracker"
    # creates D:\Projects\snack-tracker

.EXAMPLE
    .\new-project.ps1 -Name "Snack Tracker" -Destination D:\Sandbox

.EXAMPLE
    .\new-project.ps1 -Name "Snack Tracker" -Hosting github
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$Destination = "D:\Projects",

    [ValidateSet("local", "github")]
    [string]$Hosting = "local",

    [switch]$IntoExisting
)

$ErrorActionPreference = "Stop"

$templateDir = Join-Path $PSScriptRoot "project-template"

# Folder name: lowercase, anything that isn't a letter or digit becomes a
# dash ("Snack Tracker!" -> "snack-tracker")
$folderName = ($Name.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
if (-not $folderName) {
    throw "Name '$Name' has no letters or digits to build a folder name from."
}

$targetDir = Join-Path $Destination $folderName

if (-not (Test-Path $templateDir)) {
    throw "Template not found at $templateDir"
}

if ($IntoExisting) {
    if (-not (Test-Path (Join-Path $targetDir ".git"))) {
        throw "-IntoExisting needs a cloned repo at $targetDir (no .git folder found)."
    }
    # Copy only what's missing, so the repo's own files are never overwritten
    $templateFull = (Resolve-Path $templateDir).Path
    $copied = @()
    Get-ChildItem -Path $templateFull -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($templateFull.Length).TrimStart([char]92)
        $dest = Join-Path $targetDir $relative
        if (Test-Path $dest) {
            Write-Warning "Kept existing $relative"
        } else {
            New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
            Copy-Item -Path $_.FullName -Destination $dest
            $copied += $dest
        }
    }
} else {
    if (Test-Path $targetDir) {
        throw "$targetDir already exists - pick another name or remove it first."
    }
    Copy-Item -Path $templateDir -Destination $targetDir -Recurse
    $copied = @(Get-ChildItem -Path $targetDir -Recurse -File | ForEach-Object { $_.FullName })
}

# Fill in the name placeholders. Read/write through .NET so files stay UTF-8
# without a BOM - Windows PowerShell's Set-Content would add one or switch to
# the ANSI codepage and mangle characters like the arrows used in the docs.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
# Only the files copied in just now - never an existing repo's own files.
$copied | Where-Object { $_ -like '*.md' } | ForEach-Object {
    $text = [System.IO.File]::ReadAllText($_, $utf8NoBom)
    $updated = $text.Replace('<Project name>', $Name).Replace('<project-name>', $folderName).Replace('<hosting>', $Hosting)
    if ($updated -ne $text) {
        [System.IO.File]::WriteAllText($_, $updated, $utf8NoBom)
    }
}

# Name the first branch main explicitly - older git defaults to master, and
# docs/13-git-workflow.md assumes main
if (-not $IntoExisting) {
    git -C $targetDir init --quiet --initial-branch=main
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "git init failed - the files were created, but initialise git yourself."
    }
}

Write-Host ""
Write-Host "Created $targetDir (hosting: $Hosting)" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. code `"$targetDir`""
Write-Host "  2. Fill in README.md and AGENTS.md (search for '<')"
Write-Host "  3. Fill in docs/00 -> docs/04 in order: vision, requirements,"
Write-Host "     architecture, tech stack (ask the agent to recommend one), plan"
Write-Host "  4. Commit when you're happy with the starting docs"
