# Engram en Windows — estado comprobado

## Estado actual (2026-11-02)

- Windows corporativo sin permisos de administrador. Gentle Shell 4.5.1 / Pi 1.4.0; Engram 3.6.0 precompilado; extension gentle-engram 0.4.2.
- Servidor local `127.0.0.1:7437` en segundo plano. Inicio de sesion mediante tarea `Engram - Memoria Local` que ejecuta `wscript.exe` con `iniciar-oculto.vbs` **sin mostrar consola**. Tras reiniciar Windows, el proceso se verifico activo y la tarea retorno 0. En este diseño, tarea `Ready` y resultado 0 son esperados porque el proceso servidor es independiente.
- Persistencia comprobada mediante `mem_list_projects`, `mem_search` y `mem_get_observation` desde un repositorio Git. Los datos locales permanecen fuera de GitHub.
- El script `setup-engram.ps1` paso analisis sintactico PowerShell y preview en la PC existente, pero **no** se ha probado la instalacion desde cero con `-Apply` en otra PC.
- Gentle AI nativo no se ejecuta por controles corporativos; este problema es independiente de Engram.

## Antecedentes (soluciones descartadas)

Inicialmente se uso Engram 0.4.1 y una tarea que ejecutaba `engram.exe serve` directamente: el servidor funcionaba, pero abria una consola visible. El intento posterior de PowerShell con `-WindowStyle Hidden` tambien mostro la ventana tras el reinicio. Se sustituyo por `wscript.exe` y un lanzador VBS sin ventana, que **si fue comprobado tras reinicio**. Estas alternativas antiguas no deben repetirse al restaurar el entorno.

## Validación final Gentle Shell posterior al reinicio (2026-10-29)

Desde `$HOME\apps\RBI`, Gentle Shell 4.5.1 / Pi 1.4.0 ejecutó correctamente `mem_list_projects`, `mem_search` y `mem_get_observation` sin escribir datos. Se recuperó la observación #1 del proyecto `rbi` (`scope=project`, `type=discovery`, título `Prueba de integración Engram`) con contenido exacto `Engram funciona correctamente con Gentle Shell 4.5.1 y Pi 1.4.0 en Windows`. Engram inició oculto tras reboot, PID 1868 y puerto 127.0.0.1:7437, resultado tarea 0. INTEGRACIÓN Y PERSISTENCIA EN ESTA PC: VALIDADAS. Instalador reproducible en otra PC: NO VALIDADO AÚN.


## Proyecto nuevo RID: `memory disabled` con servidor operativo (2026-11-02)

**Síntoma:** después de reiniciar Windows, el proyecto existente `RBI` mostraba `rbi · ready` en Gentle Shell, mientras la carpeta nueva `$HOME\apps\RID` mostraba `memory disabled`.

**Diagnóstico comprobado:**

- `engram.exe` estaba ejecutándose, escuchando en `127.0.0.1:7437`; tarea programada `Engram - Memoria Local` con `wscript.exe` devolvió `LastTaskResult = 0`.
- `GET http://127.0.0.1:7437/compatibility` devolvió HTTP 200, `status: ready`, `active_reuse_authorized: true` y `capability: startup-verified-store-v1`.
- Gentle Shell 4.5.1 / Pi 1.4.0 tenía instalado `npm:gentle-engram@0.4.2`; en su `package.json` figuraba `engram.startupPolicy: 1`.
- `git rev-parse --show-toplevel` falló inicialmente en RID porque no existía `.git`; la carpeta solo contenía `.atl`.

**Solución efectivamente verificada en RID:**

```powershell
cd "$HOME\apps\RID"
git init -b main
git rev-parse --show-toplevel
# Cerrar la sesión anterior de Gentle Shell solo si no ejecuta tareas.
gentle-shell
```

Tras inicializar el repositorio Git local y reiniciar Gentle Shell desde RID, el usuario confirmó que **Integrations mostró `rid · ready`**. No se reinstaló Engram ni se cambió su tarea de inicio. `git init` fue local: **no publica en GitHub ni genera un respaldo remoto**.

**Regla operativa de recuperación:** si un proyecto nuevo indica `memory disabled` pero otros proyectos funcionan, verificar primero la raíz de proyecto y `git rev-parse --show-toplevel` antes de tocar la instalación global. Para proyectos que realmente usarán Git, inicializar un repositorio local si aún no existe, y reiniciar Gentle Shell desde esa raíz.

**Alcance de la conclusión:** esto demuestra la solución observada para RID en esta PC, no que Git sea requisito universal de Engram o que todos los mensajes `memory disabled` tengan la misma causa. En otros casos verificar igualmente el proceso, puerto, compatibilidad, registro de extensión y logs.
