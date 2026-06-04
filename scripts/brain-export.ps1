# Compiles Obsidian vault notes (cursor_rule: true) -> .cursor/rules/*.mdc
# Safe: skips .mdc files that were not generated from the vault.
param(
    [switch]$DryRun,
    [string]$ConfigPath = (Join-Path $PSScriptRoot "..\brain-sync.config.json")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ConfigPath)) {
    Write-Warning "brain-sync.config.json not found at $ConfigPath"
    exit 0
}

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$vaultPath = $config.vault_path
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$rulesDir = Join-Path $repoRoot $config.cursor_rules_dir

if (-not (Test-Path $vaultPath)) {
    Write-Warning "Vault not found: $vaultPath (skip export)"
    exit 0
}

if (-not (Test-Path $rulesDir)) {
    New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null
}

function Get-Frontmatter([string]$Content) {
    if ($Content -notmatch '(?s)\A---\r?\n(.*?)\r?\n---') { return $null }
    return $Matches[1]
}

function Get-FmValue([string]$Fm, [string]$Key) {
    if ($Fm -match "(?m)^${Key}:\s*(.+)$") {
        return $Matches[1].Trim().Trim('"')
    }
    return $null
}

function Get-FmGlobs([string]$Fm) {
    $m = [regex]::Match($Fm, 'cursor_globs:\s*\[(.*?)\]', 'Singleline')
    if (-not $m.Success) { return @() }
    return [regex]::Matches($m.Groups[1].Value, '"([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
}

function Strip-WikiLinks([string]$Text) {
    return [regex]::Replace($Text, '\[\[([^\]|]+)(?:\|[^\]]+)?\]\]', '$1')
}

function Get-Title([string]$Body) {
    if ($Body -match '(?m)^#\s+(.+)$') { return $Matches[1].Trim() }
    return "Exported rule"
}

$exported = 0
$skipped = 0
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

Get-ChildItem -Path $vaultPath -Recurse -Filter "*.md" -File |
    Where-Object { $_.FullName -notmatch '\\\.git\\|\\.obsidian\\' } |
    ForEach-Object {
        $raw = Get-Content $_.FullName -Raw -Encoding UTF8
        $fm = Get-Frontmatter $raw
        if (-not $fm) { return }
        if ($fm -notmatch '(?m)^cursor_rule:\s*true\s*$') { return }

        $relativeVault = $_.FullName.Substring($vaultPath.Length).TrimStart('\', '/')
        $slug = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $outFile = Join-Path $rulesDir "$slug.mdc"

        if ($config.skip_repo_native_rules -and (Test-Path $outFile)) {
            $existing = Get-Content $outFile -Raw -Encoding UTF8
            if ($existing -notmatch '<!--\s*source:\s*vault/') {
                Write-Host "SKIP (repo-native): $slug.mdc"
                $script:skipped++
                return
            }
        }

        $body = $raw -replace '(?s)\A---\r?\n.*?\r?\n---\r?\n?', ''
        $title = Get-Title $body
        $description = Get-FmValue $fm 'summary'
        if (-not $description) { $description = $title }
        $globs = Get-FmGlobs $fm
        $apply = Get-FmValue $fm 'cursor_apply'
        $alwaysApply = ($apply -eq 'always')

        $globsYaml = if ($globs.Count -gt 0) { ($globs -join ',') } else { '' }
        $cleanBody = Strip-WikiLinks $body

        $mdc = @"
---
description: $description
globs: $globsYaml
alwaysApply: $($alwaysApply.ToString().ToLower())
---

$cleanBody

<!-- source: vault/$relativeVault
     generated: $timestamp
     do not edit — edit the vault note and run: pwsh scripts/brain-export.ps1 -->
"@

        if ($DryRun) {
            Write-Host "DRY-RUN would write: $outFile"
        } else {
            [System.IO.File]::WriteAllText($outFile, $mdc.TrimEnd() + "`n", [System.Text.UTF8Encoding]::new($false))
            Write-Host "EXPORT: $relativeVault -> $slug.mdc"
        }
        $script:exported++
    }

Write-Host "brain-export done: $exported exported, $skipped skipped (repo-native)."
