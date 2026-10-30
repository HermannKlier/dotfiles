# Windows Enterprise: Gentleman Programming

Guia para recuperar el entorno en Windows 11 Enterprise sin permisos de administrador, **siempre sujeto a las politicas de TI**. No se modifican los archivos existentes de macOS.

## Estado de la automatizacion

- `install.ps1`: primera version, **no probada aun en un equipo Windows nuevo**. Solo contempla **GCC/WinLibs, fzf y LazyGit**.
- `verify.ps1`: verificacion de comandos disponibles; no instala nada.
- `versions.json`: versiones observadas y SHA-256 verificados de esos tres ZIP.
- Git, Node.js, Go, Neovim y Gentle Shell aun **no forman parte del instalador**.

## Prueba segura en un equipo donde las herramientas ya funcionan

Desde PowerShell, tras clonar **esta rama** en una carpeta separada:

```powershell
git clone --branch setup/windows-enterprise --single-branch https://github.com/HermannKlier/dotfiles.git "$env:USERPROFILE\apps\dotfiles-windows"
```

Primero revisar la sintaxis sin ejecutar el instalador:

```powershell
$script = "$env:USERPROFILE\apps\dotfiles-windows\windows\install.ps1"
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($script, [ref]$tokens, [ref]$errors) | Out-Null
$errors | Select-Object Message, Extent
```

Si no hay errores de sintaxis y la politica de ejecucion permite scripts autorizados:

```powershell
& $script
```

**Sin `-Apply` solamente muestra el plan o detecta las herramientas instaladas.** No descarga, no instala y no modifica el PATH. Si una politica impide ejecutar archivos PS1, no la cambies ni intentes eludirla: consulta a TI.

Una vez validado con TI, `-Apply -Component GCC`, `fzf` o `LazyGit` permite instalar **solo** el componente seleccionado, verificando SHA-256. Aun no se recomienda `-Apply` sin la revision de su primer uso en ese equipo.

## Pasos para restaurar GentlemanNvim

1. Confirmar autorizacion de TI y descargar solo fuentes oficiales.
2. Instalar herramientas necesarias en directorios de usuario.
3. Respaldar la configuracion activa de Neovim antes de cualquier reemplazo. El repositorio raiz contiene `nvim/` del Mac; no copiarlo automaticamente encima de Windows.
4. Elegir la ruta local del vault Obsidian; nunca publicar notas ni rutas privadas como configuracion universal.
5. Revisar `docs/troubleshooting-windows.md`.
6. Desde Neovim ejecutar `:checkhealth lazy`, `:checkhealth lazyvim`, `:checkhealth fzf_lua`, `:checkhealth nvim-treesitter` y `:checkhealth`.

## Estado de Gentle AI

Gentle Shell funciona con Pi integrado. Gentle AI **nativo no funciona** en el equipo de referencia (`spawn EPERM` al validar `gentle-ai.exe`); requiere revision de TI. No deshabilitar Defender ni otros controles.

## Actualizar Gentle Shell

`update-gentle-shell.ps1` actualiza `gentle-pi` con el npm de usuario (Node portable), omitiendo `gentle-ai.exe` mediante `GENTLE_PI_SKIP_GENTLE_AI_INSTALL=1`. Sin `-Apply` solo muestra el plan.

```powershell
cd "$env:USERPROFILE\apps\dotfiles-windows"
& .\windows\update-gentle-shell.ps1                          # preview
& .\windows\update-gentle-shell.ps1 -Apply -PersistSkipFlag  # actualizar y guardar la variable de usuario
& .\windows\update-gentle-shell.ps1 -Apply -Repair           # reinstalar si quedo a medias (EPERM)
```

Cerrar antes toda ventana de gentle-shell o pi. `-Version 4.2.0` fija una version concreta. No requiere administrador: el script se detiene si el prefijo de npm esta fuera del perfil de usuario.

## Seguridad

Repositorio **publico**. No agregar credenciales, tokens, `auth.json`, archivos `.env`, datos corporativos ni contenido del vault Obsidian.

