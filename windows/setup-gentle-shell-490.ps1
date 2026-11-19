#requires -Version 5.1
<#
.SYNOPSIS
  Vista previa / instalacion aislada de Gentle Shell 4.9.0 JS en Windows empresarial.
.DESCRIPTION
  Sin -Apply: solo lectura. Con -Apply, y autorizacion TI, instala gentle-pi
  usando npm --ignore-scripts en %USERPROFILE%\apps\GENTLE_SHELL_490.
  NO reemplaza una instalacion 4.8, no migra sesiones ni credenciales,
  NO modifica Engram ni desactiva controles corporativos.
  El camino -Apply NO ha sido probado de extremo a extremo en una PC nueva.
#>
[CmdletBinding()]
param([switch]$Apply)
$ErrorActionPreference = 'Stop'
if (-not $env:USERPROFILE) { throw 'No se encuentra USERPROFILE.' }
$root = Join-Path $env:USERPROFILE 'apps\GENTLE_SHELL_490'
$pkg = Join-Path $root 'node_modules\gentle-pi\package.json'
$entry = Join-Path $root 'node_modules\gentle-pi\bin\gentle-shell.mjs'
$piHome = Join-Path $root 'agent-home'
$conf = Join-Path $root 'config'
$bin = Join-Path $env:USERPROFILE 'apps\bin'
$launcher = Join-Path $bin 'gentle-shell.cmd'
$node = Get-Command node.exe -ErrorAction SilentlyContinue
$npm = Get-Command npm.cmd -ErrorAction SilentlyContinue
if (-not $node -or -not $npm) { throw 'Node.js y npm.cmd deben instalarse primero por un metodo autorizado.' }
$nodePath = $node.Source
if (Test-Path -LiteralPath $root) {
  if (-not (Test-Path -LiteralPath $pkg -PathType Leaf) -or -not (Test-Path -LiteralPath $entry -PathType Leaf)) {
    throw 'Carpeta Gentle Shell 4.9 existente pero incompleta. No se sobrescribe.'
  }
  $installedVersion = (Get-Content -LiteralPath $pkg -Raw | ConvertFrom-Json).version
  if ($installedVersion -ne '4.9.0') { throw "Version inesperada en destino: $installedVersion" }
  $installed = $true
} else { $installed = $false }
$lines = @(
  '@echo off',
  'set "GENTLE_SHELL_NO_AUTO_SETUP=1"',
  'set "GENTLE_PI_CONFIG_HOME=%USERPROFILE%\apps\GENTLE_SHELL_490\config"',
  'set "ENGRAM_URL=http://127.0.0.1:7437"',
  ('"' + $nodePath + '" "%USERPROFILE%\apps\GENTLE_SHELL_490\node_modules\gentle-pi\bin\gentle-shell.mjs" --home "%USERPROFILE%\apps\GENTLE_SHELL_490\agent-home" %*')
)
$expected = $lines -join [Environment]::NewLine
$launcherExists = Test-Path -LiteralPath $launcher -PathType Leaf
if ($launcherExists) {
  $actual = (Get-Content -LiteralPath $launcher -Raw).Trim()
  $normalized = $actual.Replace([string][char]13, '')
  $normalizedExpected = $expected.Replace([string][char]13, '')
  if ($normalized -cne $normalizedExpected) {
    throw "Hay otro lanzador en $launcher. No se sobreescribe ni en modo -Apply. Usar migracion manual con respaldo."
  }
}
Write-Host "[INFO] gentle-pi@4.9.0: $(if ($installed) { 'PRESENT' } else { 'MISSING' })"
Write-Host "[INFO] Node: $nodePath"
Write-Host "[INFO] Home: $piHome"
Write-Host "[INFO] Lanzador: $launcher"
Write-Host '[INFO] No instala Gentle AI nativo, Engram, Git Bash, auth ni datos corporativos.'
if (-not $Apply) { Write-Host '[PREVIEW] Sin cambios.'; return }
if (-not $installed) {
  & $npm.Source install --prefix $root --ignore-scripts --no-audit --no-fund gentle-pi@4.9.0
  if ($LASTEXITCODE -ne 0) { throw 'npm install fallo. Revisar carpeta de destino sin repetir automaticamente.' }
  if (-not (Test-Path -LiteralPath $entry -PathType Leaf) -or -not (Test-Path -LiteralPath $pkg -PathType Leaf)) {
    throw 'Paquete incompleto tras npm install.'
  }
  $installedVersion = (Get-Content -LiteralPath $pkg -Raw | ConvertFrom-Json).version
  if ($installedVersion -ne '4.9.0') { throw "Version incorrecta: $installedVersion" }
}
foreach ($dir in @($piHome, $conf, $bin)) {
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -ErrorAction Stop | Out-Null }
}
if (-not $launcherExists) {
  [System.IO.File]::WriteAllText($launcher, ($expected + [Environment]::NewLine), [System.Text.Encoding]::ASCII)
}
$userPath = [Environment]::GetEnvironmentVariable('Path','User')
$parts = @($userPath -split ';' | Where-Object { $_ -and $_.Trim() -and $_.TrimEnd('\') -ine $bin.TrimEnd('\') })
$nextPath = (@($bin) + $parts) -join ';'
if ($nextPath -ne $userPath) { [Environment]::SetEnvironmentVariable('Path',$nextPath,'User') }
Write-Host '[DONE] Abrir PowerShell nuevo y verificar gentle-shell --version.'
Write-Host '[NEXT] Autenticar por OAuth, configurar Git Bash y gentle-engram 0.4.2 por separado.'
