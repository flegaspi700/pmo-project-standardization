<#
.SYNOPSIS
    Checks that the template still produces a working project.

.DESCRIPTION
    Runs new-project.ps1 into a temp folder (new project, and -IntoExisting
    on a fake repo) and checks:
      - no script placeholders are left (<Project name>, <hosting>, ...)
      - AGENTS.md has the template version stamped
      - portfolio.json (and the example in spec/reporting-contract.md) is
        valid JSON and fits spec/portfolio.schema.json
      - compliance: both generated projects reach level 3 (Current), an
        empty folder is level 0, a folder with only portfolio.json level 1;
        spec/compliance-checks.json is well formed
      - relative Markdown links and `docs/NN-*.md` references resolve
      - every SKILL.md has frontmatter with a name matching its folder and
        a description
      - the brainstorm steps copied into /new-project still match /brainstorm
      - every file is valid UTF-8 with no garbled characters

    Run it before opening a PR: .\tests\check-template.ps1
    Exits 1 if anything fails.
#>

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot
$script:failures = @()

function Fail($message) {
    $script:failures += $message
    Write-Host "FAIL  $message" -ForegroundColor Red
}

function Read-Text($path) {
    [System.IO.File]::ReadAllText($path, (New-Object System.Text.UTF8Encoding($false)))
}

# Get-Compliance and Get-PortfolioProblems
. (Join-Path $root "check-compliance.ps1")

# Fails for every way a portfolio.json text doesn't fit the schema, and
# returns the parsed object ($null if it isn't valid JSON)
function Test-Portfolio($json, $label) {
    foreach ($problem in Get-PortfolioProblems $json (Join-Path $root "spec\portfolio.schema.json")) {
        Fail "${label}: $problem"
    }
    try { $json | ConvertFrom-Json } catch { $null }
}

# Fails unless the folder reaches the expected compliance level. The far
# future date makes every required check due, whatever its grace period.
function Test-Level($folder, $expected, $label) {
    $report = Get-Compliance $folder "2999-01-01"
    if ($report.Level -ne $expected) {
        $failed = ($report.Results | Where-Object { $_.Pass -eq $false } | ForEach-Object { $_.Id }) -join ', '
        Fail "${label}: compliance level $($report.Level), expected $expected (failing: $failed)"
    }
}

# Collapse whitespace and line breaks so wrapping doesn't matter
function Normalize($text) {
    ($text -replace '\s+', ' ').Trim()
}

