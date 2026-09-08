return {
  {
    "nvim-orgmode/orgmode",
    config = function()
      local agenda_path = vim.fn.expand("~/Documents/Obsidian/**/*.org")
      local default_notes = vim.fn.expand("~/Documents/Obsidian/Seguimiento_Actividades.org")

      require("orgmode").setup({
        org_agenda_files = { agenda_path },
        org_default_notes_file = default_notes,
        org_todo_keywords = {
          "TODO(t)",
          "IN_PROGRESS(i)",
          "|",
          "DONE(d)",
          "CANCELLED(c)",
        },
        org_todo_keyword_faces = {
          TODO = ":foreground #f7768e :weight bold",
          IN_PROGRESS = ":foreground #e0af68 :weight bold",
          DONE = ":foreground #73daca :weight bold",
          CANCELLED = ":foreground #565f89 :weight bold",
        },
      })

      local function apply_agenda_highlights()
        -- 1. Tareas a tiempo: Blanco suave neutro (sin tono azul)
        vim.api.nvim_set_hl(0, "OrgAgendaScheduled", { fg = "#e2e8f0", force = true })
        vim.api.nvim_set_hl(0, "@org.agenda.scheduled", { fg = "#e2e8f0", force = true })

        -- 2. Tareas con retraso (Sched. Xx): Amarillo advertencia
        vim.api.nvim_set_hl(0, "OrgAgendaScheduledPast", { fg = "#e0af68", force = true })
        vim.api.nvim_set_hl(0, "@org.agenda.scheduled_past", { fg = "#e0af68", force = true })

        -- 3. Prioridades independientes de alto contraste
        -- Prioridad A: Rojo
        vim.api.nvim_set_hl(0, "OrgPriorityA", { fg = "#f7768e", bold = true, force = true })
        vim.api.nvim_set_hl(0, "@org.priority.highest", { fg = "#f7768e", bold = true, force = true })

        -- Prioridad B: Verde
        vim.api.nvim_set_hl(0, "OrgPriorityB", { fg = "#9ece6a", bold = true, force = true })
        vim.api.nvim_set_hl(0, "@org.priority.default", { fg = "#9ece6a", bold = true, force = true })

        -- Prioridad C: Gris tenue
        vim.api.nvim_set_hl(0, "OrgPriorityC", { fg = "#565f89", bold = false, force = true })
        vim.api.nvim_set_hl(0, "@org.priority.lowest", { fg = "#565f89", bold = false, force = true })
      end

      -- Aplicar al inicio
      apply_agenda_highlights()

      -- Persistencia ante recarga de buffers o colores
      vim.api.nvim_create_autocmd({ "ColorScheme", "FileType" }, {
        pattern = { "*", "org", "orgagenda" },
        callback = apply_agenda_highlights,
      })
    end,
  },
}
