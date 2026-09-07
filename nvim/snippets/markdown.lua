local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("markdown", {
  -- Escribe 'tsk' + Tab para desplegar la tarea completa
  s("tsk", {
    t("- [ ] "),
    i(1, "Descripción de la tarea"),
    t(" [avance:: "),
    i(2, "0"),
    t("] [peso:: "),
    i(3, "1"),
    t("] [plan:: "),
    i(4, os.date("%Y-%m-%d")),
    t("] [comentario:: "),
    i(5, "Inicio de actividad"),
    t("]"),
  }),

  -- Escribe 'tskc' + Tab para insertar tarea ya completada al 100%
  s("tskc", {
    t("- [x] "),
    i(1, "Descripción de la tarea"),
    t(" [avance:: 100] [peso:: "),
    i(2, "1"),
    t("] [plan:: "),
    i(3, os.date("%Y-%m-%d")),
    t("] [comentario:: "),
    i(4, "Completado"),
    t("] ✅ "),
    t(os.date("%Y-%m-%d")),
  }),
})