## Comprobacion en equipo de referencia (12 octubre 2026)

Se clono la rama `setup/windows-enterprise`, se verifico sintaxis de `install.ps1` con el parser de PowerShell (sin errores) y se ejecuto sin `-Apply`: WinLibs GCC, fzf y LazyGit aparecieron como `[PRESENT]`, sin cambios. Despues, `verify.ps1` informo **11/11 herramientas [OK]** y detecto `%LOCALAPPDATA%\nvim\init.lua`. Herramientas: Git 2.53.0.windows.2, Node.js 24.17.0, npm 11.13.0, Go 1.27.2, Neovim 0.12.4, ripgrep 15.2.0, fd 10.5.0, GCC 16.2.0, fzf 0.74.4, LazyGit 0.65.1 y Gentle Shell 4.1.0.

Este resultado confirma la deteccion de herramientas **ya instaladas**, no la restauracion desde cero ni la instalacion mediante `-Apply`. El siguiente paso es diagnosticar y respaldar GentlemanNvim antes de automatizar copias o reemplazos.


## Nuevo flujo asistido (rama de trabajo, aun sin fusionar)

- `bootstrap.ps1` es el punto de entrada; en su modo normal solo consulta, sin instalar nada.
- `setup-engram.ps1` prepara el Engram precompilado y la extension de Gentle Shell, con una tarea programada de inicio de sesion. Exige ZIP oficial y SHA-256 validado cuando el ejecutable no existe.
- `ENGRAM_STATUS.md` detalla las versiones probadas, fallos encontrados y limitaciones.
- Prueba inicial, desde PowerShell, sin modificar el equipo:

```powershell
& .\windows\bootstrap.ps1 -Component All
```

Para instalacion autorizada, ejecutar por componentes y revisar cada plan. Antes de `-Apply`, verificar procedencia y SHA-256 del ZIP de Engram; confirmar que Gentle Shell empaquetado se encuentra en `%LOCALAPPDATA%\gentle-shell\bin`.

```powershell
& .\windows\bootstrap.ps1 -Component Engram -EngramZip "$HOME\Downloads\engram_3.6.0_windows_amd64.zip" -EngramSha256 "<SHA256_VALIDADO>"
# Solo tras validar el plan y la politica de TI:
& .\windows\bootstrap.ps1 -Component Engram -Apply -EngramZip "$HOME\Downloads\engram_3.6.0_windows_amd64.zip" -EngramSha256 "<SHA256_VALIDADO>"
```

**Pendiente:** probar sintaxis y previsualizacion en Windows, verificar arranque automatico tras reinicio, revisar las vulnerabilidades npm reportadas y completar instaladores con manifiestos aprobados para Git, Node, Go, Neovim y Gentle Shell empaquetado. El metodo antiguo `update-gentle-shell.ps1` corresponde a npm global y **no** es el actualizador de la instalacion empaquetada 4.5.1.


## Reemplazo o avería del equipo corporativo

Este repositorio se conserva como guía de **recuperación del entorno en una futura computadora**, no como compromiso de probar hoy en una segunda PC. La instalación actual se verificó en Windows Enterprise sin privilegios de administrador: Gentle Shell 4.5.1 con Pi 1.4.0, Engram 3.6.0, servidor local en 127.0.0.1:7437, arranque automático oculto mediante tarea programada con WScript y recuperación de la observación #1 desde Gentle Shell después de reiniciar. Véase `ENGRAM_STATUS.md`.

**Al recibir un equipo nuevo:** comprobar primero las políticas de seguridad y disponibilidad de PowerShell, Node, Git, Go, Neovim y los ejecutables precompilados; revisar la versión fijada y los artefactos de descarga; ejecutar los scripts de este repositorio en modo lectura/plan antes de aplicar cambios; restaurar únicamente respaldos autorizados; verificar manualmente el arranque sin consola, el puerto 7437, la integración mem_* y la recuperación de una observación de prueba. Las operaciones dependientes del equipo nuevo **no están validadas**; no desactivar controles empresariales para forzar la instalación.

