return {
  {
    "nvim-orgmode/orgmode",
    config = function()
      -- Patrón único recursivo directo. Orgmode expande internamente el tilde '~'.
      -- Al usar únicamente este patrón, no hay solapamiento ni duplicación.
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
          DONE = ":foreground #9ece6a :weight bold",
          CANCELLED = ":foreground #565f89 :weight bold",
        },
      })
    end,
  },
}
