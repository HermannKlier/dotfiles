#requires -Version 5.1
<#
.SYNOPSIS
  Prepara Engram 3.6.0, la extension de Gentle Shell y una tarea oculta al iniciar sesion.
.DESCRIPTION
  Vista previa por defecto. -Apply requiere aprobacion y cumplimiento de politicas TI.
  No instala Gentle Shell ni modifica Pi independiente. No sobrescribe memorias.
  Si falta el ejecutable, requiere ZIP oficial y huella SHA-256 previamente verificada.
  No altera ni sustituye tareas existentes con configuraciones distintas.
  No elimina accesos directos Startup automaticamente.
.NOTES
  Probado manualmente en PC de referencia; este script aun NO se ha ejecutado
  de extremo a extremo en Windows. Ver ENGRAM_STATUS.md.
#>
[CmdletBinding()]
param(
  [switch]$Apply,
  [string]$ZipPath = (Join-Path $HOME 'Downloads\engram_3.6.0_windows_amd64.zip'),
  [string]$ApprovedSha256 = ''
)

$ErrorActionPreference = 'Stop'
$exe = Join-Path $HOME 'apps\engram\engram.exe'
$dir = Split-Path -Parent $exe
$launcher = Join-Path $dir 'iniciar-oculto.vbs'
$shell = Join-Path $env:LOCALAPPDATA 'gentle-shell\bin\gentle-shell.cmd'
$taskName = 'Engram - Memoria Local'
$package = 'npm:gentle-engram@0.4.2'
$expectedExecute = Join-Path $env:WINDIR 'System32\wscript.exe'
$expectedArgs = '"' + $launcher + '"'

Write-Host "[INFO] Gentle Shell: $shell"
Write-Host "[INFO] Engram: $exe"
Write-Host "[INFO] Memorias locales: $HOME\.engram (no se modifican)"

# Comprobaciones previas, todas de solo lectura.
if (-not (Test-Path -LiteralPath $shell -PathType Leaf)) {
  throw 'Falta Gentle Shell empaquetado. Instalar por un procedimiento autorizado.'
}
$exeExists = Test-Path -LiteralPath $exe -PathType Leaf
if (-not $exeExists) {
  if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) {
    throw "No esta el ZIP oficial de Engram: $ZipPath"
  }
  if ($ApprovedSha256 -notmatch '^[0-9a-fA-F]{64}$') {
    throw 'Indicar -ApprovedSha256 con la huella oficial verificada del ZIP.'
  }
  $actualHash = (Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash
  if ($actualHash -ine $ApprovedSha256) {
    throw 'La huella SHA-256 no coincide; no instalar.'
  }
  if (Test-Path -LiteralPath $dir) {
    throw "La carpeta $dir ya existe sin engram.exe; revisar manualmente."
  }
  Write-Host "[PLAN] Extraer ZIP verificado en $dir"
} else {
  Write-Host '[PRESENT] Engram.exe ya existe; no se sobrescribira.'
}

if (Test-Path -LiteralPath $launcher -PathType Leaf) {
  $actualLauncher = (Get-Content -LiteralPath $launcher -Raw)
  if ($actualLauncher -notlike '*CreateObject("WScript.Shell")*' -or
      $actualLauncher -notlike ('*' + $exe + '* serve*')) {
    throw "Existe lanzador distinto: $launcher. Revisar antes de continuar."
  }
  Write-Host '[PRESENT] Lanzador WScript existente; se conserva.'
} else {
  Write-Host "[PLAN] Crear lanzador oculto $launcher"
}

$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($task) {
  $actions = @($task.Actions)
  if ($actions.Count -ne 1) {
    throw 'La tarea existente tiene multiples acciones; revisar manualmente.'
  }
  $action = $actions[0]
  $actionPath = [Environment]::ExpandEnvironmentVariables($action.Execute)
  $expectedPath = [Environment]::ExpandEnvironmentVariables($expectedExecute)
  if ($actionPath -ine $expectedPath -or $action.Arguments -ne $expectedArgs) {
    throw 'La tarea existe con otra accion. No se reemplazara automaticamente.'
  }
  Write-Host '[PRESENT] Tarea programada con lanzador oculto correcto.'
} else {
  Write-Host '[PLAN] Registrar tarea al iniciar sesion con permisos limitados.'
}

# La lista es una consulta; no equivale a instalar o actualizar paquetes.
$packageList = (& $shell list 2>&1 | Out-String)
if ($LASTEXITCODE -ne 0) {
  throw 'No se pudo consultar la lista de paquetes de Gentle Shell.'
}
if ($packageList -match [regex]::Escape($package)) {
  Write-Host "[PRESENT] $package"
} elseif ($packageList -match 'npm:gentle-engram(?:@[^\s]+)?') {
  throw 'Hay otra version de gentle-engram instalada. Revisar antes de actualizar.'
} else {
  Write-Host "[PLAN] Instalar $package en el Gentle Shell aislado."
}

if (-not $Apply) {
  Write-Host '[PREVIEW] Ningun archivo, paquete ni tarea fue modificado.'
  return
}

if (-not $exeExists) {
  New-Item -ItemType Directory -Path $dir -ErrorAction Stop | Out-Null
  Expand-Archive -LiteralPath $ZipPath -DestinationPath $dir -ErrorAction Stop
  if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
    throw 'El ZIP no contiene engram.exe en la ruta esperada. Revisar extraccion.'
  }
}

# Verificar el ejecutable sin levantar una segunda instancia de servidor.
& $exe version
if ($LASTEXITCODE -ne 0) { throw 'Engram.exe version fallo. Detener instalacion.' }

if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) {
  $line1 = 'Set shell = CreateObject("WScript.Shell")'
  $line2 = 'shell.Run Chr(34) & "' + $exe + '" & Chr(34) & " serve", 0, False'
  @($line1, $line2) | Set-Content -LiteralPath $launcher -Encoding Unicode -ErrorAction Stop
}

if ($packageList -notmatch [regex]::Escape($package)) {
  & $shell install $package
  if ($LASTEXITCODE -ne 0) { throw 'Fallo la instalacion de gentle-engram.' }
}

if (-not $task) {
  $username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  $taskAction = New-ScheduledTaskAction -Execute $expectedExecute -Argument $expectedArgs -WorkingDirectory $dir
  $trigger = New-ScheduledTaskTrigger -AtLogOn -User $username
  $principal = New-ScheduledTaskPrincipal -UserId $username -LogonType Interactive -RunLevel Limited
  $settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew
  Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $trigger -Principal $principal -Settings $settings -ErrorAction Stop | Out-Null
}
Write-Host '[OK] Preparacion completada. Falta validar tarea, puerto 7437 y mem_search en un proyecto Git.'
Write-Host '[NOTA] No se inicia automaticamente ahora ni se borran accesos Startup antiguos.'
