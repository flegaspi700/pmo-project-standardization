<#
.SYNOPSIS
    Checks that the template still produces a working project.

.DESCRIPTION
    Runs new-project.ps1 into a temp folder (new project, -IntoExisting on a
    fake repo with a README and a CLAUDE.md, -ReportOnly) and checks:
      - the starter files are there and scaffold\extras isn't copied
      - no script placeholders are left (<Project name>, <hosting>, ...)
      - AGENTS.md has the **Standard:** line with a vX.Y.Z version
      - existing files (README.md, CLAUDE.md) are never changed, and the
        dry run flags a CLAUDE.md that needs '@AGENTS.md'
      - -ReportOnly adds portfolio.json and nothing else
      - portfolio.json (and the example in spec/reporting-contract.md) is
        valid JSON and fits spec/portfolio.schema.json
      - compliance (spec v2): new and -IntoExisting projects reach level 3,
        -ReportOnly level 1, a v1.5.1 project level 1 with its v1-only
        checks applied (and n/a on v2 projects); W1 warns about a CLAUDE.md
        without '@AGENTS.md', W4 about a v1 skill copy;
        spec/compliance-checks.json is well formed
      - update-plan.ps1, on a v1 project generated from the v1.5.1 tag,
        sorts files into ADD / REPLACE / MERGE / UP-TO-DATE and detects an
        unstamped project's base version
      - relative Markdown links and `docs/*.md` references resolve (to a
        starter file or an extra); extras have no relative links
      - every SKILL.md has frontmatter with a name matching its folder and
        a description
      - every v2 skill in skills\ runs skills\preflight.md and looks itself
        up by its own name; install-skills.ps1 links every skill and a
        second run changes nothing
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
# Get-UpdatePlan, Find-BaseVersion and Get-TemplateFileAt
. (Join-Path $root "update-plan.ps1")

function Write-Utf8($path, $text) {
    [System.IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding($false)))
}

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