$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("template-check-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
    # --- 1. New project --------------------------------------------------
    Write-Host "Creating a new project in $tempDir"
    & (Join-Path $root "new-project.ps1") -Name "Check Project" -Destination $tempDir -Hosting github | Out-Null
    $project = Join-Path $tempDir "check-project"
    $mdFiles = @(Get-ChildItem -Path $project -Recurse -File -Filter *.md)

    # Placeholders the script must fill. Other <...> placeholders are for the
    # user and are expected.
    foreach ($file in $mdFiles) {
        $text = Read-Text $file.FullName
        foreach ($placeholder in '<Project name>', '<project-name>', '<hosting>', '<template-dir>', '<template-version>') {
            if ($text.Contains($placeholder)) {
                Fail "$($file.FullName.Substring($project.Length + 1)): $placeholder not filled in"
            }
        }
    }
    if (-not (Read-Text (Join-Path $project "AGENTS.md")).Contains("**Hosting: github**")) {
        Fail "AGENTS.md: hosting line not set to github"
    }
    if ((Read-Text (Join-Path $project "AGENTS.md")) -notmatch '\*\*Template version: v\d+\.\d+\.\d+') {
        Fail "AGENTS.md: template version not stamped (expected a vX.Y.Z git tag)"
    }

    $portfolio = Test-Portfolio (Read-Text (Join-Path $project "portfolio.json")) "portfolio.json"
    if ($portfolio -and $portfolio.name -ne "Check Project") {
        Fail "portfolio.json: name not filled in (got '$($portfolio.name)')"
    }

    # Links: [text](relative/path) and `docs/NN-name.md` references
    foreach ($file in $mdFiles) {
        $text = Read-Text $file.FullName
        $relative = $file.FullName.Substring($project.Length + 1)
        foreach ($match in [regex]::Matches($text, '\]\(([^)\s]+)\)')) {
            $target = $match.Groups[1].Value
            if ($target -match '^(https?:|mailto:|#)') { continue }
            $target = ($target -split '#')[0]
            if (-not (Test-Path (Join-Path $file.DirectoryName $target))) {
                Fail "${relative}: broken link ($target)"
            }
        }
        foreach ($match in [regex]::Matches($text, 'docs/\d\d-[a-z0-9-]+\.md')) {
            if (-not (Test-Path (Join-Path $project $match.Value))) {
                Fail "${relative}: refers to missing $($match.Value)"
            }
        }
    }

    # --- 2. Template added to an existing repo ---------------------------
    $existing = Join-Path $tempDir "existing-repo"
    git init --quiet $existing
    [System.IO.File]::WriteAllText((Join-Path $existing "README.md"), "# Existing repo`n")

    $dryRun = & (Join-Path $root "new-project.ps1") -Name "Existing Repo" -Destination $tempDir -IntoExisting -Hosting github -DryRun 6>&1 | Out-String
    if (@(Get-ChildItem -Path $existing -File).Count -ne 1 -or @(Get-ChildItem -Path $existing -Directory).Count -ne 0) {
        Fail "-DryRun changed files in the existing repo"
    }
    if ($dryRun -notmatch 'KEEP.*README\.md') {
        Fail "-DryRun didn't list README.md as KEEP"
    }

    & (Join-Path $root "new-project.ps1") -Name "Existing Repo" -Destination $tempDir -IntoExisting -Hosting github | Out-Null
    if ((Read-Text (Join-Path $existing "README.md")) -ne "# Existing repo`n") {
        Fail "-IntoExisting overwrote the existing README.md"
    }
    if (-not (Test-Path (Join-Path $existing "AGENTS.md"))) {
        Fail "-IntoExisting didn't add AGENTS.md"
    }

    # --- 3. Compliance levels ------------------------------------------
    # Fresh projects pass every required check; the levels below them work
    Test-Level $project 3 "new project"
    Test-Level $existing 3 "-IntoExisting repo"
    $empty = Join-Path $tempDir "empty-repo"
    New-Item -ItemType Directory -Path $empty | Out-Null
    Test-Level $empty 0 "empty folder"
    $reportingOnly = Join-Path $tempDir "reporting-only"
    New-Item -ItemType Directory -Path $reportingOnly | Out-Null
    Copy-Item (Join-Path $project "portfolio.json") $reportingOnly
    Test-Level $reportingOnly 1 "folder with only portfolio.json"
}
finally {
    Remove-Item -Path $tempDir -Recurse -Force
}

# --- 4. Compliance check registry ----------------------------------------
# Unique IDs, known severities and kinds, a date on every required check,
# and level definitions that point at real checks
$registry = (Read-Text (Join-Path $root "spec\compliance-checks.json")) | ConvertFrom-Json
$ids = @($registry.checks | ForEach-Object { $_.id })
foreach ($dup in $ids | Group-Object | Where-Object { $_.Count -gt 1 }) {
    Fail "spec/compliance-checks.json: duplicate check id $($dup.Name)"
}
foreach ($check in $registry.checks) {
    if (@('required', 'optional', 'warning') -notcontains $check.severity) {
        Fail "spec/compliance-checks.json: $($check.id) has unknown severity '$($check.severity)'"
    }
    if (@('exists', 'contains', 'absent', 'schema') -notcontains $check.kind) {
        Fail "spec/compliance-checks.json: $($check.id) has unknown kind '$($check.kind)'"
    }
    if ($check.severity -eq 'required' -and $check.required_from -notmatch '^\d{4}-\d{2}-\d{2}$') {
        Fail "spec/compliance-checks.json: required check $($check.id) needs a required_from date"
    }
    if (-not $check.fix) {
        Fail "spec/compliance-checks.json: $($check.id) has no fix"
    }
}
foreach ($id in @($registry.levels.reporting) + @($registry.levels.adopted)) {
    if ($ids -notcontains $id) { Fail "spec/compliance-checks.json: level refers to unknown check $id" }
}

