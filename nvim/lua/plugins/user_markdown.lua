return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      checkbox = {
        enabled = true,

        unchecked = {
          icon = "󰄱     ",
          highlight = "RenderMarkdownUnchecked",
        },

        checked = {
          icon = "󰱒     ",
          highlight = "RenderMarkdownChecked",
        },

        custom = {
          todo = {
            raw = "[-]",
            rendered = "󰥔     ",
            highlight = "RenderMarkdownTodo",
          },
        },
      },
    },
  },
}
