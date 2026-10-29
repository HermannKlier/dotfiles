#requires -Version 5.1
<#
.SYNOPSIS
  Prepara Engram precompilado, su extension para Gentle Shell y el inicio automatico.
.DESCRIPTION
  PREVIEW por defecto y sin cambios. -Apply requiere aprobacion local y politicas TI.
  Requiere Gentle Shell empaquetado instalado. No instala Pi independiente.
  Para Engram nuevo se exige SHA-256 validado desde un origen confiable.
#>
[CmdletBinding()]
param(
  [switch]$Apply,
  [string]$ZipPath = (Join-Path $HOME 'Downloads\engram_3.6.0_windows_amd64.zip'),
  [string]$ApprovedSha256 = ''
)
$ErrorActionPreference = 'Stop'
$exe = Join-Path $HOME 'apps\engram\engram.exe'
$shell = Join-Path $env:LOCALAPPDATA 'gentle-shell\bin\gentle-shell.cmd'
$name = 'Engram - Memoria Local'
$launcher = Join-Path (Split-Path $exe) 'iniciar-oculto.ps1'
$expectedArgs = '-NoProfile -NonInteractive -WindowStyle Hidden -File "' + $launcher + '"'
$oldShortcut = Join-Path ([Environment]::GetFolderPath('Startup')) 'Engram Server.lnk'
Write-Host "Gentle Shell: $shell"
Write-Host "Engram: $exe"
Write-Host "Memoria central predeterminada: $HOME\.engram"
$missingShell = -not (Test-Path -LiteralPath $shell -PathType Leaf)
$missingExe = -not (Test-Path -LiteralPath $exe -PathType Leaf)
if ($missingShell) { Write-Warning 'Falta Gentle Shell empaquetado. Instalarlo desde proveedor oficial antes de aplicar.' }
if ($missingExe) {
  Write-Host "[PLAN] Extraer ZIP oficial: $ZipPath"
  if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) { Write-Warning 'No esta el ZIP de Engram.' }
  elseif ($ApprovedSha256 -notmatch '^[0-9a-fA-F]{64}$') { Write-Warning 'Falta SHA256 de fuente confiable; obligatorio al aplicar.' }
  elseif ((Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash -ine $ApprovedSha256) { Write-Warning 'SHA256 no coincide con el aprobado.' }
} else { Write-Host '[PRESENT] Engram executable; no se sobrescribira.' }
$task = Get-ScheduledTask -TaskName $name -ErrorAction SilentlyContinue
if ($task) {
  $taskAction = @($task.Actions)[0]
  if (-not $taskAction -or $taskAction.Execute -notmatch '(?i)(^|\\)powershell\.exe) {
    throw "La tarea $name existe con otra accion. Revisar antes de cambiarla."
  }
  Write-Host '[PRESENT] Tarea de Engram existente; se conserva.'
} else { Write-Host '[PLAN] Crear tarea al iniciar sesion, retraso 30s, usuario limitado.' }
Write-Host '[PLAN] Instalar extension npm:gentle-engram@0.4.1 en Gentle Shell.'
Write-Host '[PLAN] Crear lanzador PowerShell oculto en carpeta de Engram.'
if (Test-Path -LiteralPath $oldShortcut) { Write-Host '[PLAN] Retirar Startup shortcut antiguo despues de validar tarea.' }
if (-not $Apply) { Write-Host '[PREVIEW] Sin cambios.'; return }
if ($missingShell) { throw 'No se puede aplicar: falta Gentle Shell empaquetado.' }
if ($missingExe) {
  if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) { throw 'Falta ZIP oficial de Engram.' }
  if ($ApprovedSha256 -notmatch '^[0-9a-fA-F]{64}$') { throw 'Falta ApprovedSha256 verificado.' }
  if ((Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash -ine $ApprovedSha256) { throw 'SHA256 incorrecto.' }
  $dest = Split-Path $exe
  if (Test-Path -LiteralPath $dest) { throw "Existe carpeta $dest sin Engram. Revisar manualmente, no sobrescribir." }
  New-Item -ItemType Directory -Path $dest -Force | Out-Null
  Expand-Archive -LiteralPath $ZipPath -DestinationPath $dest -ErrorAction Stop
  if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) { throw 'ZIP sin engram.exe esperado; no continuar.' }
}
& $exe version
if ($LASTEXITCODE -ne 0) { throw 'Engram no ejecuto version.' }
& $shell install npm:gentle-engram@0.4.1
if ($LASTEXITCODE -ne 0) { throw 'Instalacion de extension fallo.' }
if (-not (Test-Path -LiteralPath $launcher)) {
  @'
$ErrorActionPreference = "Stop"
& "$HOME\apps\engram\engram.exe" serve
'@ | Set-Content -LiteralPath $launcher -Encoding UTF8
}
if (-not $task) {
  $who = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $expectedArgs -WorkingDirectory (Split-Path $exe)
  $trigger = New-ScheduledTaskTrigger -AtLogOn -User $who
  $trigger.Delay = 'PT30S'
  $principal = New-ScheduledTaskPrincipal -UserId $who -LogonType Interactive -RunLevel Limited
  $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Seconds 0) -MultipleInstances IgnoreNew
  Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger -Principal $principal -Settings $settings -ErrorAction Stop | Out-Null
}
$task = Get-ScheduledTask -TaskName $name -ErrorAction Stop
$taskAction = @($task.Actions)[0]
if ($taskAction.Execute -notmatch '(?i)(^|\\)powershell\.exe { throw 'Tarea no coincidente; no retirar acceso antiguo.' }
if (Test-Path -LiteralPath $oldShortcut) { Remove-Item -LiteralPath $oldShortcut -ErrorAction Stop }
Write-Host '[OK] Configurado. Validar con Start-ScheduledTask, puerto 7437 y nuevo inicio de sesion.'
 -or $taskAction.Arguments -ne $expectedArgs) {
    throw "La tarea $name existe con otra accion. Revisar antes de cambiarla."
  }
  Write-Host '[PRESENT] Tarea de Engram existente; se conserva.'
} else { Write-Host '[PLAN] Crear tarea al iniciar sesion, retraso 30s, usuario limitado.' }
Write-Host '[PLAN] Instalar extension npm:gentle-engram@0.4.1 en Gentle Shell.'
if (Test-Path -LiteralPath $oldShortcut) { Write-Host '[PLAN] Retirar Startup shortcut antiguo despues de validar tarea.' }
if (-not $Apply) { Write-Host '[PREVIEW] Sin cambios.'; return }
if ($missingShell) { throw 'No se puede aplicar: falta Gentle Shell empaquetado.' }
if ($missingExe) {
  if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) { throw 'Falta ZIP oficial de Engram.' }
  if ($ApprovedSha256 -notmatch '^[0-9a-fA-F]{64}$') { throw 'Falta ApprovedSha256 verificado.' }
  if ((Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash -ine $ApprovedSha256) { throw 'SHA256 incorrecto.' }
  $dest = Split-Path $exe
  if (Test-Path -LiteralPath $dest) { throw "Existe carpeta $dest sin Engram. Revisar manualmente, no sobrescribir." }
  New-Item -ItemType Directory -Path $dest -Force | Out-Null
  Expand-Archive -LiteralPath $ZipPath -DestinationPath $dest -ErrorAction Stop
  if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) { throw 'ZIP sin engram.exe esperado; no continuar.' }
}
& $exe version
if ($LASTEXITCODE -ne 0) { throw 'Engram no ejecuto version.' }
& $shell install npm:gentle-engram@0.4.1
if ($LASTEXITCODE -ne 0) { throw 'Instalacion de extension fallo.' }
if (-not $task) {
  $who = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  $action = New-ScheduledTaskAction -Execute $exe -Argument 'serve' -WorkingDirectory (Split-Path $exe)
  $trigger = New-ScheduledTaskTrigger -AtLogOn -User $who
  $trigger.Delay = 'PT30S'
  $principal = New-ScheduledTaskPrincipal -UserId $who -LogonType Interactive -RunLevel Limited
  $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Seconds 0) -MultipleInstances IgnoreNew
  Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger -Principal $principal -Settings $settings -ErrorAction Stop | Out-Null
}
$task = Get-ScheduledTask -TaskName $name -ErrorAction Stop
$taskAction = @($task.Actions)[0]
if ($taskAction.Execute.Trim('"') -ine $exe -or $taskAction.Arguments -ne 'serve') { throw 'Tarea no coincidente; no retirar acceso antiguo.' }
if (Test-Path -LiteralPath $oldShortcut) { Remove-Item -LiteralPath $oldShortcut -ErrorAction Stop }
Write-Host '[OK] Configurado. Validar con Start-ScheduledTask, puerto 7437 y nuevo inicio de sesion.'
 -or $taskAction.Arguments -ne $expectedArgs) { throw 'Tarea no coincidente; no retirar acceso antiguo.' }
