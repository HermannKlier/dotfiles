return {
  "obsidian-nvim/obsidian.nvim",
  opts = {
    legacy_commands = false,

    workspaces = {
      {
        name = "HK",
        path = vim.fn.expand("~/Documents/Obsidian/HK"),
      },
      {
        name = "Proyectos",
        path = vim.fn.expand("~/Documents/Obsidian/Proyectos"),
      },
    },

    notes_subdir = "01. Inbox",
    new_notes_location = "notes_subdir",

    picker = {
      name = "snacks.picker",
    },

    attachments = {
      folder = "05. Files",
    },

    templates = {
      folder = "04. Plantillas",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },
  },
}
