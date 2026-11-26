local alpha = require("alpha")
local art = require("dashboard.evangelion")
local api = vim.api

local function highlights()
  api.nvim_set_hl(0, "EvaNormal", { fg = "#D8CBE8", bg = "#21132E" })
  api.nvim_set_hl(0, "EvaEndOfBuffer", { fg = "#21132E", bg = "#21132E" })
  api.nvim_set_hl(0, "EvaPurple", { fg = "#9564BF" })
  api.nvim_set_hl(0, "EvaGreen", { fg = "#91E65A" })
  api.nvim_set_hl(0, "EvaShortcut", { fg = "#91E65A", bold = true })
  api.nvim_set_hl(0, "EvaFooter", { fg = "#D8CBE8", italic = true })
end

local function git_status()
  if vim.fn.systemlist({ "git", "rev-parse", "--is-inside-work-tree" })[1] == "true" then
    require("telescope.builtin").git_status({ cwd = vim.fn.getcwd() })
  else
    vim.notify("Abra o dashboard em um repositório Git para ver as alterações.")
  end
end

local function button(key, label, action)
  return {
    type = "button",
    val = label,
    on_press = action,
    opts = {
      position = "center",
      shortcut = key,
      align_shortcut = "right",
      hl_shortcut = "EvaShortcut",
      keymap = { "n", key, action, { silent = true, nowait = true, desc = label } },
    },
  }
end

local buttons = {
  button("n", "  New file", vim.cmd.enew),
  button("r", "  Recent files", function() vim.cmd.Telescope("oldfiles") end),
  button("f", "  Find file", function() vim.cmd.Telescope("find_files") end),
  button("g", "  Find text", function() vim.cmd.Telescope("live_grep") end),
  button("h", "  Git status", git_status),
  button("c", "  Configuration", function()
    vim.cmd.edit({ args = { vim.fs.joinpath(vim.fn.stdpath("config"), "init.lua") } })
  end),
  button("l", "󰒲  Lazy", vim.cmd.Lazy),
  button("m", "󰏖  Mason", vim.cmd.Mason),
  button("q", "  Quit", vim.cmd.qall),
}

local function centered(value, hl)
  return { type = "text", val = value, opts = { position = "center", hl = hl } }
end

local function logo(lines)
  local hl = {}
  local width = 0
  for i, line in ipairs(lines) do
    hl[i] = { { i % 2 == 1 and "EvaPurple" or "EvaGreen", 0, #line } }
    width = math.max(width, #line)
  end
  return { element = centered(lines, hl), width = width, height = #lines }
end

local logos = { logo(art.full), logo(art.compact) }
local wordmark = centered("EVANGELION", { { "EvaGreen", 0, 3 }, { "EvaPurple", 3, 10 } })
local slogan = "✟ C H R I S T   I S   K I N G ✟"

local function footer(width)
  local stats = require("lazy").stats()
  local time = stats.startuptime > 0 and ("%.1f ms"):format(stats.startuptime) or "…"
  local plugins = ("%d/%d plugins"):format(stats.loaded, stats.count)
  local line = plugins .. "  ·  " .. time
  return vim.fn.strdisplaywidth(line) <= width and { line } or { plugins, time }
end

local function layout()
  -- Um picker flutuante pode ter o foco durante o redesenho do Alpha.
  local win = api.nvim_get_current_win()
  if vim.bo.filetype ~= "alpha" then
    for _, other in ipairs(api.nvim_tabpage_list_wins(0)) do
      if vim.bo[api.nvim_win_get_buf(other)].filetype == "alpha" then
        win = other
        break
      end
    end
  end
  local width, height = api.nvim_win_get_width(win), api.nvim_win_get_height(win)
  local status = footer(width)
  local header = { element = wordmark, height = 1 }
  for _, candidate in ipairs(logos) do
    if width >= candidate.width and height >= candidate.height + #buttons + #status + 2 then
      header = candidate
      break
    end
  end

  local rows = {}
  local free = math.max(0, height - header.height - #buttons - #status)
  if width >= #slogan and free >= 3 then
    table.insert(rows, centered(slogan, "EvaPurple"))
    free = free - 1
  end
  table.insert(rows, header.element)

  local spacing = free >= #buttons + 3 and 1 or 0
  free = free - spacing * #buttons
  for _, item in ipairs(buttons) do
    item.opts.width = math.min(50, math.max(22, math.floor(width * 0.42)))
  end
  table.insert(rows, { type = "padding", val = math.min(4, math.ceil(free / 2)) })
  table.insert(rows, { type = "group", val = buttons, opts = { spacing = spacing } })
  -- O Alpha já insere uma linha após o último botão quando spacing vale 1.
  table.insert(rows, { type = "padding", val = free >= 2 and 1 - spacing or 0 })
  for _, line in ipairs(status) do
    table.insert(rows, centered(line, "EvaFooter"))
  end
  return rows
end

local M = {}

function M.setup()
  local group = api.nvim_create_augroup("EvangelionDashboard", { clear = true })
  highlights()
  api.nvim_create_autocmd("ColorScheme", { group = group, callback = highlights })
  api.nvim_create_autocmd("User", {
    group = group,
    pattern = "LazyVimStarted",
    once = true,
    callback = function()
      alpha.redraw()
      api.nvim_create_autocmd("User", {
        group = group,
        pattern = "LazyLoad",
        callback = function() alpha.redraw() end,
      })
    end,
  })
  alpha.setup({
    layout = { { type = "group", val = layout, opts = { position = "v_center" } } },
    opts = {
      setup = function()
        -- Conserva também o atalho de novo arquivo do dashboard original.
        vim.keymap.set("n", "e", vim.cmd.enew, { buffer = true, silent = true, nowait = true, desc = "New file" })
        vim.opt_local.winhighlight:append({
          Normal = "EvaNormal", NormalNC = "EvaNormal", EndOfBuffer = "EvaEndOfBuffer",
        })
      end,
    },
  })
end

return M
