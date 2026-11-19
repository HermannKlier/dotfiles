# Migración Gentle Shell 4.8.0 → 4.9.0 en Windows Enterprise

Estado documentado: **2026-11-19**, Windows corporativo sin permisos de administrador. Ejecutar solo paquetes autorizados; no cambiar políticas de Defender ni introducir ejecutables nativos bloqueados. Este repositorio es **público**: jamás incorporar `auth.json`, `.engram`, sesiones, credenciales, ni datos de proyectos.

## Resultado confirmado en la PC de referencia

- Gentle Shell 4.8.0 y Pi 1.5.2 estaban operativos con home aislado `%USERPROFILE%\apps\GENTLE_SHELL_480\agent-home` y el único lanzador `apps\bin\gentle-shell.cmd`.
- `gentle-pi@4.9.0` disponible en npm; instalación de **187 paquetes** bajo `apps\GENTLE_SHELL_490_TEST`, mediante `npm.cmd install --prefix ... --ignore-scripts --no-audit --no-fund`.
- Arranque comprobado con Node.js **24.17.0**, `GENTLE_SHELL_NO_AUTO_SETUP=1`, `GENTLE_PI_CONFIG_HOME` y `--home` apuntando solo al TEST. Resultado: `gentle-shell 4.9.0 / pi 1.5.2`. El lanzador principal seguía siendo 4.8.0 durante la prueba.
- Se copió `settings.json` al home de pruebas, se instaló físicamente `gentle-engram@0.4.2` con `npm --prefix <home>\npm --ignore-scripts` (**124 paquetes**), y se completó OAuth de OpenAI Codex **en home independiente**, sin compartir claves ni publicar tokens.
- Integración: Engram servidor **3.6.0** en `127.0.0.1:7437` (mismo servidor, sin actualizar ni modificar el ejecutable). `mem_doctor` en RBI **10/10**, vinculación automática de proyecto `ok`; `mem_search` devolvió resultados; `mem_save` creó observación **#169** de prueba y `mem_search` verificó la recuperación. Agente `gentle-ai-explore` completó exploración de directorios en modo lectura sin errores.
- Herdr/WezTerm con 4.9.0: interfaz gráfica de terminal visible y proyecto RID reconocido como `rid · ready`. El inicio desde una línea dividida accidentalmente abrió el REPL de Node; se resolvió usando **una sola línea completa**, sin reinstalación.
- **Cambio local de lanzador realizado y verificado:** se renombró `GENTLE_SHELL_490_TEST` a `GENTLE_SHELL_490`, se reemplazaron las referencias a `GENTLE_SHELL_480` en `apps\bin\gentle-shell.cmd` y se ejecutó `gentle-shell --version`: **4.9.0 / Pi 1.5.2 / home correcto**.
- Se mantiene la carpeta de **4.8.0** para reversión. Existía ya un archivo `apps\bin\gentle-shell-480-backup.cmd` antes de ejecutar el bloque de promoción; se debe inspeccionar su contenido en vez de asumir que es una copia histórica intacta. La ejecución posterior de `Copy-Item` terminó sin error.
- **Pendiente**: comprobar la versión desde una nueva ventana PowerShell, una consulta de memorias y autentificación tras el cambio a ruta definitiva; probar el instalador `-Apply` sobre una PC limpia. Nada de esto debe declararse validado.

## Comando de ejecución de la versión definitiva

```powershell
gentle-shell --version
gentle-shell
```

En la PC validada el lanzador `apps\bin\gentle-shell.cmd` contiene las variables `GENTLE_SHELL_NO_AUTO_SETUP=1`, `GENTLE_PI_CONFIG_HOME=%USERPROFILE%\apps\GENTLE_SHELL_490\config` y `ENGRAM_URL=http://127.0.0.1:7437`, y llama al Node.js 24.17.0 del perfil de usuario con:

```text
"%USERPROFILE%\apps\GENTLE_SHELL_490\node_modules\gentle-pi\bin\gentle-shell.mjs" --home "%USERPROFILE%\apps\GENTLE_SHELL_490\agent-home"
```

El home y la autenticación de 4.8.0 se conservan aparte. Solo hay **un lanzador principal** en PATH; no se borran ni alteran sesiones de Engram.

## Instalación desde cero y modo vista previa

`windows/bootstrap.ps1` ofrece diagnóstico de todas las herramientas en modo solo lectura; `windows/setup-gentle-shell-490.ps1` ofrece instalación JS independiente **con `-Apply` explícito**, que requiere Node/npm previamente permitidos. `windows/setup-engram.ps1` conserva Engram 3.6.0 y prepara `gentle-engram 0.4.2` para el nuevo home. No son un instalador completo y probado de Git, Node, Go, Neovim, WezTerm ni Herdr; esas herramientas conservan procedimientos separados.

```powershell
# Desde el checkout autorizado de esta rama:
& .\windows\bootstrap.ps1 -Component All
& .\windows\bootstrap.ps1 -Component GentleShell
& .\windows\bootstrap.ps1 -Component Engram
```

**No ejecutar `-Apply` sin revisión de código, prueba sintáctica y autorización de TI**. Los scripts nuevos no deben reemplazar un lanzador diferente ni borrar datos; en una migración 4.8 → 4.9, se usa el procedimiento específico respaldado, no el instalador de PC nueva. La compatibilidad de la extensión se verifica con `mem_doctor`, `mem_search` y un `mem_save` explícito de prueba en proyecto autorizado.

## Procedimiento manual de recuperación 4.8.0 (sin borrar 4.9.0)

1. Cerrar las sesiones Gentle Shell antes de cambiar rutas.
2. Confirmar la presencia de `apps\GENTLE_SHELL_480\node_modules\gentle-pi\bin\gentle-shell.mjs`, `apps\GENTLE_SHELL_480\agent-home\settings.json` y su autenticación local.
3. Revisar `Get-Content "$HOME\apps\bin\gentle-shell-480-backup.cmd"` y comprobar que el archivo llama a 4.8.0. **No darlo por válido únicamente por el nombre**. Alternativamente respaldar el lanzador actual y editar solo la cadena `GENTLE_SHELL_490` → `GENTLE_SHELL_480` en `apps\bin\gentle-shell.cmd`, sin reemplazar carpetas ni configuración.
4. Abrir una nueva ventana PowerShell; ejecutar `Get-Command gentle-shell -All`, `gentle-shell --version` y prueba de lectura Engram desde un proyecto Git autorizado.
5. Si las verificaciones fallan, detenerse y revisar los logs y rutas. No borrar la base de Engram ni introducir cambios de Defender.

## Restricciones y alcance

- Gentle Shell 4.9.0 oficial trae como pin **Gentle AI 4.6.0**; esto **no prueba la ejecución del binario nativo** en este PC. Versiones anteriores fueron bloqueadas por política corporativa.
- Engram 3.7.2 también fue bloqueado por Windows Defender ASR; el servidor comprobado sigue siendo 3.6.0 y la extensión 0.4.2. No intentar eludir esos controles.
- El conjunto de pruebas en el home TEST confirma funcionamiento JS, OAuth, memoria y exploración; **no** demuestra que toda función Desktop/Tower o el motor nativo esté operativa.
- Evitar copiar memorias o sesiones empresariales al repositorio GitHub. Usar respaldos locales aprobados y probar recuperación con permiso de TI.

Véase también [estado Engram](ENGRAM_STATUS.md) y el [registro histórico 4.8.0](gentle-shell-480-enterprise.md).