**Datos no incluidos en GitHub:** las memorias SQLite locales de Engram (bajo `%USERPROFILE%\.engram` de manera predeterminada), los repositorios y archivos de trabajo, las credenciales, las sesiones y cualquier información corporativa. Antes de migrar, obtener respaldos aprobados por TI, determinar una ubicación corporativa autorizada y verificar integridad y restauración con el servidor detenido. No subir bases de memoria, secretos ni archivos de trabajo al repositorio de scripts. Si el equipo se avería sin respaldo previo, estos datos pueden no ser recuperables.

**Estado de cierre:** entorno actual **VALIDADO**; procedimiento de recuperación **DOCUMENTADO, PENDIENTE DE VALIDACIÓN EN EQUIPO FUTURO**. No se requiere una segunda computadora para cerrar esta etapa.


## WezTerm + Herdr (validado en la computadora actual)

Se instaló WezTerm 20240203-110809-5046fc22 (ZIP portátil) en la carpeta de usuario, y Herdr 0.9.5 (ZIP con ConPTY) sin permisos administrativos. El archivo de configuración de Herdr de Gentleman.Dots se aplicó a %APPDATA%/herdr/config.toml y pasó `herdr.exe config check` con resultado `config: ok`.

En %USERPROFILE%/.wezterm.lua se configuró `config.default_prog` con la ruta local de `herdr.exe`, tema OneDark, fuente 12 y atajo Ctrl+V para pegar desde el portapapeles. El usuario confirmó que WezTerm abre Herdr automáticamente y que Ctrl+V pega. No se modificó el perfil PowerShell de OneDrive.

Se verificó Gentle Shell con Pi dentro de Herdr, y mem_search recuperó exitosamente la observación 1 del proyecto RBI desde Engram, solo lectura. Una incidencia de texto desalineado en Herdr se corrigió con Clear-Host, pero se debe observar si vuelve a ocurrir. El procedimiento no se ha probado todavía en otro equipo. Gentle AI nativo permanece pendiente.

**Revisión necesaria antes de reutilizar:** el archivo windows/setup-engram.ps1 muestra secciones duplicadas y posiblemente dañadas. No ejecutar con -Apply sin corregirlo y probar su sintaxis y lógica. La instalación manual probada de Engram no valida automáticamente dicho script.


## Gentle AI 4.2.0 — BLOQUEADO POR SEGURIDAD CORPORATIVA (29/10/2026)

En Windows Enterprise, usuario sin permisos de administrador, Go 1.27.2 (`windows/amd64`), se ejecutó:

```powershell
go install github.com/gentleman-programming/gentle-ai/v4/cmd/gentle-ai@v4.2.0
```

La compilación terminó sin errores y creó `%USERPROFILE%\go\bin\gentle-ai.exe` (27 154 432 bytes). `Get-AuthenticodeSignature` devolvió `NotSigned`. Al ejecutar `& "$HOME\go\bin\gentle-ai.exe" --version`, PowerShell informó `Program 'gentle-ai.exe' failed to run: Access is denied` (`ApplicationFailedException`, `NativeCommandFailed`) y Windows Security pidió credenciales de administrador. El usuario no las tiene. **Estado: BLOCKED_BY_CORPORATE_POLICY (bloqueo observado; la regla exacta no está determinada)**. No se ejecutó `gentle-ai install/setup/sync`; no se modificó la instalación funcional de Gentle Shell, Pi, Engram, Herdr y WezTerm.

Para un equipo futuro, verificar con TI si permite el ejecutable y el procedimiento; **no** desactivar ni eludir controles corporativos. No repetir compilaciones como supuesto remedio: compilar fue posible, ejecutar el resultado no. La distribución precompilada de Engram sí se ejecutó en esta PC, pero ello no implica que otros binarios sean admitidos. Gentle AI independiente no es imprescindible para utilizar el Gentle Shell actualmente funcional.
