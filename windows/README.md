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
