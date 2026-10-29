#requires -Version 5.1
<#
.SYNOPSIS
  Entrypoint asistido, vista previa por defecto.
.DESCRIPTION
  No cambia las politicas de seguridad. Instalar solo componentes aprobados.
  La fase Tools cubre GCC, fzf y LazyGit; Engram requiere Gentle Shell preinstalado.
#>
[CmdletBinding()]
param(
 [switch]$Apply,
 [ValidateSet('All','Tools','Engram')][string]$Component='All',
 [string]$EngramZip=(Join-Path $HOME 'Downloads\engram_3.6.0_windows_amd64.zip'),
 [string]$EngramSha256=''
)
$ErrorActionPreference='Stop'
Write-Host 'Windows corporativo: aplicar solo con autorizacion TI; no elevar privilegios.'
& (Join-Path $PSScriptRoot 'verify.ps1')
if ($Component -in @('All','Tools')) {
 Write-Host '[STAGE] GCC, fzf, LazyGit'
 & (Join-Path $PSScriptRoot 'install.ps1') -Apply:$Apply
}
if ($Component -in @('All','Engram')) {
 Write-Host '[STAGE] Gentle Shell (prerrequisito) + Engram'
 & (Join-Path $PSScriptRoot 'setup-engram.ps1') -Apply:$Apply -ZipPath $EngramZip -ApprovedSha256 $EngramSha256
}
Write-Host '[INFO] Git, Node.js, Go, Neovim y Gentle Shell empaquetado todavia requieren instalacion autorizada aparte.'
