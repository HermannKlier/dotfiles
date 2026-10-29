# Engram Windows

Probado en Windows Enterprise: Gentle Shell 4.5.1 con Pi 1.4.0 empaquetado, Engram 3.6.0 precompilado, gentle-engram 0.4.1. Memorias locales en ~/.engram con separacion logica por repositorio Git. Tarea Engram - Memoria Local: inicio de sesion, retardo 30s, usuario sin elevacion, ejecuta engram.exe serve, escucha 127.0.0.1:7437. Ejecucion manual de tarea verificada; inicio automatico tras nueva sesion aun pendiente. Gentle AI nativo falla con spawn EPERM. No deshabilitar medidas de seguridad. El instalador windows/install.ps1 aun solo cubre GCC, fzf, LazyGit.

Actualización 29-10-2026: se modificó la tarea para ejecutar powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -File iniciar-oculto.ps1. Se comprobó tarea Running, código 267009 y puerto 127.0.0.1:7437 con PID 19980. Pendiente comprobar de nuevo tras reiniciar Windows que no se muestra la consola. No debe cerrarse el proceso Engram para mantener memoria disponible.
