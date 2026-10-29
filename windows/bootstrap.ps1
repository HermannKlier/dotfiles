#requires -Version 5.1
# Punto de entrada. Predeterminado: solo diagnostico.
[CmdletBinding()]
param([switch]$Apply,[ValidateSet('All','Tools','Engram')][string]$Component='All',[string]$EngramZip="$HOME\Downloads\engram_3.6.0_windows_amd64.zip",[string]$EngramSha256="")
$ErrorActionPreference='Stop'
Write-Host 'Windows corporativo: no cambiar politica de ejecucion ni elevar privilegios.'
& "$PSScriptRoot\verify.ps1"
if ($Component -in @('All','Tools')) {
 Write-Host '[STAGE] Herramientas GCC, fzf, LazyGit'
 & "$PSScriptRoot\install.ps1" -Apply:$Apply
 if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {throw 'Falló install.ps1'}
}
if ($Component -in @('All','Engram')) {
 Write-Host '[STAGE] Engram + Gentle Shell (Shell empaquetado es prerequisito)'
 & "$PSScriptRoot\setup-engram.ps1" -Apply:$Apply -ZipPath $EngramZip -ApprovedSha256 $EngramSha256
 if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {throw 'Falló setup-engram.ps1'}
}
Write-Host 'No se instala automaticamente Git, Node.js, Go, Neovim ni Gentle Shell: requieren descarga/verificacion oficial y permiso TI.'
