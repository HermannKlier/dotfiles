#requires -Version 5.1
# Update Gentle Shell (npm package gentle-pi) in a user-level Node.js install. Preview by default.
# Skips the native gentle-ai.exe build (blocked by spawn EPERM on enterprise Windows).
[CmdletBinding()]
param(
  [string]$Version = 'latest',
  [switch]$Apply,
  [switch]$Repair,
  [switch]$PersistSkipFlag
)
$ErrorActionPreference = 'Stop'
$package = 'gentle-pi'
$skipName = 'GENTLE_PI_SKIP_GENTLE_AI_INSTALL'

$npm = Get-Command 'npm.cmd' -ErrorAction SilentlyContinue
if (-not $npm) { throw 'npm.cmd not found in PATH. Check the user-level Node.js install.' }

$prefix = (& $npm.Source config get prefix).Trim()
if ($LASTEXITCODE -ne 0 -or -not $prefix) { throw 'Could not read npm prefix.' }
$prefix = [System.IO.Path]::GetFullPath($prefix)
$userRoot = [System.IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\') + '\'
if (-not $prefix.StartsWith($userRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw "npm prefix is outside the user profile: $prefix. Nothing changed (avoids admin-only locations)."
}
$pkgDir = Join-Path $prefix ('node_modules\' + $package)

$current = $null
$pkgJson = Join-Path $pkgDir 'package.json'
if (Test-Path -LiteralPath $pkgJson -PathType Leaf) {
  try { $current = (Get-Content -LiteralPath $pkgJson -Raw | ConvertFrom-Json).version } catch { $current = $null }
}
$broken = (Test-Path -LiteralPath $pkgDir) -and (-not $current -or -not (Test-Path -LiteralPath (Join-Path $pkgDir 'bin\gentle-shell.mjs') -PathType Leaf))

$target = $Version
if ($Version -eq 'latest') {
  $target = (& $npm.Source view $package version | Select-Object -Last 1)
  if ($LASTEXITCODE -ne 0 -or -not $target) { throw 'Could not query the npm registry (network or proxy).' }
  $target = $target.Trim()
}

$running = @()
try {
  $running = @(Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction Stop |
    Where-Object { $_.CommandLine -match 'gentle-pi|gentle-shell|pi-coding-agent' })
} catch { Write-Host '[WARN] Could not inspect running processes; close gentle-shell and pi manually.' -ForegroundColor Yellow }

$persisted = [Environment]::GetEnvironmentVariable($skipName, 'User')

Write-Host ("npm prefix:      " + $prefix)
Write-Host ("Installed:       " + $(if ($current) { $current } elseif ($broken) { 'BROKEN (incomplete install)' } else { 'not installed' }))
Write-Host ("Target:          " + $target)
Write-Host ("$skipName (user): " + $(if ($persisted) { $persisted } else { 'not set' }))
if ($running.Count -gt 0) { Write-Host ("[WARN] gentle-shell/pi running, PIDs: " + (($running | ForEach-Object { $_.ProcessId }) -join ', ')) -ForegroundColor Yellow }

$needsRepair = $Repair -or $broken
if ($current -eq $target -and -not $needsRepair) { Write-Host '[UNCHANGED] Gentle Shell already at target version.' }
else {
  if ($needsRepair) { Write-Host ("[PLAN] Uninstall $package and remove " + $pkgDir) }
  Write-Host ("[PLAN] npm.cmd install -g $package@$target  (with $skipName=1)")
}
if ($PersistSkipFlag -and $persisted -ne '1') { Write-Host "[PLAN] Set user environment variable $skipName=1" }

if (-not $Apply) { Write-Host 'PREVIEW ONLY: no files changed.' -ForegroundColor Yellow; return }

if ($PersistSkipFlag -and $persisted -ne '1') {
  [Environment]::SetEnvironmentVariable($skipName, '1', 'User')
  Write-Host "[UPDATED] User variable $skipName=1" -ForegroundColor Green
}
if ($current -eq $target -and -not $needsRepair) { Write-Host 'Nothing to apply.'; return }
if ($running.Count -gt 0) { throw 'Close every gentle-shell / pi window (including VS Code terminals) and run again. Nothing changed.' }

$env:GENTLE_PI_SKIP_GENTLE_AI_INSTALL = '1'

if ($needsRepair) {
  & $npm.Source uninstall -g $package
  if (Test-Path -LiteralPath $pkgDir) { Remove-Item -LiteralPath $pkgDir -Recurse -Force }
  Write-Host ("[UPDATED] Removed " + $pkgDir) -ForegroundColor Green
}

& $npm.Source install -g ("$package@$target")
if ($LASTEXITCODE -ne 0) {
  throw "npm install failed (exit $LASTEXITCODE). If you see EPERM, sign out of Windows and run again with -Apply -Repair."
}

$shell = Get-Command 'gentle-shell' -ErrorAction SilentlyContinue
if (-not $shell) { throw 'gentle-shell not found in PATH after install.' }
& $shell.Source --version
if ($LASTEXITCODE -ne 0) { throw 'gentle-shell --version failed after install.' }
Write-Host "[OK] Gentle Shell updated to $target. Native gentle-ai review stays disabled (spawn EPERM policy)." -ForegroundColor Green
Write-Host 'Next: run gentle-shell and inside it /gentle:status and /gentle:doctor.'
