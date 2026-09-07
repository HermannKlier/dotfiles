return {
  {
    "nvim-telescope/telescope-bibtex.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      extensions = {
        bibtex = {
          -- Ruta absoluta al archivo generado por Zotero en tu HK
          global_files = { "/Users/hermannklier/Documents/Obsidian/HK/references.bib" },
          -- Formato estándar de cita Pandoc / Zettelkasten: [@citekey]
          format = "pandoc",
          context = true,
          context_fallback = true,
          search_keys = { "author", "year", "title" },
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("bibtex")
    end,
  },
}
