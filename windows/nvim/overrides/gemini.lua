-- Windows does not prompt to install Gemini CLI on Neovim startup.
-- Preserve current behavior on macOS/Linux.
return {
  "jonroosevelt/gemini-cli.nvim",
  enabled = vim.fn.has("win32") == 0,
  config = function()
    require("gemini").setup()
  end,
}
