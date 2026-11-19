# Windows Enterprise: incidencias comprobadas

| Componente | Problema | Tratamiento |
|---|---|---|
| Obsidian.nvim | `os.getenv("HOME")` devolvio `nil` en Windows | Elegir la ruta local del vault en la configuracion, sin publicarla como ruta universal. |
| Lazy.nvim | Advertencias de LuaRocks/hererocks y Python | Se desactivo soporte LuaRocks con `rocks = { enabled = false },`; ningun plugin instalado lo requeria. |
| Treesitter | Compilador C no encontrado | WinLibs GCC aprobado en PATH de usuario; luego `:checkhealth lazyvim` dio OK. |
| fzf-lua | Faltaba ejecutable fzf | fzf portatil; comprobacion posterior correcta. |
| LazyVim | Faltaba LazyGit | LazyGit portatil; comprobacion posterior correcta. |
| PowerShell npm | Advertencia al ejecutar `npm.ps1` | Usar `npm.cmd` sin cambiar politicas de ejecucion. |
| Gentle AI nativo | `spawn EPERM` al verificar binario | Sin resolver; consultar TI y no eludir protecciones. Gentle Shell instalado omitiendo el componente nativo. |
| Snacks.image | Terminal actual no soporta protocolo grafico requerido | Opcional; no instalar herramientas graficas indiscriminadamente. |
| Neovim Node provider | `node_host_prog` configurado con ejecutable node, no host neovim | Pendiente de revisar y corregir con pruebas. |

## Validaciones satisfactorias
`:checkhealth lazy`, `:checkhealth lazyvim`, `:checkhealth fzf_lua` y requisitos de `nvim-treesitter` correctos. Obsidian reconoce el vault local.

## Seguridad
No agregar credenciales de OpenAI/Codex, archivos `auth.json`, secretos, notas personales ni informacion interna de la empresa al repositorio publico.
