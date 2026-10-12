# Windows Enterprise: Gentleman Programming

Configuracion reproducible para Windows 11 Enterprise sin privilegios administrativos, sujeta a autorizacion de TI.

**Estado:** etapa inicial de documentacion y verificacion. No hay instalacion automatica. La configuracion de Mac (`nvim/`, `ghostty/`, `herdr/`) queda intacta.

## Proceso previsto
1. Confirmar las herramientas autorizadas por TI.
2. Obtener este repositorio sin incluir informacion sensible.
3. Consultar `versions.json` y validar los paquetes y sus SHA-256.
4. Instalar herramientas aprobadas en ubicaciones de usuario.
5. Adaptar GentlemanNvim para Windows; realizar respaldo antes de reemplazar configuraciones.
6. Ejecutar el diagnostico de solo lectura `windows/verify.ps1`.
7. Dentro de Neovim, ejecutar `:checkhealth lazy`, `:checkhealth lazyvim`, `:checkhealth fzf_lua`, `:checkhealth nvim-treesitter` y `:checkhealth`.

Desde PowerShell, en la raiz de este repositorio:

```powershell
& .\windows\verify.ps1
```

## Alcance y limitaciones
- GentlemanNvim y Gentle Shell funcionan en el equipo de referencia.
- La instalacion nativa de Gentle AI **no esta resuelta**: error `spawn EPERM` al verificar su binario; solicitar revision a TI, sin eludir bloqueos.
- La ruta de Obsidian debe ser elegida por cada usuario y equipo. No copiar ni publicar el contenido de las notas.
- El proveedor Node.js de Neovim y herramientas opcionales de Mason/Snacks quedan pendientes de evaluar.
- Los archivos actuales de Mac **no se migran ni modifican** por este procedimiento.

## Seguridad
Este repositorio es **publico**. No guardar tokens, `auth.json`, contrasenas, `.env`, documentos corporativos ni notas privadas. Las descargas y ejecuciones solo deben realizarse conforme a las politicas corporativas.

Consultar `docs/troubleshooting-windows.md` para los problemas detectados.