# --- 5. Skill frontmatter ------------------------------------------------
$skillFiles = @(Get-ChildItem -Path (Join-Path $root "skills"), (Join-Path $root "project-template\.claude\skills") -Recurse -File -Filter SKILL.md)
foreach ($file in $skillFiles) {
    $relative = $file.FullName.Substring($root.Length + 1)
    $text = Read-Text $file.FullName
    $match = [regex]::Match($text, '\A---\r?\n(.*?)\r?\n---\r?\n', 'Singleline')
    if (-not $match.Success) {
        Fail "${relative}: no frontmatter between --- lines at the top"
        continue
    }
    $frontmatter = $match.Groups[1].Value
    $name = [regex]::Match($frontmatter, '(?m)^name:\s*(\S+)\s*$').Groups[1].Value
    if ($name -ne $file.Directory.Name) {
        Fail "${relative}: name '$name' doesn't match folder '$($file.Directory.Name)'"
    }
    if ($frontmatter -notmatch '(?m)^description:\s*\S') {
        Fail "${relative}: missing description"
    }
}

# --- 6. Brainstorm steps in /new-project match /brainstorm ---------------
# Each numbered step in /new-project's "1b. Brainstorm" section must appear
# word for word (ignoring line wrapping) in the /brainstorm skill.
$newProject = Read-Text (Join-Path $root "skills\new-project\SKILL.md")
$brainstorm = Normalize (Read-Text (Join-Path $root "project-template\.claude\skills\brainstorm\SKILL.md"))
$section = [regex]::Match($newProject, '(?s)## 1b\. Brainstorm.*?(?=\r?\n## )').Value
$steps = [regex]::Matches($section, '(?ms)^\d+\.\s+(.*?)(?=^\d+\.\s|^\s*$)')
if ($steps.Count -eq 0) {
    Fail "skills/new-project/SKILL.md: no numbered steps found under '## 1b. Brainstorm'"
}
foreach ($step in $steps) {
    $text = Normalize $step.Groups[1].Value
    if (-not $brainstorm.Contains($text)) {
        Fail "brainstorm step out of sync with /brainstorm: '$($text.Substring(0, [Math]::Min(60, $text.Length)))...'"
    }
}

# --- 7. Reporting contract example ---------------------------------------
# The example in spec/reporting-contract.md must fit the schema too.
$contract = Read-Text (Join-Path $root "spec\reporting-contract.md")
$example = [regex]::Match($contract, '(?s)## Example.*?```json\r?\n(.*?)```').Groups[1].Value
if (-not $example) {
    Fail "spec/reporting-contract.md: no json example under '## Example'"
} else {
    Test-Portfolio $example "spec/reporting-contract.md example" | Out-Null
}

# --- 8. Encoding -------------------------------------------------------
# Every file must be valid UTF-8 and free of mojibake, the trace left when
# UTF-8 is read as Windows-1252 and saved back as UTF-8 (an em dash becomes
# a-circumflex, euro sign, right quote). Built from char codes so this
# script stays ASCII.
$strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)
$mojibake = [string][char]0x00E2 + [char]0x20AC
$textFiles = @(Get-ChildItem -Path $root -Recurse -File -Force | Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' })
foreach ($file in $textFiles) {
    $relative = $file.FullName.Substring($root.Length + 1)
    try {
        $text = $strictUtf8.GetString([System.IO.File]::ReadAllBytes($file.FullName))
    }
    catch {
        Fail "${relative}: not valid UTF-8"
        continue
    }
    if ($text.Contains($mojibake)) {
        Fail "${relative}: contains garbled characters (UTF-8 read as Windows-1252 and saved)"
    }
}

# --- Result --------------------------------------------------------------
if ($script:failures.Count -gt 0) {
    Write-Host "`n$($script:failures.Count) check(s) failed." -ForegroundColor Red
    exit 1
}
Write-Host "All checks passed ($($mdFiles.Count) docs, $($skillFiles.Count) skills, $($steps.Count) brainstorm steps, $($textFiles.Count) files encoding-checked)." -ForegroundColor Green
