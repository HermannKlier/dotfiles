return {
  "nvim-orgmode/orgmode",
  event = "VeryLazy",
  ft = { "org", "orgagenda" },
  config = function()
    require("orgmode").setup({
      -- Ajusta esta ruta a tu carpeta principal de notas de Obsidian
      org_agenda_files = "~/Documents/HK/**/*",
      org_default_notes_file = "~/Documents/HK/Seguimiento_Actividades.org",

      -- Palabras clave para los estados de tareas
      org_todo_keywords = { "TODO(t)", "IN_PROGRESS(i)", "|", "DONE(d)" },

      -- Configuración de la Agenda
      org_agenda_span = "week",
      org_agenda_start_on_weekday = 1, -- Lunes

      -- Sangría visual automática para proyectos y tareas
      org_indent_mode = "indent",
    })

    -- FORZAR COLORES DE PRIORIDADES EN NEOVIM
    vim.api.nvim_set_hl(0, "OrgPriorityA", { fg = "#ff5555", bold = true }) -- Rojo [#A]
    vim.api.nvim_set_hl(0, "OrgPriorityB", { fg = "#50fa7b", bold = true }) -- VERDE [#B]
    vim.api.nvim_set_hl(0, "OrgPriorityC", { fg = "#8be9fd", bold = true }) -- Azul [#C]

    -- Compatibilidad con Treesitter (si lo usas)
    vim.api.nvim_set_hl(0, "@org.priority.highest", { fg = "#ff5555", bold = true })
    vim.api.nvim_set_hl(0, "@org.priority.default", { fg = "#50fa7b", bold = true })
    vim.api.nvim_set_hl(0, "@org.priority.lowest", { fg = "#8be9fd", bold = true })
  end,
}
