#requires -Version 5.1
<#
Preview-first recovery installer for Gentle Shell 4.8.0 JS in enterprise Windows.
Never changes security policy; -Apply only with corporate approval.
The -Apply path is UNTESTED on a fresh PC. No secrets or Engram DB are copied.
#>
[CmdletBinding()]
param([switch]$Apply)
$ErrorActionPreference = 'Stop'
if (-not $env:USERPROFILE) { throw 'USERPROFILE unavailable.' }
$root = Join-Path $env:USERPROFILE 'apps\GENTLE_SHELL_480'
$entry = Join-Path $root 'node_modules\gentle-pi\bin\gentle-shell.mjs'
$pkgJson = Join-Path $root 'node_modules\gentle-pi\package.json'
$bin = Join-Path $env:USERPROFILE 'apps\bin'
$launcher = Join-Path $bin 'gentle-shell.cmd'
$npm = Get-Command npm.cmd -ErrorAction SilentlyContinue
$node = Get-Command node.exe -ErrorAction SilentlyContinue
if (-not $npm -or -not $node) { throw 'Node.js and npm.cmd must be available first.' }
$nodePath = $node.Source
if (Test-Path -LiteralPath $root) {
  if (-not (Test-Path -LiteralPath $entry) -or -not (Test-Path -LiteralPath $pkgJson)) {
    throw "Existing installation incomplete: $root. No changes made."
  }
  $version = (Get-Content -LiteralPath $pkgJson -Raw | ConvertFrom-Json).version
  if ($version -ne '4.8.0') { throw "Unexpected existing gentle-pi version $version. No changes made." }
  $installed = $true
} else { $installed = $false }
$lines = @(
  '@echo off',
  'set "GENTLE_SHELL_NO_AUTO_SETUP=1"',
  'set "GENTLE_PI_CONFIG_HOME=%USERPROFILE%\apps\GENTLE_SHELL_480\config"',
  'set "ENGRAM_URL=http://127.0.0.1:7437"',
  ('"' + $nodePath + '" "%USERPROFILE%\apps\GENTLE_SHELL_480\node_modules\gentle-pi\bin\gentle-shell.mjs" --home "%USERPROFILE%\apps\GENTLE_SHELL_480\agent-home" %*')
)
$expected = $lines -join [Environment]::NewLine
if (Test-Path -LiteralPath $launcher) {
  $actual = (Get-Content -LiteralPath $launcher -Raw).Trim()
  if (($actual -replace '\r\n', [string][char]10) -cne ($expected -replace '\r\n', [string][char]10)) {
    throw "Other launcher already exists: $launcher. No changes made."
  }
}
Write-Host "[INFO] Node: $nodePath"
Write-Host "[INFO] Source: gentle-pi@4.8.0 (npm, JS only; no native bundle)"
Write-Host "[INFO] Target: $root"
Write-Host "[INFO] Launcher: $launcher"
Write-Host "[INFO] Already installed: $installed"
Write-Host '[INFO] Does not install Engram, Gentle AI native, auth, shells or project memory.'
if (-not $Apply) { Write-Host '[PREVIEW] No changes made.'; return }
if (-not $installed) {
  & $npm.Source install --prefix $root --ignore-scripts --no-audit --no-fund gentle-pi@4.8.0
  if ($LASTEXITCODE -ne 0) { throw 'npm install failed; inspect target manually.' }
  if (-not (Test-Path -LiteralPath $entry) -or -not (Test-Path -LiteralPath $pkgJson)) {
    throw 'Missing package files after npm install.'
  }
  $version = (Get-Content -LiteralPath $pkgJson -Raw | ConvertFrom-Json).version
  if ($version -ne '4.8.0') { throw "Unexpected installed version: $version" }
}
foreach ($dir in @((Join-Path $root 'agent-home'),(Join-Path $root 'config'),$bin)) {
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -ErrorAction Stop | Out-Null }
}
if (-not (Test-Path -LiteralPath $launcher)) {
  [System.IO.File]::WriteAllText($launcher, ($expected + [Environment]::NewLine), [System.Text.Encoding]::ASCII)
}
$oldPath = [Environment]::GetEnvironmentVariable('Path','User')
$parts = @($oldPath -split ';' | Where-Object { $_ -and $_.Trim() -and $_.TrimEnd('\') -ine $bin.TrimEnd('\') })
$newPath = (@($bin) + $parts) -join ';'
if ($oldPath -ne $newPath) { [Environment]::SetEnvironmentVariable('Path',$newPath,'User') }
Write-Host '[DONE] Open a new PowerShell and verify Get-Command gentle-shell -All and gentle-shell --version.'
Write-Host '[NEXT] Configure authorized Git Bash, authentication and gentle-engram separately. Do not copy secrets from GitHub.'
