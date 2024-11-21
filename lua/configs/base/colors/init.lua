local theme = require(string.format("%s", _G.DEUS_SETTINGS.theme)) -- or any other flavor
local palette = require(string.format("%s.palette", _G.DEUS_SETTINGS.theme))

local C = {}

C.theme = theme
C.palette = palette

C.themes = {
  ["tokyobones"] = {
    ["dark"] = {
      bg        = "#1a1b26",
      bg_warm   = "#24283b",
      fg        = "#c0caf5",
      rose      = "#f7768e",
      leaf      = "#73daca",
      wood      = "#e0af68",
      water     = "#7aa2f7",
      blossom   = "#bb9af7",
      sky       = "#2ac3de",
      orange    = "#ff9e64",
      sky1      = "#73daca",
      white     = "#FFFFFF",
      corection = "#141414",
    },
    ["light"] = {
      bg        = "#d5d6db",
      fg        = "#343b58",
      rose      = "#8c4351",
      leaf      = "#33635c",
      wood      = "#8f5e15",
      water     = "#34548a",
      blossom   = "#5a4a78",
      sky       = "#166775",
      orange    = "#965027",
      sky1      = "#33635c",
      white     = "#FFFFFF",
      corection = "#141414",
    },
  },
  ["seoulbones"] = {
    ["dark"] = {
      bg        = "#4b4b4b",
      fg        = "#d9d9d9",
      rose      = "#e17899",
      leaf      = "#98bc99",
      wood      = "#ffde99",
      water     = "#98bede",
      blossom   = "#999abd",
      sky       = "#6fbcbd",
      orange    = "#e19972",
      white     = "#FFFFFF",
      corection = "#141414",

    },
    ["light"] = {
      bg        = "#e1e1e1",
      fg        = "#616161",
      rose      = "#e17899",
      leaf      = "#719872",
      wood      = "#e19972",
      water     = "#0099bd",
      blossom   = "#9a7599",
      sky       = "#009799",
      orange    = "#9a7200",
      white     = "#FFFFFF",
      corection = "#141414",
    },
  },
  ["all"] = {
    ["blue_01"]          = "#0C97D3",
    ["blue_02"]          = "#0B8EC6",
    ["blue_03"]          = "#0A85B9",
    ["teal_01"]          = "#02A384",
    ["teal_02"]          = "#02967A",
    ["teal_03"]          = "#028970",
    ["cyan_01"]          = "#019AB3",
    ["cyan_02"]          = "#018FA6",
    ["cyan_03"]          = "#018499",
    ["green_01"]         = "#95B266",
    ["green_02"]         = "#8AA55F",
    ["green_03"]         = "#7F9858",
    ["red_01"]           = "#E34A39",
    ["red_02"]           = "#D64636",
    ["red_03"]           = "#C94233",
    ["orange_01"]        = "#FF9C2A",
    ["orange_02"]        = "#F29428",
    ["orange_03"]        = "#E58C26",
    ["MiniIconsAzure"]   = "#0B8EC6",
    ["MiniIconsBlue"]    = "#0C97D3",
    ["MiniIconsCyan"]    = "#02A384",
    ["MiniIconsGreen"]   = "#95B266",
    ["MiniIconsGrey"]    = "#448589",
    ["MiniIconsOrange "] = "#FF9C2A",
    ["MiniIconsPurple"]  = "Purple",
    ["MiniIconsRed"]     = "#E34A39",
    ["MiniIconsYellow"]  = "#E58C26",
  }
}

function C.highlight_colors()
  local utils = require("heirline.utils")
  return {
    MiniIconsAzure = utils.get_highlight("Folded").bg,
    MiniIconsBlue = utils.get_highlight("Function").fg,
    MiniIconsCyan = utils.get_highlight("Function").fg,
    MiniIconsGreen = utils.get_highlight("String").fg,
    MiniIconsGrey = utils.get_highlight("NonText").fg,
    MiniIconsOrange = utils.get_highlight("Constant").fg,
    MiniIconsPurple = utils.get_highlight("Statement").fg,
    MiniIconsRed = utils.get_highlight("DiagnosticError").fg,
    MiniIconsYellow = utils.get_highlight("Number").fg,
    git_add = utils.get_highlight("diffAdded").fg,
    git_added = utils.get_highlight("diffAdded").fg,
    git_del = utils.get_highlight("diffDeleted").fg,
    git_deleted = utils.get_highlight("diffDeleted").fg,
    git_change = utils.get_highlight("diffChanged").fg,
    git_changed = utils.get_highlight("diffChanged").fg,
  }
end

function C.convert_color_to_string(color)
  return tostring(color)
end

function C.base_colors()
  if vim.opt.background:get() == "dark" then
    return C.palette.dark
  else
    return C.palette.light
  end
end

local colors = C.base_colors()
C.vi_mode = {
  static = {
    mode_names = {
      n = "N",
      no = "N?",
      nov = "N?",
      noV = "N?",
      ["no\22"] = "N?",
      niI = "Ni",
      niR = "Nr",
      niV = "Nv",
      nt = "Nt",
      v = "V",
      vs = "Vs",
      V = "V_",
      Vs = "Vs",
      ["\22"] = "^V",
      ["\22s"] = "^V",
      s = "S",
      S = "S_",
      ["\19"] = "^S",
      i = "I",
      ic = "Ic",
      ix = "Ix",
      R = "R",
      Rc = "Rc",
      Rx = "Rx",
      Rv = "Rv",
      Rvc = "Rv",
      Rvx = "Rv",
      c = "C",
      cv = "Ex",
      r = "...",

      ["r?"] = "?",
      ["!"] = "!",
      t = "T",
    },
    mode_colors = {
      n = colors.rose.hex,
      i = colors.leaf.hex,
      v = colors.water.hex,
      V = colors.water.hex,
      ["\22"] = colors.wood.hex,
      c = colors.water.hex,
      s = colors.sky.hex,
      S = colors.sky.hex,
      ["\19"] = colors.sky.hex,
      R = colors.leaf.hex,
      r = colors.leaf.hex,
      ["!"] = colors.rose.hex,
      t = colors.rose.hex,
    },
  },
}

return C
