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

## Seguridad

Repositorio **publico**. No agregar credenciales, tokens, `auth.json`, archivos `.env`, datos corporativos ni contenido del vault Obsidian.
