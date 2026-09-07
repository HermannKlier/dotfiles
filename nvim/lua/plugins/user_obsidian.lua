return {
  "obsidian-nvim/obsidian.nvim",
  opts = {
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
    new_notes_location = "01. Inbox",
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
