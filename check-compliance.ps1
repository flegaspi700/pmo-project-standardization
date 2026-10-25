<#
.SYNOPSIS
    Reports where a repo stands against the standard (spec/compliance.md).

.DESCRIPTION
    Runs the checks in spec/compliance-checks.json against a local folder and
    prints each result, the warnings, and the compliance level:
      0 Not on standard, 1 Reporting, 2 Adopted, 3 Current.
    Only reads; changes nothing.

    The portfolio dashboard runs the same checks over the GitHub API. This is
    the local version, and the reference for how each check kind works.

    Dot-source it (". .\check-compliance.ps1") to use Get-Compliance and
    Get-PortfolioProblems from another script without running a check.

.EXAMPLE
    .\check-compliance.ps1 -Path D:\Projects\ocr-pipeline

.EXAMPLE
    .\check-compliance.ps1 -Path . -Today 2026-12-01
    # as if it were 2026-12-01, to see which grace periods will have ended
#>
param(
    [string]$Path,

    # Date the grace periods are measured against (yyyy-MM-dd)
    [string]$Today = (Get-Date -Format 'yyyy-MM-dd')
)

$complianceSpecDir = Join-Path $PSScriptRoot "spec"
$complianceUtf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8($file) {
    [System.IO.File]::ReadAllText($file, $complianceUtf8)
}

# Problems with a portfolio.json text. Windows PowerShell has no JSON Schema
# validator, so this checks what the schema pins down at the top level:
# required fields, known fields only, enums, constants. Empty = valid.
function Get-PortfolioProblems($json, $schemaPath) {
    $schema = (Read-Utf8 $schemaPath) | ConvertFrom-Json
    try {
        $doc = $json | ConvertFrom-Json
    }
    catch {
        return @("not valid JSON ($($_.Exception.Message))")
    }
    $problems = @()
    $known = @($schema.properties.PSObject.Properties.Name)
    $present = @($doc.PSObject.Properties.Name)
    foreach ($field in $schema.required) {
        if ($present -notcontains $field) { $problems += "missing required field '$field'" }
    }
    foreach ($field in $present) {
        if ($known -notcontains $field) {
            $problems += "field '$field' isn't in the schema"
            continue
        }
        $rule = $schema.properties.$field
        if ($rule.enum -and $rule.enum -notcontains $doc.$field) {
            $problems += "$field '$($doc.$field)' isn't one of: $($rule.enum -join ', ')"
        }
        if ($null -ne $rule.const -and $doc.$field -ne $rule.const) {
            $problems += "$field must be $($rule.const)"
        }
    }
    return $problems
}

# One check against one repo folder: $true (pass), $false (fail), or $null
# (doesn't apply). Kinds are described in spec/compliance.md -> Checks.
function Test-ComplianceCheck($check, $repo) {
    if ($check.applies_if) {
        $file = Join-Path $repo $check.applies_if.path
        if (-not (Test-Path -LiteralPath $file) -or (Read-Utf8 $file) -notmatch $check.applies_if.pattern) {
            return $null
        }
    }
    switch ($check.kind) {
        'exists' {
            foreach ($p in $check.paths) {
                if (-not (Test-Path -LiteralPath (Join-Path $repo $p))) { return $false }
            }
            return $true
        }
        'contains' {
            $file = Join-Path $repo $check.path
            if (-not (Test-Path -LiteralPath $file)) { return [bool]$check.if_exists }
            return (Read-Utf8 $file) -match $check.pattern
        }
        'absent' {
            foreach ($p in $check.paths) {
                $file = Join-Path $repo $p
                if ((Test-Path -LiteralPath $file) -and (Read-Utf8 $file) -match $check.pattern) { return $false }
            }
            return $true
        }
        'schema' {
            $file = Join-Path $repo $check.path
            if (-not (Test-Path -LiteralPath $file)) { return $false }
            $problems = @(Get-PortfolioProblems (Read-Utf8 $file) (Join-Path $complianceSpecDir $check.schema))
            return $problems.Count -eq 0
        }
        default { throw "Unknown check kind '$($check.kind)' in $($check.id)" }
    }
}

# Runs every check and works out the level. Returns Level, LevelName,
# Version (from AGENTS.md, or $null), Results (one per check) and Warnings.
function Get-Compliance($repo, $today) {
    $registry = (Read-Utf8 (Join-Path $complianceSpecDir "compliance-checks.json")) | ConvertFrom-Json
    $results = @(foreach ($check in $registry.checks) {
        [pscustomobject]@{
            Id           = $check.id
            Title        = $check.title
            Severity     = $check.severity
            Pass         = Test-ComplianceCheck $check $repo
            # A required check counts once its 30-day grace period is over
            Due          = ($check.severity -eq 'required' -and $check.required_from -le $today)
            RequiredFrom = $check.required_from
            Fix          = $check.fix
        }
    })
    $allPass = {
        param($ids)
        foreach ($id in $ids) {
            if (($results | Where-Object { $_.Id -eq $id }).Pass -ne $true) { return $false }
        }
        return $true
    }

    $level = 0
    if (& $allPass $registry.levels.adopted) {
        $level = 2
        if (@($results | Where-Object { $_.Due -and $_.Pass -eq $false }).Count -eq 0) { $level = 3 }
    }
    elseif (& $allPass $registry.levels.reporting) {
        $level = 1
    }

    $warnings = @()
    foreach ($r in $results | Where-Object { $_.Pass -eq $false }) {
        if ($r.Severity -eq 'warning') {
            $warnings += "$($r.Id) $($r.Title): $($r.Fix)"
        }
        elseif ($r.Severity -eq 'required' -and -not $r.Due) {
            $warnings += "$($r.Id) required from $($r.RequiredFrom): $($r.Fix)"
        }
    }

    $version = $null
    $agents = Join-Path $repo "AGENTS.md"
    if (Test-Path -LiteralPath $agents) {
        $match = [regex]::Match((Read-Utf8 $agents), 'Template version: ([^*\s]+)')
        if ($match.Success) { $version = $match.Groups[1].Value }
    }

    [pscustomobject]@{
        Level     = $level
        LevelName = @('Not on standard', 'Reporting', 'Adopted', 'Current')[$level]
        Version   = $version
        Results   = $results
        Warnings  = $warnings
    }
}

# Run only when called as a script, not when dot-sourced
if ($MyInvocation.InvocationName -ne '.') {
    if (-not $Path) { throw "Give the repo folder to check: -Path <folder>" }
    if (-not (Test-Path -LiteralPath $Path)) { throw "Folder not found: $Path" }
    $report = Get-Compliance (Resolve-Path -LiteralPath $Path).Path $Today

    $report.Results | Format-Table -AutoSize Id, Severity,
        @{ Name = 'Result'; Expression = { if ($null -eq $_.Pass) { 'n/a' } elseif ($_.Pass) { 'pass' } else { 'FAIL' } } },
        Title | Out-Host
    $versionText = if ($report.Version) { $report.Version } else { 'not stamped' }
    Write-Host "Level $($report.Level) - $($report.LevelName) (template version: $versionText)" -ForegroundColor Cyan
    foreach ($w in $report.Warnings) { Write-Host "WARN  $w" -ForegroundColor Yellow }
}
