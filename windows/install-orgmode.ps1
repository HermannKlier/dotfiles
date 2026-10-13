#requires -Version 5.1
<#
  Configure nvim-orgmode on Windows without elevation.
  Default is preview. -Apply writes only selected user Neovim files after backup.
  Does NOT move or copy any personal .org notes.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$OrgRoot,
  [string]$ConfigRoot = (Join-Path $env:LOCALAPPDATA 'nvim'),
  [switch]$Apply
)
$ErrorActionPreference = 'Stop'
$org = [System.IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($OrgRoot))
if (-not (Test-Path -LiteralPath $org -PathType Container)) {
  throw "Org folder not found: $org. No files changed."
}
$root = [System.IO.Path]::GetFullPath($ConfigRoot)
$plugins = Join-Path $root 'lua\plugins'
$cfg = Join-Path $root 'lua\config'
$oldMain = Join-Path $plugins 'orgmode.lua'
$oldUser = Join-Path $plugins 'user_orgmode.lua'
$localConfig = Join-Path $cfg 'orgmode_windows.lua'
$override = Join-Path $PSScriptRoot 'nvim\overrides\orgmode.lua'
foreach ($f in @($oldMain,$oldUser,$override)) {
  if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { throw "Expected file missing: $f. No changes." }
}
$oldMainText = [System.IO.File]::ReadAllText($oldMain)
$oldUserText = [System.IO.File]::ReadAllText($oldUser)
if (-not $oldMainText.Contains('"nvim-orgmode/orgmode"') -or -not $oldUserText.Contains('"nvim-orgmode/orgmode"')) {
  throw 'Unexpected original orgmode plugin files. Inspect before overwriting; nothing changed.'
}
$normalized = $org.Replace('\','/')
if ($normalized.Contains('"') -or $normalized.Contains(']]')) {
  throw 'Unsupported folder path characters for local Lua configuration. Nothing changed.'
}
$localText = 'return { root = [[' + $normalized + ']] }' + "`r`n"
$overrideText = [System.IO.File]::ReadAllText($override)
$emptyText = "return {} -- orgmode configured by orgmode.lua`r`n"
if (Test-Path -LiteralPath $localConfig -PathType Leaf) {
  $existing = [System.IO.File]::ReadAllText($localConfig)
  if ($existing -ne $localText) {
    throw "Existing local orgmode settings found: $localConfig. Review manually. No changes."
  }
}
$orgCount = @(Get-ChildItem -LiteralPath $org -Filter '*.org' -File -Recurse -ErrorAction Stop).Count
Write-Host ('Org folder: ' + $org)
Write-Host ('Found .org files: ' + $orgCount)
Write-Host ('[PLAN] Backup ' + $oldMain + ', ' + $oldUser)
Write-Host ('[PLAN] Install merged plugin config into ' + $oldMain)
Write-Host ('[PLAN] Disable duplicate plugin config in ' + $oldUser)
Write-Host ('[PLAN] Set local paths in ' + $localConfig)
Write-Host 'No personal notes will be copied or uploaded.'
if (-not $Apply) { Write-Host 'PREVIEW ONLY: no files changed.' -ForegroundColor Yellow; return }
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path (Split-Path $root -Parent) ("nvim-orgmode-backup-$stamp")
if (Test-Path -LiteralPath $backup) { throw "Backup folder already exists: $backup" }
New-Item -ItemType Directory -Path $backup -ErrorAction Stop | Out-Null
Copy-Item -LiteralPath $oldMain,$oldUser -Destination $backup -ErrorAction Stop
if (Test-Path -LiteralPath $localConfig -PathType Leaf) {
  Copy-Item -LiteralPath $localConfig -Destination (Join-Path $backup 'orgmode_windows.lua') -ErrorAction Stop
}
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($oldMain, $overrideText, $utf8)
[System.IO.File]::WriteAllText($oldUser, $emptyText, $utf8)
[System.IO.File]::WriteAllText($localConfig, $localText, $utf8)
Write-Host ('[OK] Backup: ' + $backup) -ForegroundColor Green
Write-Host '[OK] Windows agenda configured. Validate in Neovim with :Org agenda' -ForegroundColor Green
if ($orgCount -eq 0) {
  Write-Warning 'No .org files were found. Copy your existing agenda files separately before expecting tasks.'
}
