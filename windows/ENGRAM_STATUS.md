# Engram Windows

Probado en Windows Enterprise: Gentle Shell 4.5.1 con Pi 1.4.0 empaquetado, Engram 3.6.0 precompilado, gentle-engram 0.4.1. Memorias locales en ~/.engram con separacion logica por repositorio Git. Tarea Engram - Memoria Local: inicio de sesion, retardo 30s, usuario sin elevacion, ejecuta engram.exe serve, escucha 127.0.0.1:7437. Ejecucion manual de tarea verificada; inicio automatico tras nueva sesion aun pendiente. Gentle AI nativo falla con spawn EPERM. No deshabilitar medidas de seguridad. El instalador windows/install.ps1 aun solo cubre GCC, fzf, LazyGit.

Actualización 29-10-2026: se modificó la tarea para ejecutar powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -File iniciar-oculto.ps1. Se comprobó tarea Running, código 267009 y puerto 127.0.0.1:7437 con PID 19980. Pendiente comprobar de nuevo tras reiniciar Windows que no se muestra la consola. No debe cerrarse el proceso Engram para mantener memoria disponible.


Actualización final de prueba en sesión (29-10-2026): se configuró la acción de tarea con wscript.exe y el archivo iniciar-oculto.vbs (`shell.Run ... " serve", 0, False`). Se detuvo el proceso anterior y se inició la tarea sin ventana visible; Engram PID 17700 escuchó en 127.0.0.1:7437 y LastTaskResult fue 0. El estado Ready/resultado 0 del lanzador es normal porque Engram queda como proceso separado. PENDIENTE: verificar inicio oculto tras reiniciar/iniciar sesión, pues no se ha realizado esa prueba con WScript.


## Validación final Gentle Shell posterior al reinicio (2026-10-29)

Desde `C:\Users\hklier\apps\RBI`, Gentle Shell 4.5.1 / Pi 1.4.0 ejecutó correctamente `mem_list_projects`, `mem_search` y `mem_get_observation` sin escribir datos. Se recuperó la observación #1 del proyecto `rbi` (`scope=project`, `type=discovery`, título `Prueba de integración Engram`) con contenido exacto `Engram funciona correctamente con Gentle Shell 4.5.1 y Pi 1.4.0 en Windows`. Engram inició oculto tras reboot, PID 1868 y puerto 127.0.0.1:7437, resultado tarea 0. INTEGRACIÓN Y PERSISTENCIA EN ESTA PC: VALIDADAS. Instalador reproducible en otra PC: NO VALIDADO AÚN.
