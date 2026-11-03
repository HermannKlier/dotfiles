#requires -Version 5.1
<#
.SYNOPSIS
  Vista previa asistida del entorno Windows corporativo.
.DESCRIPTION
  Modo normal: solo consultas. -Apply requiere seleccionar Tools o Engram de forma
  explicita; no se admite -Apply -Component All para evitar cambios masivos.
  Tools instala solo GCC, fzf o LazyGit (componente especifico obligatorio).
  Engram requiere Gentle Shell empaquetado preinstalado y ZIP oficial verificable.
  Nunca eleva privilegios ni cambia politicas de seguridad.
#>
[CmdletBinding()]
param(
  [switch]$Apply,
  [ValidateSet('All','Tools','Engram')][string]$Component = 'All',
  [ValidateSet('All','GCC','fzf','LazyGit')][string]$ToolComponent = 'All',
  [string]$EngramZip = (Join-Path $HOME 'Downloads\engram_3.6.0_windows_amd64.zip'),
  [string]$EngramSha256 = ''
)
$ErrorActionPreference = 'Stop'
$verify = Join-Path $PSScriptRoot 'verify.ps1'
$toolsScript = Join-Path $PSScriptRoot 'install.ps1'
$engramScript = Join-Path $PSScriptRoot 'setup-engram.ps1'

if ($Apply -and $Component -eq 'All') {
  throw 'Para aplicar cambios, elegir explicitamente -Component Tools o -Component Engram. All solo admite preview.'
}
if ($Apply -and $Component -eq 'Tools' -and $ToolComponent -eq 'All') {
  throw 'Para instalar herramientas, seleccionar -ToolComponent GCC, fzf o LazyGit.'
}
if ($Component -ne 'Tools' -and $ToolComponent -ne 'All') {
  throw '-ToolComponent solo se admite con -Component Tools.'
}
foreach ($script in @($verify, $toolsScript, $engramScript)) {
  if (-not (Test-Path -LiteralPath $script -PathType Leaf)) {
    throw "Script requerido no encontrado: $script"
  }
}
Write-Host '[INFO] Windows corporativo: respetar permisos y politicas TI.'
& $verify
if ($Component -in @('All','Tools')) {
  Write-Host "[STAGE] Herramientas: $ToolComponent"
  & $toolsScript -Apply:$Apply -Component $ToolComponent
}
if ($Component -in @('All','Engram')) {
  Write-Host '[STAGE] Engram para Gentle Shell aislado'
  & $engramScript -Apply:$Apply -ZipPath $EngramZip -ApprovedSha256 $EngramSha256
}
Write-Host '[INFO] Git, Node.js, Go, Neovim, Herdr, WezTerm y Gentle Shell empaquetado requieren pasos separados.'
if (-not $Apply) {
  Write-Host '[PREVIEW] Bootstrap terminado sin realizar instalaciones.'
}
