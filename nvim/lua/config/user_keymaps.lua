-- ============================================================
-- ATAJOS PERSONALES (DESACOPLADOS DE GENTLEMAN DOTS)
-- ============================================================

-- Workspaces de Obsidian
vim.keymap.set("n", "<leader>owp", "<cmd>Obsidian workspace Proyectos<CR>", { desc = "Ir a baúl Proyectos" })
vim.keymap.set("n", "<leader>owh", "<cmd>Obsidian workspace HK<CR>", { desc = "Ir a baúl HK" })

-- Zotero / Citas bibliográficas
vim.keymap.set("n", "<leader>cb", "<cmd>Telescope bibtex<CR>", { desc = "Zotero: Buscar Cita (BibTeX)" })
vim.keymap.set("n", "<leader>cz", "<cmd>Telescope bibtex<CR>", { desc = "Zotero: Insertar Cita [@citekey]" })

-- Abrir nota actual en Obsidian nativo
vim.keymap.set("n", "<leader>ob", function()
  local relative_path = vim.fn.expand("%:t")
  local uri = "obsidian://open?file=" .. relative_path
  vim.fn.jobstart({ "open", uri })
end, { desc = "Obsidian: Abrir nota actual" })

-- Orgmode: Modificar porcentaje de avance
vim.keymap.set("n", "<leader>ta", function()
  local new_avance = vim.fn.input("Nuevo avance (%): ")
  if new_avance ~= "" then
    local line = vim.api.nvim_get_current_line()
    local updated = line:gsub("(%%s*)%d+(%%)", "%1" .. new_avance .. "%2")
    vim.api.nvim_set_current_line(updated)
  end
end, { desc = "Tarea: Modificar Avance (%)" })

-- Orgmode: Insertar plantilla de Proyecto
vim.keymap.set("n", "<leader>np", function()
  local fecha_hoy = os.date("<%Y-%m-%d %a>")
  local lines = {
    "** Nombre del Proyecto / Actividad",
    "*** TODO [#A] Primera tarea del proyecto",
    "    SCHEDULED: " .. fecha_hoy,
    "    COMENTARIOS",
    "    - ",
  }
  vim.api.nvim_put(lines, "l", true, true)
end, { desc = "Org: Insertar nuevo proyecto" })

-- Orgmode: Insertar plantilla de Tarea suelta
vim.keymap.set("n", "<leader>nt", function()
  local fecha_hoy = os.date("<%Y-%m-%d %a>")
  local lines = {
    "*** TODO [#B] Descripción de la tarea",
    "    SCHEDULED: " .. fecha_hoy,
    "    COMENTARIOS",
    "    - ",
  }
  vim.api.nvim_put(lines, "l", true, true)
end, { desc = "Org: Insertar nueva tarea" })

-- Previsualizar imagen bajo el cursor con Quick Look en macOS (<leader>oi)
vim.keymap.set("n", "<leader>oi", function()
  local line = vim.api.nvim_get_current_line()
  local file = line:match("%%[%%[([^%]]+)%]%]")
  if not file then
    file = line:match("%%!%[[.-%]%%]%((.-)%)")
  end
  if not file then
    file = vim.fn.expand("<cfile>")
  end
  file = vim.trim(file)

  if file and file ~= "" then
    local found = vim.fn.glob(file)
    if found == "" then
      local search = vim.fn.glob("**/" .. file)
      if search ~= "" then
        found = vim.split(search, "\n")[1]
      else
        found = file
      end
    end
    vim.fn.jobstart({ "qlmanage", "-p", found }, { detach = true })
  else
    vim.notify("No se detectó ninguna imagen o archivo bajo el cursor", vim.log.levels.WARN)
  end
end, { desc = "Obsidian: Previsualizar imagen bajo el cursor (Quick Look)" })
