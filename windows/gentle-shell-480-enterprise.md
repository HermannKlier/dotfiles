# Gentle Shell 4.8.0 + Engram en Windows corporativo (estado 2026-11-14)

> **PC de referencia, sin administrador.** Estado observado y validado en una PC existente; no es un instalador universal ni autorización de TI. Este repositorio es **público**: no subir tokens, auth.json, bases SQLite, memorias, sesiones, ficheros de proyectos, logs sensibles ni datos corporativos.

## Estado efectivo

| Pieza | Versión / ubicación relativa a %USERPROFILE% | Verificación |
|---|---|---|
| Gentle Shell (paquete JS `gentle-pi`) | 4.8.0; `apps\GENTLE_SHELL_480\node_modules\gentle-pi` | `gentle-shell --version` |
| Pi integrado | 1.5.2 | `gentle-shell --version` |
| Node.js externo | 24.17.0; `apps\node-v24.17.0-win-x64\node-v24.17.0-win-x64\node.exe` | uso confirmado en lanzador |
| Lanzador principal único | `apps\bin\gentle-shell.cmd` | `Get-Command gentle-shell -All`: una sola entrada |
| Pi home aislado | `apps\GENTLE_SHELL_480\agent-home` | `--version`; `settings.json` y `auth.json` existen (NO publicar) |
| Config Pi | `apps\GENTLE_SHELL_480\config` | variable `GENTLE_PI_CONFIG_HOME` del lanzador |
| Extensión | `npm:gentle-engram@0.4.2` bajo `agent-home\npm\node_modules` | `settings.json`, package.json presentes |
| Engram servidor/binario | 3.6.0; `apps\engram\engram.exe` | puerto `127.0.0.1:7437` accesible |
| Base local Engram | `.engram\engram.db` | persistente; **fuera de Git** |

Después de renombrar la carpeta de `GENTLE_480_TEST` a `GENTLE_SHELL_480`, se confirmó: `gentle-shell 4.8.0`, `pi 1.5.2`, home correcto; `mem_doctor` **10/10** comprobaciones sin advertencias y `mem_search` **9** resultados al buscar un proyecto existente. La prueba posterior al cambio fue **de lectura**: no está revalidada la escritura. `mem_doctor` indicó “Caller binding: ok (later writes not guaranteed)”; no interpretar como garantía de escrituras futuras.

### Lanzador efectivo

El archivo `%USERPROFILE%\apps\bin\gentle-shell.cmd` en la PC validada contiene esta configuración **sin secretos**:

```bat
@echo off
set "GENTLE_SHELL_NO_AUTO_SETUP=1"
set "GENTLE_PI_CONFIG_HOME=%USERPROFILE%\apps\GENTLE_SHELL_480\config"
set "ENGRAM_URL=http://127.0.0.1:7437"
"%USERPROFILE%\apps\node-v24.17.0-win-x64\node-v24.17.0-win-x64\node.exe" "%USERPROFILE%\apps\GENTLE_SHELL_480\node_modules\gentle-pi\bin\gentle-shell.mjs" --home "%USERPROFILE%\apps\GENTLE_SHELL_480\agent-home" %*
```

`apps\bin` figura al principio del PATH **de usuario**. Se validó el orden abriendo una **nueva** ventana de PowerShell. La instalación de Gentle Shell 4.8.0 es una **instalación JS autónoma** (paquete npm), **no** el paquete oficial completo con todos los binarios nativos. No utilizar `gentle-shell upgrade` del bundle antiguo para mantener esta instalación.

### Diagnóstico de solo lectura

```powershell
Get-Command gentle-shell -All | Select-Object Name, Source
gentle-shell --version
$homePi = Join-Path $HOME 'apps\GENTLE_SHELL_480\agent-home'
Test-Path (Join-Path $homePi 'settings.json')
Test-Path (Join-Path $homePi 'auth.json') # verificar existencia; NO mostrar contenido
$config = Get-Content (Join-Path $homePi 'settings.json') -Raw | ConvertFrom-Json
$config | Select-Object packages, extensions
Test-Path (Join-Path $homePi 'npm\node_modules\gentle-engram\package.json')
Test-NetConnection 127.0.0.1 -Port 7437 -WarningAction SilentlyContinue |
  Select-Object TcpTestSucceeded
```

Abrir `gentle-shell` **desde la raíz de un proyecto Git autorizado** y probar `mem_doctor`, luego `mem_search` sin modificar ni borrar memorias. Si el puerto responde pero un proyecto nuevo muestra `memory disabled`, revisar su raíz Git antes de reinstalar (ver `ENGRAM_STATUS.md`). La carpeta `agent-home\extensions` puede no existir; la extensión se instala vía npm y su ausencia no demuestra fallo.

### Historial de migración y limpieza controlada

