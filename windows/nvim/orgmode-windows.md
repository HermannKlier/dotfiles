# Agenda nvim-orgmode en Windows

El repositorio Mac tiene dos configuraciones para `nvim-orgmode/orgmode`:
`nvim/lua/plugins/orgmode.lua` y `nvim/lua/plugins/user_orgmode.lua`.
La primera usa `~/Documents/HK/**/*` y `Seguimiento_Actividades.org`; la segunda usa `~/Documents/Obsidian/**/*.org` y otro `Seguimiento_Actividades.org`. Se conservaron sus prioridades, estados y colores en una configuracion unificada para Windows.

La ruta de los archivos `.org` es personal, y **no se incluye en GitHub**.
Para preparar la instalacion en Windows, indicar la carpeta real de archivos `.org`:

```powershell
.\windows\install-orgmode.ps1 -OrgRoot 'RUTA_DE_TUS_ARCHIVOS_ORG'
```

De forma predeterminada solo muestra el plan. Una vez revisado, usar `-Apply`. El script exige una carpeta existente, realiza respaldo de los dos archivos de plugin, y genera `lua/config/orgmode_windows.lua` **localmente**; no copia notas ni las sube a GitHub.

Ejemplo de validacion despues de instalar: abrir Neovim y ejecutar `:Org agenda`; verificar tareas programadas de la semana y acceso a `Seguimiento_Actividades.org`.

La instalacion de Neovim y plugins de base corresponde al flujo principal. Este script solo configura el plugin; si Lazy no tiene descargado nvim-orgmode, Neovim necesitara instalarlo mediante el gestor de plugins autorizado. No modificar ni mezclar la configuracion macOS.
