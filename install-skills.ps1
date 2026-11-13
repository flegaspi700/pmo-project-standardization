<#
.SYNOPSIS
    Installs the standard's skills for the current user, as junctions.

.DESCRIPTION
    For every folder in skills\ that has a SKILL.md, creates a junction
    (folder shortcut) at %USERPROFILE%\.claude\skills\<name> pointing to it.
    Claude Code then finds the skill in every folder you open, and a change
    to a skill in this repo reaches every project at once.

    Never overwrites anything: a name that already exists is left alone
    and reported. Junctions need no admin rights.

    Run it once per machine. Run it again after a new skill is added here.

.PARAMETER DryRun
    Show what would be linked, change nothing.

.EXAMPLE
    .\install-skills.ps1 -DryRun
    .\install-skills.ps1
#>
param([switch]$DryRun)

$ErrorActionPreference = "Stop"
$source = Join-Path $PSScriptRoot "skills"
$destination = Join-Path $env:USERPROFILE ".claude\skills"

function Format-Path($path) { $path.TrimEnd('\').ToLowerInvariant() }

if (-not (Test-Path $destination)) {
    if ($DryRun) { Write-Host "Would create $destination" }
    else { New-Item -ItemType Directory -Path $destination | Out-Null }
}

$linked = 0; $skipped = 0
foreach ($skill in Get-ChildItem $source -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }) {
    $link = Join-Path $destination $skill.Name

    if (-not (Test-Path $link)) {
        if ($DryRun) { Write-Host "LINK  $($skill.Name)" }
        else {
            New-Item -ItemType Junction -Path $link -Target $skill.FullName | Out-Null
            Write-Host "LINK  $($skill.Name)" -ForegroundColor Green
        }
        $linked++
        continue
    }

    $item = Get-Item $link -Force
    $target = if ($item.Target) { @($item.Target)[0] } else { $null }
    if ($target -and (Format-Path $target) -eq (Format-Path $skill.FullName)) {
        Write-Host "OK    $($skill.Name) (already installed)"
    }
    elseif ($target) {
        Write-Host "SKIP  $($skill.Name): already links to $target. Remove that link first to use this one." -ForegroundColor Yellow
        $skipped++
    }
    else {
        Write-Host "SKIP  $($skill.Name): a real folder is there, not a link. Left as it is." -ForegroundColor Yellow
        $skipped++
    }
}

$verb = if ($DryRun) { "Would link" } else { "Linked" }
Write-Host "`n$verb $linked skill(s), skipped $skipped."
Write-Host "Note: in a repo that has its own .claude\skills\ copy of a skill (v1 projects), that copy may be the one that runs there."
