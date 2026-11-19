#requires -Version 5.1
# Configure nvim-orgmode in user Neovim config. Preview by default.
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$OrgRoot,
  [string]$ConfigRoot = (Join-Path $env:LOCALAPPDATA 'nvim'),
  [switch]$Apply
)
$ErrorActionPreference = 'Stop'
$org = [System.IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($OrgRoot))
if (-not (Test-Path -LiteralPath $org -PathType Container)) { throw "Org folder does not exist: $org" }
$root = [System.IO.Path]::GetFullPath($ConfigRoot)
$plugins = Join-Path $root 'lua\plugins'
$cfg = Join-Path $root 'lua\config'
if (-not (Test-Path -LiteralPath (Join-Path $root 'init.lua') -PathType Leaf)) { throw "No Neovim init.lua in $root" }
$main = Join-Path $plugins 'orgmode.lua'
$duplicate = Join-Path $plugins 'user_orgmode.lua'
$local = Join-Path $cfg 'orgmode_windows.lua'
$override = Join-Path $PSScriptRoot 'nvim\overrides\orgmode.lua'
if (-not (Test-Path -LiteralPath $override -PathType Leaf)) { throw "Missing template: $override" }
$utf8 = New-Object System.Text.UTF8Encoding($false)
$normalized = $org.Replace('\','/')
if ($normalized.Contains(']]')) { throw 'Path contains unsupported Lua long string delimiter ]]' }
$localText = 'return { root = [[' + $normalized + ']] }' + "`r`n"
$mainText = [System.IO.File]::ReadAllText($override)
$duplicateText = "return {} -- orgmode configured by orgmode.lua`r`n"
if (Test-Path -LiteralPath $main -PathType Leaf) {
  $existing = [System.IO.File]::ReadAllText($main)
  if ($existing -ne $mainText -and -not $existing.Contains('"nvim-orgmode/orgmode"')) {
    throw "Unrecognized orgmode.lua: $main. Nothing changed."
  }
}
if (Test-Path -LiteralPath $duplicate -PathType Leaf) {
  $existing = [System.IO.File]::ReadAllText($duplicate)
  if ($existing -ne $duplicateText -and -not $existing.Contains('"nvim-orgmode/orgmode"')) {
    throw "Unrecognized user_orgmode.lua: $duplicate. Nothing changed."
  }
}
if (Test-Path -LiteralPath $local -PathType Leaf) {
  $existing = [System.IO.File]::ReadAllText($local)
  if ($existing -ne $localText) { throw "Local orgmode config already exists with different path: $local. Review manually." }
}
$planned = @()
foreach ($entry in @(@{Path=$main;Content=$mainText},@{Path=$duplicate;Content=$duplicateText},@{Path=$local;Content=$localText})) {
  $current = if (Test-Path -LiteralPath $entry.Path -PathType Leaf) { [System.IO.File]::ReadAllText($entry.Path) } else { $null }
  if ($null -eq $current -or $current -cne $entry.Content) { $planned += $entry }
}
$orgCount = @(Get-ChildItem -LiteralPath $org -Filter '*.org' -File -Recurse).Count
Write-Host ("Org folder: " + $org)
Write-Host ("Found .org files: " + $orgCount)
foreach ($entry in $planned) { Write-Host ("[PLAN] " + $entry.Path) }
if ($planned.Count -eq 0) { Write-Host '[UNCHANGED] Orgmode Windows configuration already matches.' }
if (-not $Apply) { Write-Host 'PREVIEW ONLY: no files changed.' -ForegroundColor Yellow; return }
if ($planned.Count -eq 0) { Write-Host 'Nothing to apply.'; return }
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path (Split-Path $root -Parent) ("nvim-orgmode-backup-$stamp")
if (Test-Path -LiteralPath $backup) { throw "Backup exists: $backup" }
New-Item -ItemType Directory -Path $backup | Out-Null
foreach ($entry in $planned) {
  if (Test-Path -LiteralPath $entry.Path -PathType Leaf) {
    $destination = Join-Path $backup ([System.IO.Path]::GetFileName($entry.Path))
    Copy-Item -LiteralPath $entry.Path -Destination $destination -ErrorAction Stop
  }
}
New-Item -ItemType Directory -Path $plugins -Force | Out-Null
New-Item -ItemType Directory -Path $cfg -Force | Out-Null
foreach ($entry in $planned) {
  [System.IO.File]::WriteAllText($entry.Path,$entry.Content,$utf8)
  Write-Host ("[UPDATED] " + $entry.Path) -ForegroundColor Green
}
Write-Host ("[OK] Backup folder: " + $backup) -ForegroundColor Green
Write-Host 'No .org notes were moved, copied, or uploaded. Validate :Org agenda in Neovim.'
