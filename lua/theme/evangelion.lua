local M = {}

local p = {
  background = "#21132E",
  panel = "#432D59",
  purple = "#9564BF",
  green = "#91E65A",
  text = "#D8CBE8",
  selection = "#352044",
}

function M.on_highlights(hl)
  -- O texto sem um grupo próprio também herda Normal.fg.
  hl.Normal.bg = p.background
  hl.NormalNC.bg = p.background
  hl.EndOfBuffer = { fg = p.background }
  hl.SignColumn.bg = p.background
  hl.FoldColumn.bg = p.background
  hl.LineNr = { fg = p.purple }
  hl.LineNrAbove = "LineNr"
  hl.LineNrBelow = "LineNr"
  hl.CursorLineNr = { fg = p.green, bold = true }
  hl.CursorLine = { bg = p.selection }
  hl.CursorColumn = "CursorLine"
  hl.Visual = { bg = p.selection }
  hl.VisualNOS = "Visual"

  hl.NormalFloat = { fg = p.text, bg = p.panel }
  hl.FloatBorder = { fg = p.purple, bg = p.panel }
  hl.FloatTitle = { fg = p.green, bg = p.panel, bold = true }
  hl.FloatFooter = "FloatBorder"
  hl.LspInfoBorder = "FloatBorder"
  hl.WinSeparator = { fg = p.purple }
  hl.VertSplit = "WinSeparator"
  hl.StatusLine = { fg = p.text, bg = p.panel }
  hl.StatusLineNC = { fg = p.purple, bg = p.background }
  hl.TabLine = "StatusLine"
  hl.TabLineFill = { bg = p.background }
  hl.TabLineSel = { fg = p.green, bg = p.selection, bold = true }

  hl.Pmenu = "NormalFloat"
  hl.PmenuSel = { fg = p.text, bg = p.selection, bold = true }
  hl.PmenuMatch = { fg = p.green, bg = p.panel }
  hl.PmenuMatchSel = { fg = p.green, bg = p.selection, bold = true }
  hl.PmenuSbar = { bg = p.background }
  hl.PmenuThumb = { bg = p.purple }
  hl.WildMenu = "PmenuSel"
  hl.CmpDocumentation = "NormalFloat"
  hl.CmpDocumentationBorder = "FloatBorder"
  hl.CmpItemAbbr = { fg = p.text }
  hl.CmpItemMenu = { fg = p.text, italic = true }
  hl.CmpItemAbbrMatch = { fg = p.green, bold = true }
  hl.CmpItemAbbrMatchFuzzy = "CmpItemAbbrMatch"

  hl.NvimTreeNormal = "NormalFloat"
  hl.NvimTreeNormalNC = "NvimTreeNormal"
  hl.NvimTreeEndOfBuffer = { fg = p.panel }
  hl.NvimTreeWinSeparator = "FloatBorder"
  hl.NvimTreeFolderName = { fg = p.text }
  hl.NvimTreeEmptyFolderName = "NvimTreeFolderName"
  hl.NvimTreeOpenedFolderName = { fg = p.green }
  hl.NvimTreeFolderIcon = { fg = p.purple }
  hl.NvimTreeIndentMarker = { fg = p.purple }
  hl.NvimTreeRootFolder = { fg = p.green, bold = true }
  hl.NvimTreeOpenedFile = "CursorLine"

  hl.TelescopeNormal = { fg = p.text, bg = p.background }
  hl.TelescopePreviewNormal = "Normal"
  hl.TelescopeBorder = { fg = p.purple, bg = p.background }
  hl.TelescopePromptNormal = "NormalFloat"
  hl.TelescopePromptBorder = "FloatBorder"
  hl.TelescopeTitle = { fg = p.green, bold = true }
  hl.TelescopePromptTitle = "FloatTitle"
  hl.TelescopePromptPrefix = { fg = p.green }
  hl.TelescopeMatching = { fg = p.green, bold = true }
  hl.TelescopeSelection = "PmenuSel"
  hl.TelescopeSelectionCaret = { fg = p.green, bg = p.selection }

  -- O Tokyo Night já define esse indicador antes de o Bufferline carregar.
  hl.BufferLineIndicatorSelected = { fg = p.green, bg = p.selection }
end

function M.bufferline()
  -- O Bufferline usa estas cores também para gerar o fundo dos ícones de arquivo.
  local groups = {
    fill = { bg = p.background },
    background = { fg = p.text, bg = p.background },
    tab = { fg = p.text, bg = p.background },
    tab_selected = { fg = p.green, bg = p.selection },
    tab_close = { fg = p.purple, bg = p.background },
    indicator_visible = { fg = p.panel, bg = p.panel },
  }
  for suffix, bg in pairs({ [""] = p.background, _visible = p.panel, _selected = p.selection }) do
    groups["buffer" .. suffix] = { fg = p.text, bg = bg }
    groups["numbers" .. suffix] = { fg = p.text, bg = bg }
    groups["close_button" .. suffix] = { fg = p.purple, bg = bg }
    groups["duplicate" .. suffix] = { fg = p.purple, bg = bg }
    groups["separator" .. suffix] = { fg = p.purple, bg = bg }
    groups["modified" .. suffix] = { fg = p.green, bg = bg }
  end
  return groups
end

function M.lualine()
  local function section(fg, bg)
    return { fg = fg, bg = bg }
  end
  return {
    normal = { a = section(p.background, p.green), b = section(p.text, p.panel), c = section(p.text, p.selection) },
    insert = { a = section(p.background, p.purple) },
    visual = { a = section(p.green, p.panel) },
    replace = { a = section(p.background, p.text) },
    command = { a = section(p.text, p.panel) },
    terminal = { a = section(p.green, p.selection) },
    inactive = { a = section(p.purple, p.background), b = section(p.text, p.background), c = section(p.text, p.background) },
  }
end

return M
