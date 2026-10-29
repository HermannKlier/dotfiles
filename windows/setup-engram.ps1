#requires -Version 5.1
# Engram Windows: preview by default; install only with -Apply.
[CmdletBinding()]
param([switch]$Apply,[string]$ZipPath="$HOME\Downloads\engram_3.6.0_windows_amd64.zip",[string]$ApprovedSha256="")
$ErrorActionPreference='Stop'
$exe="$HOME\apps\engram\engram.exe"
$shell="$env:LOCALAPPDATA\gentle-shell\bin\gentle-shell.cmd"
$name='Engram - Memoria Local'
if (!(Test-Path $shell)) {throw 'Instalar primero Gentle Shell empaquetado oficial'}
if (!(Test-Path $exe)) {
 if (!(Test-Path $ZipPath)) {throw 'Falta ZIP oficial Engram'}
 if ($ApprovedSha256 -notmatch '^[a-fA-F0-9]{64}$') {throw 'Indicar SHA256 validado de fuente confiable'}
 if ((Get-FileHash $ZipPath -Algorithm SHA256).Hash -ine $ApprovedSha256) {throw 'SHA256 distinto; no instalar'}
}
$task=Get-ScheduledTask -TaskName $name -ErrorAction SilentlyContinue
if ($task) {
 $a=@($task.Actions)[0]
 if (($a.Execute.Trim('"') -ine $exe) -or $a.Arguments -ne 'serve') {throw 'La tarea existente tiene otra configuracion'}
}
Write-Host "[PLAN] Engram: $exe; extension gentle-engram@0.4.1; tarea $name"
if (!$Apply) {Write-Host '[PREVIEW] Sin cambios';return}
if (!(Test-Path $exe)) {
 New-Item -ItemType Directory -Force -Path (Split-Path $exe)|Out-Null
 Expand-Archive -LiteralPath $ZipPath -DestinationPath (Split-Path $exe)
}
& $exe version
if ($LASTEXITCODE -ne 0) {throw 'Engram no ejecuta'}
& $shell install npm:gentle-engram@0.4.1
if ($LASTEXITCODE -ne 0) {throw 'Extension no instalada'}
if (!$task) {
 $who=[System.Security.Principal.WindowsIdentity]::GetCurrent().Name
 $a=New-ScheduledTaskAction -Execute $exe -Argument 'serve' -WorkingDirectory (Split-Path $exe)
 $t=New-ScheduledTaskTrigger -AtLogOn -User $who
 $t.Delay='PT30S'
 $p=New-ScheduledTaskPrincipal -UserId $who -LogonType Interactive -RunLevel Limited
 $s=New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Seconds 0) -MultipleInstances IgnoreNew
 Register-ScheduledTask -TaskName $name -Action $a -Trigger $t -Principal $p -Settings $s | Out-Null
}
Write-Host '[OK] Probar Start-ScheduledTask y puerto 7437. Validar proximo inicio de sesion.'