# True when the folder's compliance report has a warning from that check
function Test-Warning($folder, $id) {
    [bool](@((Get-Compliance $folder "2999-01-01").Warnings) | Where-Object { $_ -like "$id *" })
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

    # The starter files, and nothing from extras\
    foreach ($expectedFile in 'AGENTS.md', 'README.md', 'portfolio.json', '.gitignore', 'docs\requirements.md', 'docs\decisions.md', 'docs\session-log.md') {
        if (-not (Test-Path (Join-Path $project $expectedFile))) { Fail "new project: $expectedFile missing" }
    }
    if (Test-Path (Join-Path $project "extras")) { Fail "new project: scaffold\extras was copied in" }

    # Placeholders the script must fill. Other <...> placeholders are for the
    # user and are expected.
    foreach ($file in $mdFiles) {
        $text = Read-Text $file.FullName
        foreach ($placeholder in '<Project name>', '<project-name>', '<hosting>', '<standard-version>') {
            if ($text.Contains($placeholder)) {
                Fail "$($file.FullName.Substring($project.Length + 1)): $placeholder not filled in"
            }
        }
    }
    if (-not (Read-Text (Join-Path $project "AGENTS.md")).Contains("**Hosting: github**")) {
        Fail "AGENTS.md: hosting line not set to github"
    }
    if ((Read-Text (Join-Path $project "AGENTS.md")) -notmatch '\*\*Standard:\*\* pmo-project-standardization v\d+\.\d+\.\d+') {
        Fail "AGENTS.md: no '**Standard:** pmo-project-standardization vX.Y.Z' line"
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
        # A docs/ reference must be a starter file, or an extra the agent
        # adds when the project needs it
        foreach ($match in [regex]::Matches($text, 'docs/[a-z0-9-]+\.md')) {
            $inProject = Test-Path (Join-Path $project $match.Value)
            $isExtra = Test-Path (Join-Path $root "scaffold\extras\$($match.Value)")
            if (-not $inProject -and -not $isExtra) {
                Fail "${relative}: refers to $($match.Value), which is neither a starter file nor an extra"
            }
        }
    }

    # Extras are copied later by the agent, so they can't rely on relative
    # links, and the script never fills their placeholders
    foreach ($file in Get-ChildItem (Join-Path $root "scaffold\extras") -Recurse -File -Force) {
        $text = Read-Text $file.FullName
        $relative = $file.FullName.Substring($root.Length + 1)
        foreach ($match in [regex]::Matches($text, '\]\(([^)\s]+)\)')) {
            if ($match.Groups[1].Value -notmatch '^(https?:|mailto:|#)') { Fail "${relative}: relative link ($($match.Groups[1].Value))" }
        }
        foreach ($placeholder in '<Project name>', '<project-name>', '<hosting>', '<standard-version>') {
            if ($text.Contains($placeholder)) { Fail "${relative}: uses the script placeholder $placeholder" }
        }
    }

    # --- 2. Template added to an existing repo ---------------------------
    $existing = Join-Path $tempDir "existing-repo"
    git init --quiet $existing
    [System.IO.File]::WriteAllText((Join-Path $existing "README.md"), "# Existing repo`n")
    [System.IO.File]::WriteAllText((Join-Path $existing "CLAUDE.md"), "# Notes`n")

    $dryRun = & (Join-Path $root "new-project.ps1") -Name "Existing Repo" -Destination $tempDir -IntoExisting -Hosting github -DryRun 6>&1 | Out-String
    if (@(Get-ChildItem -Path $existing -File).Count -ne 2 -or @(Get-ChildItem -Path $existing -Directory).Count -ne 0) {
        Fail "-DryRun changed files in the existing repo"
    }
    if ($dryRun -notmatch 'KEEP.*README\.md') {
        Fail "-DryRun didn't list README.md as KEEP"
    }
    if ($dryRun -notmatch 'CLAUDE\.md exists') {
        Fail "-DryRun didn't mention the CLAUDE.md that needs '@AGENTS.md'"
    }

    & (Join-Path $root "new-project.ps1") -Name "Existing Repo" -Destination $tempDir -IntoExisting -Hosting github 3>$null | Out-Null
    if ((Read-Text (Join-Path $existing "README.md")) -ne "# Existing repo`n") {
        Fail "-IntoExisting overwrote the existing README.md"
    }
    if ((Read-Text (Join-Path $existing "CLAUDE.md")) -ne "# Notes`n") {
        Fail "-IntoExisting changed CLAUDE.md (only the agent edits it, after asking)"
    }
    if (-not (Test-Path (Join-Path $existing "AGENTS.md"))) {
        Fail "-IntoExisting didn't add AGENTS.md"
    }

    # -ReportOnly adds portfolio.json and nothing else
    $reportRepo = Join-Path $tempDir "report-repo"
    git init --quiet $reportRepo
    & (Join-Path $root "new-project.ps1") -Name "Report Repo" -Destination $tempDir -ReportOnly | Out-Null
    $added = @(Get-ChildItem -Path $reportRepo -Recurse -File -Force | Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' })
    if ($added.Count -ne 1 -or $added[0].Name -ne 'portfolio.json') {
        Fail "-ReportOnly added $($added.Count) file(s), expected only portfolio.json"
    } else {
        $reported = Test-Portfolio (Read-Text $added[0].FullName) "-ReportOnly portfolio.json"
        if ($reported -and $reported.name -ne "Report Repo") { Fail "-ReportOnly: name not filled in" }
    }

    # --- 3. Compliance levels ------------------------------------------
    # Fresh projects pass every required check; the levels below them work
    Test-Level $project 3 "new project"
    Test-Level $existing 3 "-IntoExisting repo"
    Test-Level $reportRepo 1 "-ReportOnly repo"

    # Warnings: a CLAUDE.md without the import line (W1), until it gets one;
    # a v1 copy of a skill in a v2 project (W4)
    if (-not (Test-Warning $existing 'W1')) { Fail "compliance: CLAUDE.md without '@AGENTS.md' didn't warn (W1)" }
    Write-Utf8 (Join-Path $existing "CLAUDE.md") "@AGENTS.md`n# Notes`n"
    if (Test-Warning $existing 'W1') { Fail "compliance: CLAUDE.md with '@AGENTS.md' still warns (W1)" }
    if (Test-Warning $project 'W4') { Fail "compliance: fresh project warns about old skill copies (W4)" }
    $shadowed = Join-Path $tempDir "shadowed"
    Copy-Item $project $shadowed -Recurse
    New-Item -ItemType Directory -Path (Join-Path $shadowed ".claude\skills\story") -Force | Out-Null
    Write-Utf8 (Join-Path $shadowed ".claude\skills\story\SKILL.md") "---`nname: story`n---`n"
    if (-not (Test-Warning $shadowed 'W4')) { Fail "compliance: a .claude/skills/story copy didn't warn (W4)" }
    Test-Level $shadowed 3 "project with an old skill copy (warning only)"
    $empty = Join-Path $tempDir "empty-repo"
    New-Item -ItemType Directory -Path $empty | Out-Null
    Test-Level $empty 0 "empty folder"
    $reportingOnly = Join-Path $tempDir "reporting-only"
    New-Item -ItemType Directory -Path $reportingOnly | Out-Null
    Copy-Item (Join-Path $project "portfolio.json") $reportingOnly
    Test-Level $reportingOnly 1 "folder with only portfolio.json"

    # --- 4. Update plan (update-plan.ps1) --------------------------------
    # Fixed tags, so these hold however the template changes later:
    # v1.2.0 -> v1.4.0 changed report, wrap-up, AGENTS.md, added portfolio.json
    # The v1 project is generated by the v1.5.1 script and template, taken
    # from git, so it doesn't depend on today's (v2) new-project.ps1.
    $v1 = Join-Path $tempDir "v1.5.1"
    New-Item -ItemType Directory -Path $v1 | Out-Null
    git -C $root archive --format=zip -o (Join-Path $tempDir "v1.5.1.zip") v1.5.1 new-project.ps1 project-template
    Expand-Archive (Join-Path $tempDir "v1.5.1.zip") $v1
    # The v1 script stamps the version from git, so give it a repo tagged v1.5.1
    git -C $v1 init --quiet
    git -C $v1 add -A
    git -C $v1 -c user.name=check -c user.email=check@example.invalid commit --quiet -m v1.5.1
    git -C $v1 tag v1.5.1
    & (Join-Path $v1 "new-project.ps1") -Name "Old Project" -Destination $tempDir -Hosting github | Out-Null
    $old = Join-Path $tempDir "old-project"
    # Under the v2 spec a v1 project reports (level 1) but isn't adopted,
    # and its v1-only checks apply to it
    Test-Level $old 1 "v1.5.1 project"
    $c3 = (Get-Compliance $old "2999-01-01").Results | Where-Object { $_.Id -eq 'C3' }
    if ($c3.Pass -ne $true) { Fail "compliance: v1-only check C3 should apply to and pass on a v1 project" }
    $c3New = (Get-Compliance $project "2999-01-01").Results | Where-Object { $_.Id -eq 'C3' }
    if ($null -ne $c3New.Pass) { Fail "compliance: v1-only check C3 should be n/a on a v2 project" }
    $skillsDir = Join-Path $old ".claude\skills"
    Write-Utf8 (Join-Path $skillsDir "report\SKILL.md") (Get-TemplateFileAt "v1.2.0" "project-template/.claude/skills/report/SKILL.md")
    Remove-Item (Join-Path $skillsDir "wrap-up\SKILL.md")
    Write-Utf8 (Join-Path $old "portfolio.json") (Get-TemplateFileAt "v1.4.0" "project-template/portfolio.json")
    $plan = Get-UpdatePlan $old "v1.2.0" "v1.4.0"
    $expected = @{
        ".claude/skills/report/SKILL.md"  = "REPLACE"
        ".claude/skills/wrap-up/SKILL.md" = "ADD"
        "portfolio.json"                  = "UP-TO-DATE"
        "AGENTS.md"                       = "MERGE"
    }
    foreach ($path in $expected.Keys) {
        $got = ($plan.Files | Where-Object { $_.Path -eq $path }).Action
        if ($got -ne $expected[$path]) { Fail "update plan: $path is '$got', expected '$($expected[$path])'" }
    }
    if (@($plan.Changelog).Count -ne 2) {
        Fail "update plan: expected the v1.3.0 and v1.4.0 CHANGELOG entries, got $(@($plan.Changelog).Count)"
    }

    # No stamp: the base is detected from the skills. Skills didn't change
    # from v1.0.0 to v1.2.0, so v1.1.0 skills give the oldest tie, v1.0.0.
    $agentsPath = Join-Path $old "AGENTS.md"
    Write-Utf8 $agentsPath ((Read-Text $agentsPath) -replace '\*\*Template version: [^*]+\*\*', '')
    foreach ($skill in Get-ChildItem $skillsDir -Directory) {
        $text = Get-TemplateFileAt "v1.1.0" "project-template/.claude/skills/$($skill.Name)/SKILL.md"
        if ($null -eq $text) { Remove-Item $skill.FullName -Recurse } else { Write-Utf8 (Join-Path $skill.FullName "SKILL.md") $text }
    }
    $base = Find-BaseVersion $old (Get-TemplateTags)
    if ($base.Version -ne "v1.0.0") { Fail "update plan: detected base $($base.Version), expected v1.0.0 ($($base.How))" }
}
finally {
    Remove-Item -Path $tempDir -Recurse -Force
}

# --- 5. Compliance check registry ----------------------------------------
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

# --- 6. Skill frontmatter ------------------------------------------------
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

# --- 6b. v2 skills run the preflight -------------------------------------
# Every skill in skills\ except the two template commands must read
# skills\preflight.md, and look itself up by its own name (a copy-pasted
# name would resolve the wrong junction).
if (-not (Test-Path (Join-Path $root "skills\preflight.md"))) {
    Fail "skills/preflight.md is missing"
}
$v2Skills = @(Get-ChildItem (Join-Path $root "skills") -Directory | Where-Object {
    (Test-Path (Join-Path $_.FullName "SKILL.md")) -and $_.Name -notin 'new-project', 'update-template'
})
foreach ($skill in $v2Skills) {
    $text = Read-Text (Join-Path $skill.FullName "SKILL.md")
    if (-not $text.Contains('<template-dir>\skills\preflight.md')) {
        Fail "skills/$($skill.Name)/SKILL.md: doesn't read <template-dir>\skills\preflight.md"
    }
    if (-not $text.Contains(".claude\skills\$($skill.Name)`"")) {
        Fail "skills/$($skill.Name)/SKILL.md: the template-folder lookup doesn't use its own name"
    }
}

# --- 6c. install-skills.ps1 -------------------------------------------------
# Installs into a throwaway profile. Junctions are removed one by one with
# DirectoryInfo.Delete(): a recursive delete could follow them into this repo.
$fakeProfile = Join-Path ([System.IO.Path]::GetTempPath()) ("skills-check-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
$realProfile = $env:USERPROFILE
try {
    $env:USERPROFILE = $fakeProfile
    & (Join-Path $root "install-skills.ps1") | Out-Null
    $installed = Join-Path $fakeProfile ".claude\skills"
    foreach ($skill in Get-ChildItem (Join-Path $root "skills") -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }) {
        $link = Get-Item (Join-Path $installed $skill.Name) -Force -ErrorAction SilentlyContinue
        if (-not $link -or $link.LinkType -ne 'Junction' -or (@($link.Target)[0].TrimEnd('\') -ne $skill.FullName.TrimEnd('\'))) {
            Fail "install-skills.ps1: no junction for '$($skill.Name)' pointing at skills\$($skill.Name)"
        }
    }
    $again = & (Join-Path $root "install-skills.ps1") 6>&1 | Out-String
    if ($again -notmatch 'Linked 0 skill\(s\), skipped 0') {
        Fail "install-skills.ps1: a second run should change nothing"
    }
}
finally {
    $env:USERPROFILE = $realProfile
    if (Test-Path (Join-Path $fakeProfile ".claude\skills")) {
        Get-ChildItem (Join-Path $fakeProfile ".claude\skills") -Force | Where-Object { $_.LinkType -eq 'Junction' } | ForEach-Object { $_.Delete() }
    }
    if (Test-Path $fakeProfile) { Remove-Item $fakeProfile -Recurse -Force }
}

# --- 7. Brainstorm steps in /new-project match /brainstorm ---------------
# Each numbered step in /new-project's "1b. Brainstorm" section must appear
# word for word (ignoring line wrapping) in the /brainstorm skill.
$newProject = Read-Text (Join-Path $root "skills\new-project\SKILL.md")
$brainstorm = Normalize (Read-Text (Join-Path $root "skills\brainstorm\SKILL.md"))
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

# --- 8. Reporting contract example ---------------------------------------
# The example in spec/reporting-contract.md must fit the schema too.
$contract = Read-Text (Join-Path $root "spec\reporting-contract.md")
$example = [regex]::Match($contract, '(?s)## Example.*?```json\r?\n(.*?)```').Groups[1].Value
if (-not $example) {
    Fail "spec/reporting-contract.md: no json example under '## Example'"
} else {
    Test-Portfolio $example "spec/reporting-contract.md example" | Out-Null
}

# --- 9. Encoding -------------------------------------------------------
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
