<#
.SYNOPSIS
    Checks that the template still produces a working project.

.DESCRIPTION
    Runs new-project.ps1 into a temp folder (new project, and -IntoExisting
    on a fake repo) and checks:
      - no script placeholders are left (<Project name>, <hosting>, ...)
      - relative Markdown links and `docs/NN-*.md` references resolve
      - every SKILL.md has frontmatter with a name matching its folder and
        a description
      - the brainstorm steps copied into /new-project still match /brainstorm

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
        foreach ($placeholder in '<Project name>', '<project-name>', '<hosting>', '<template-dir>') {
            if ($text.Contains($placeholder)) {
                Fail "$($file.FullName.Substring($project.Length + 1)): $placeholder not filled in"
            }
        }
    }
    if (-not (Read-Text (Join-Path $project "AGENTS.md")).Contains("**Hosting: github**")) {
        Fail "AGENTS.md: hosting line not set to github"
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
}
finally {
    Remove-Item -Path $tempDir -Recurse -Force
}

# --- 3. Skill frontmatter ------------------------------------------------
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

# --- 4. Brainstorm steps in /new-project match /brainstorm ---------------
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

# --- Result --------------------------------------------------------------
if ($script:failures.Count -gt 0) {
    Write-Host "`n$($script:failures.Count) check(s) failed." -ForegroundColor Red
    exit 1
}
Write-Host "All checks passed ($($mdFiles.Count) docs, $($skillFiles.Count) skills, $($steps.Count) brainstorm steps)." -ForegroundColor Green
