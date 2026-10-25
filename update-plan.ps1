<#
.SYNOPSIS
    Plans the update of a project to a newer template version. Read-only.

.DESCRIPTION
    Works out the template version the project is on (its base), then lists
    every template file that changed between the base and the target
    version, with what to do about it:

      ADD         the project doesn't have the file: copy it
      REPLACE     the project's copy is the base version, unchanged: the new
                  version can replace it
      MERGE       the project changed the file (or it holds filled-in
                  placeholders): apply the template's change by hand
      UP-TO-DATE  the project already has the new version
      REVIEW      the template removed the file: decide whether to keep it

    Files the template didn't change since the base are not listed, however
    much the project changed them. Comparisons ignore line endings.

    Base: the `Template version:` line in AGENTS.md, or (if there isn't one)
    the oldest tag whose skills match the project's skills best. Old
    versions are read from the template's git tags, so uncommitted template
    edits don't matter.

    Used by the /update-template skill. Dot-source it to use
    Get-UpdatePlan from another script.

.EXAMPLE
    .\update-plan.ps1 -Path D:\Projects\ocr-pipeline

.EXAMPLE
    .\update-plan.ps1 -Path . -From v1.2.0 -To v1.4.0
#>
param(
    [string]$Path,

    # Base version; default: the stamp in AGENTS.md, else detected
    [string]$From,

    # Target version; default: the newest tag
    [string]$To
)

$updateTemplateRoot = $PSScriptRoot

# A file from the template repo as it was at a tag, as text ($null if it
# didn't exist). Runs git directly and reads its output as UTF-8: Windows
# PowerShell would decode it with the console code page and garble it.
function Get-TemplateFileAt($tag, $relativePath) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "git"
    $psi.Arguments = "-C `"$updateTemplateRoot`" show `"${tag}:$relativePath`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = New-Object System.Text.UTF8Encoding($false)
    $process = [System.Diagnostics.Process]::Start($psi)
    $text = $process.StandardOutput.ReadToEnd()
    $process.StandardError.ReadToEnd() | Out-Null
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) { return $null }
    return $text
}

# Text with Windows line endings turned into Unix ones, for comparing
function ConvertTo-Lf($text) {
    if ($null -eq $text) { return $null }
    return $text.Replace("`r`n", "`n")
}

function Read-ProjectFile($file) {
    if (-not (Test-Path -LiteralPath $file)) { return $null }
    return [System.IO.File]::ReadAllText($file, (New-Object System.Text.UTF8Encoding($false)))
}

# Version tags, oldest first
function Get-TemplateTags {
    @(git -C $updateTemplateRoot tag --list "v*" --sort=v:refname)
}

# The tag a project is on: its stamp, or the oldest tag whose skills match
# best. Returns @{ Version; How }.
function Find-BaseVersion($project, $tags) {
    $agents = Read-ProjectFile (Join-Path $project "AGENTS.md")
    if ($agents) {
        $stamp = [regex]::Match($agents, 'Template version: (v\d+\.\d+\.\d+)')
        if ($stamp.Success -and $tags -contains $stamp.Groups[1].Value) {
            return @{ Version = $stamp.Groups[1].Value; How = "stamp in AGENTS.md" }
        }
    }
    $skillsDir = Join-Path $project ".claude\skills"
    $skills = @(Get-ChildItem -Path $skillsDir -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
    $best = $null
    $bestScore = -1
    foreach ($tag in $tags) {
        $score = 0
        foreach ($skill in $skills) {
            $theirs = ConvertTo-Lf (Get-TemplateFileAt $tag "project-template/.claude/skills/$skill/SKILL.md")
            $ours = ConvertTo-Lf (Read-ProjectFile (Join-Path $skillsDir "$skill\SKILL.md"))
            if ($null -ne $theirs -and $theirs -eq $ours) { $score++ }
        }
        # Strictly greater, so a tie keeps the oldest tag: updating from an
        # older base only adds checks, files already new show as UP-TO-DATE
        if ($score -gt $bestScore) {
            $best = $tag
            $bestScore = $score
        }
    }
    return @{ Version = $best; How = "detected: $bestScore of $($skills.Count) skills match $best exactly" }
}

# The plan: From, To, How (base found how), Files (Path, Action) and
# Changelog (the CHANGELOG sections between From and To)
function Get-UpdatePlan($project, $from, $to) {
    $tags = Get-TemplateTags
    if (-not $to) { $to = $tags[-1] }
    $how = "given"
    if (-not $from) {
        $base = Find-BaseVersion $project $tags
        $from = $base.Version
        $how = $base.How
    }

    $files = @()
    $changes = @(git -C $updateTemplateRoot diff --name-status $from $to -- project-template)
    foreach ($line in $changes) {
        $parts = $line -split "`t"
        $status = $parts[0].Substring(0, 1)
        $templatePath = $parts[-1]
        $relative = $templatePath.Substring("project-template/".Length)
        $ours = ConvertTo-Lf (Read-ProjectFile (Join-Path $project $relative))
        if ($status -eq 'D') {
            $action = if ($null -eq $ours) { 'UP-TO-DATE' } else { 'REVIEW' }
        }
        else {
            $latest = ConvertTo-Lf (Get-TemplateFileAt $to $templatePath)
            $baseText = ConvertTo-Lf (Get-TemplateFileAt $from $templatePath)
            if ($null -eq $ours) { $action = 'ADD' }
            elseif ($ours -eq $latest) { $action = 'UP-TO-DATE' }
            elseif ($null -ne $baseText -and $ours -eq $baseText) { $action = 'REPLACE' }
            else { $action = 'MERGE' }
        }
        $files += [pscustomobject]@{ Path = $relative; Action = $action }
    }

    # CHANGELOG sections newer than From, up to and including To
    $changelog = Get-TemplateFileAt $to "CHANGELOG.md"
    $sections = [regex]::Matches((ConvertTo-Lf $changelog), '(?ms)^## (v\d+\.\d+\.\d+).*?(?=^## |\z)')
    $fromIndex = [array]::IndexOf($tags, $from)
    $notes = @($sections | Where-Object { [array]::IndexOf($tags, $_.Groups[1].Value) -gt $fromIndex } | ForEach-Object { $_.Value.Trim() })

    [pscustomobject]@{
        From      = $from
        To        = $to
        How       = $how
        Files     = $files
        Changelog = $notes
    }
}

# Run only when called as a script, not when dot-sourced
if ($MyInvocation.InvocationName -ne '.') {
    if (-not $Path) { throw "Give the project folder: -Path <folder>" }
    if (-not (Test-Path -LiteralPath $Path)) { throw "Folder not found: $Path" }
    $plan = Get-UpdatePlan (Resolve-Path -LiteralPath $Path).Path $From $To

    Write-Host "Base $($plan.From) ($($plan.How)) -> target $($plan.To)" -ForegroundColor Cyan
    if ($plan.From -eq $plan.To -or $plan.Files.Count -eq 0) {
        Write-Host "Nothing to update: no template files changed between $($plan.From) and $($plan.To)."
    }
    else {
        $plan.Files | Sort-Object Action, Path | Format-Table -AutoSize Action, Path | Out-Host
    }
    foreach ($section in $plan.Changelog) {
        Write-Host ""
        Write-Host $section
    }
}
