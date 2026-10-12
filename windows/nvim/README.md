# Ajustes de GentlemanNvim para Windows

Los archivos originales de Mac permanecen intactos en la raiz `nvim/`.

Correcciones comprobadas en el equipo Windows de referencia:
- `nodejs.lua`: sustituir las tres llamadas de version hechas con cadenas por `vim.fn.system({ ejecutable, "--version" })`.
- Separar la ruta de Node de `vim.g.node_host_prog`; usar `vim.g.gentle_node_path` para la deteccion y `M.info()`.
- `lazy.lua`: quitar la asignacion que pone `node.exe` como `node_host_prog`; conservar configuracion de plugins y `rocks = { enabled = false }` cuando LuaRocks no se utiliza.
- `gemini.lua`: establecer `enabled = vim.fn.has("win32") == 0`, sin permitir que Gemini CLI solicite una instalacion al abrir Windows.

Los cambios anteriores se verificaron localmente con `loadfile()`, la prueba aislada de `config.nodejs.setup()` y el arranque headless sin avisos de Node o Gemini.

## Aplicacion segura

Para reconstruir el entorno, obtener una copia autorizada de GentlemanNvim; realizar backup de `%LOCALAPPDATA%\nvim` antes de cambiarla. Adaptar esos tres archivos **localmente**, sin reemplazar los equivalentes macOS en `nvim/`.

La restauracion automatizada y la instalacion de proveedores opcionales de Neovim aun no estan implementadas. No subir al repositorio configuraciones personales ni rutas privadas.