1. Existía un bundle empaquetado Gentle Shell 4.7.0 en `%LOCALAPPDATA%\gentle-shell`; el intento de actualización oficial terminó en `spawn EPERM`. La desinstalación oficial `self-uninstall --yes` quedó **parcial**, con `EPERM` al retirar `runtime\engram-3.5.2`. Quedaron `bin`, `config`, `npm`, `pnpm`, `runtime`, `tmp` y metadatos. **No se afirma que el bundle se haya eliminado por completo**.
2. Se instaló `gentle-pi@4.8.0` en un directorio de usuario separado mediante `npm.cmd install --prefix <directorio> --ignore-scripts --no-audit --no-fund gentle-pi@4.8.0`, se usó Node.js 24.17.0 externo, `GENTLE_SHELL_NO_AUTO_SETUP=1` y `--home` aislado. Se configuró explícitamente la ruta Git Bash autorizada en Pi, y se instaló `npm:gentle-engram@0.4.2` dentro de ese home.
3. Se fijó `apps\bin` al inicio del PATH de usuario para que `gentle-shell` resolviera siempre al nuevo `.cmd` incluso en sesiones nuevas.
4. Los lanzadores antiguos en `gs` y `apps\nodejs` se identificaron. `npm.cmd uninstall --global --prefix "$HOME\gs" gentle-pi` retiró la instalación **4.1.0** (187 paquetes). `npm.cmd uninstall --global --prefix "$HOME\apps\nodejs" gentle-pi` retiró el residuo npm (2 paquetes); después se eliminaron **solo** los tres lanzadores obsoletos `gentle-shell`, `gentle-shell.cmd` y `gentle-shell.ps1` de `apps\nodejs` tras comprobar que el paquete ya no existía. No se borraron las carpetas compartidas `gs` ni `apps\nodejs`.
5. Se renombró `GENTLE_480_TEST` a `GENTLE_SHELL_480`, se actualizó el lanzador principal y un PS1 auxiliar, y se verificó nuevamente el home, versiones y lectura Engram.

**No repetir automáticamente esos comandos de desinstalación:** son un registro de actuaciones en esta PC, no un paso obligatorio para otra instalación. Inspeccionar siempre rutas, paquetes y versiones previamente.

### Límites por política corporativa

- Intento de Engram **3.7.2**: descarga/hash revisados previamente, pero Windows Defender ASR bloqueó la **ejecución** del nuevo binario (`EPERM`). Regla detectada de prevalencia/antigüedad/confianza de ejecutables (GUID `01443614-CD74-433A-B99E-2ECDC07BFC25`, evento 1121). Mantener Engram **3.6.0**, que funciona; no alterar Defender, reputación ni políticas.
- `gentle-engram@0.8.0` **no se ha validado** contra el servidor actual 3.6.0; mantener **0.4.2**. Un cambio combinado de servidor/extensión requiere revisión de compatibilidad, copia y restauración aprobada de la base y permiso de TI.
- Gentle AI **nativo** (4.x) y la funcionalidad nativa del bundle 4.8.0 **no están validados** y anteriores intentos de ejecutar ejecutables nativos devolvieron `spawn EPERM` / acceso denegado. No anunciar equivalencia con el bundle completo.
- La tarea antigua `Engram - Memoria Local` (WScript oculto al inicio de sesión) había sido validada después de un reinicio anterior; en esta migración se validó el **puerto**, pero no se repitió una prueba de reinicio y arranque automático.
- Los scripts antiguos `windows/setup-engram.ps1` (espera el bundle bajo `%LOCALAPPDATA%`) y `windows/update-gentle-shell.ps1` (npm global) son **heredados** y **no se deben aplicar directamente a esta topología**. Revisar y adaptar antes de ejecutar cualquier `-Apply`.

### Respaldos / recuperación

Se registraron respaldos locales fuera de Git en `apps\ENGRAM_BACKUPS\20261114_093902` y `apps\GENTLE_BACKUPS\20261114_202226`; su existencia y aptitud para restaurar deben verificarse en el momento de usarlos. No incluirlos en el repositorio. Las credenciales `auth.json`, base `engram.db`, sesiones y datos corporativos se conservan **exclusivamente en el equipo o almacenamiento autorizado**.

Ante fallo de `gentle-shell`: comprobar primero `Get-Command gentle-shell -All`, `--version`, existencia de `apps\GENTLE_SHELL_480`, ruta de Node, settings y puerto 7437. No reinstalar ni borrar memorias como primer diagnóstico. No usar `reset --hard`, `force push` ni cambios en `main` por este procedimiento.

**Estado:** migración de launcher, Pi y lectura Engram **VALIDADA EN PC ACTUAL**; escritura post-migración, ejecución nativa, instalación desde cero en otra PC y eliminación total del bundle viejo **PENDIENTES / NO VERIFICADAS**.