if (Test-Path -LiteralPath $oldShortcut) { Remove-Item -LiteralPath $oldShortcut -ErrorAction Stop }
Write-Host '[OK] Configurado. Validar con Start-ScheduledTask, puerto 7437 y nuevo inicio de sesion.'
 -or $taskAction.Arguments -ne $expectedArgs) {
    throw "La tarea $name existe con otra accion. Revisar antes de cambiarla."
  }
  Write-Host '[PRESENT] Tarea de Engram existente; se conserva.'
} else { Write-Host '[PLAN] Crear tarea al iniciar sesion, retraso 30s, usuario limitado.' }
Write-Host '[PLAN] Instalar extension npm:gentle-engram@0.4.1 en Gentle Shell.'
if (Test-Path -LiteralPath $oldShortcut) { Write-Host '[PLAN] Retirar Startup shortcut antiguo despues de validar tarea.' }
if (-not $Apply) { Write-Host '[PREVIEW] Sin cambios.'; return }
if ($missingShell) { throw 'No se puede aplicar: falta Gentle Shell empaquetado.' }
if ($missingExe) {
  if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) { throw 'Falta ZIP oficial de Engram.' }
  if ($ApprovedSha256 -notmatch '^[0-9a-fA-F]{64}$') { throw 'Falta ApprovedSha256 verificado.' }
  if ((Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash -ine $ApprovedSha256) { throw 'SHA256 incorrecto.' }
  $dest = Split-Path $exe
  if (Test-Path -LiteralPath $dest) { throw "Existe carpeta $dest sin Engram. Revisar manualmente, no sobrescribir." }
  New-Item -ItemType Directory -Path $dest -Force | Out-Null
  Expand-Archive -LiteralPath $ZipPath -DestinationPath $dest -ErrorAction Stop
  if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) { throw 'ZIP sin engram.exe esperado; no continuar.' }
}
& $exe version
if ($LASTEXITCODE -ne 0) { throw 'Engram no ejecuto version.' }
& $shell install npm:gentle-engram@0.4.1
if ($LASTEXITCODE -ne 0) { throw 'Instalacion de extension fallo.' }
if (-not $task) {
  $who = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  $action = New-ScheduledTaskAction -Execute $exe -Argument 'serve' -WorkingDirectory (Split-Path $exe)
  $trigger = New-ScheduledTaskTrigger -AtLogOn -User $who
  $trigger.Delay = 'PT30S'
  $principal = New-ScheduledTaskPrincipal -UserId $who -LogonType Interactive -RunLevel Limited
  $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Seconds 0) -MultipleInstances IgnoreNew
  Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger -Principal $principal -Settings $settings -ErrorAction Stop | Out-Null
}
$task = Get-ScheduledTask -TaskName $name -ErrorAction Stop
$taskAction = @($task.Actions)[0]
if ($taskAction.Execute.Trim('"') -ine $exe -or $taskAction.Arguments -ne 'serve') { throw 'Tarea no coincidente; no retirar acceso antiguo.' }
if (Test-Path -LiteralPath $oldShortcut) { Remove-Item -LiteralPath $oldShortcut -ErrorAction Stop }
Write-Host '[OK] Configurado. Validar con Start-ScheduledTask, puerto 7437 y nuevo inicio de sesion.'
