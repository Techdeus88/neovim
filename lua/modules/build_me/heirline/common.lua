local heirline = require("heirline")
local heirline_conditions = require("heirline.conditions")
local colors = require("configs.base.colors").base_colors()
local heirline_utils = require("heirline.utils")
local heirline_highlights = require("heirline.highlights")
local icons = require("configs.base.ui.icons")

local buftypes = {
  "nofile",
  "prompt",
  "help",
}

local filetypes = {
  "ctrlspace",
  "ctrlspace_help",
  "packer",
  "undotree",
  "diff",
  "Outline",
  "NvimTree",
  "DeusHelper",
  "ministarter",
  "floaterm",
  "dashboard",
  "vista",
  "spectre_panel",
  "DiffviewFiles",
  "flutterToolsOutline",
  "log",
  "dapui_scopes",
  "dapui_breakpoints",
  "dapui_stacks",
  "dapui_watches",
  "dapui_console",
  "calendar",
  "neo-tree",
  "neo-tree-popup",
  "noice",
  "toggleterm",
  "DeusShell",
  "oil",
}

local Dap = {
  condition = function()
    local session = require("dap").session()
    return session ~= nil
  end,
  provider = function() return "  " end,
  on_click = {
    callback = function() require("dap").continue() end,
    name = "sl_dap_click",
  },
  hl = { fg = colors.rose.hex },
}

local vi_mode = {
  init = function(self)
    self.mode = vim.fn.mode(1)
    if not self.once then
      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:*o",
        command = "redrawstatus",
      })
      self.once = true
    end
  end,
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
      rm = "M",
      ["r?"] = "?",
      ["!"] = "!",
      t = "T",
    },
    mode_colors = {
      n = colors.leaf.darken(80).hex,
      i = colors.rose.darken(80).hex,
      v = colors.water.darken(80).hex,
      V = colors.water.darken(80).hex,
      ["\23"] = colors.wood.darken(80).hex,
      c = colors.water.darken(80).hex,
      s = colors.sky.darken(80).hex,
      S = colors.sky.darken(80).hex,
      ["\20"] = colors.sky.darken(80).hex,
      R = colors.wood.darken(80).hex,
      r = colors.wood.darken(80).hex,
      ["!"] = colors.blossom.darken(80).hex,
      t = colors.leaf.darken(80).hex,
    },
  },
  provider = function(self) return " " .. icons.common.vim .. " %(" .. self.mode_names[self.mode] .. "%)  " end,
  hl = function(self)
    _G.TECHDEUS_MODE = self.mode:sub(1, 1)
    return { bg = self.mode_colors[self.mode:sub(1, 1)], fg = colors.fg.hex, bold = true }
  end,
  update = {
    "ModeChanged",
    "MenuPopup",
    "CmdlineEnter",
    "CmdlineLeave",
  },
}

local LeftSlantStart = {
  provider = "",
  hl = { fg = colors.wood.hex, bg = colors.bg.hex },
}

local LeftSlantEnd = {
  provider = "",
  hl = { fg = colors.wood.hex, bg = colors.bg.hex },
}

local RightSlantStart = {
  provider = "",
  hl = { fg = colors.wood.hex, bg = colors.bg.hex },
}

local RightSlantEnd = {
  provider = "",
  hl = { fg = colors.wood.hex, bg = colors.bg.hex },
}

local FileType = {
  provider = function()
    local file_type = vim.bo.filetype
    if file_type ~= "" then return "  " .. string.upper(file_type) end
  end,
  hl = { fg = colors.water.hex, bold = true },
}
local file_icon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon = require("mini.icons").get("file", filename)
  end,
  provider = function(self)
    local is_filename = vim.fn.fnamemodify(self.filename, ":.")
    if is_filename ~= "" then return self.icon and self.icon .. " " end
  end,
  hl = function()
    return {
      fg = vi_mode.static.mode_colors[_G.TECHDEUS_MODE],
      bold = true,
    }
  end,
}

local slants = {
  left = LeftSlantStart,
  right = RightSlantStart,
  left_end = LeftSlantEnd,
  right_end = RightSlantEnd,
}

local FileIcon = {
  init = function(self)
    local filename = self.filename
    self.icon, self.icon_color = require("mini.icons").get("file", filename)
  end,
  provider = function(self) return "  " .. self.icon .. "  " end,
  hl = function(self)
    return {
      {
        fg = self.icon_color,
        bold = true,
      },
    }
  end,
}
local function OverseerTasksForStatus(status)
  return {
    condition = function(self) return self.tasks[status] end,
    provider = function(self) return string.format("%s%d", self.symbols[status], #self.tasks[status]) end,
    hl = function(self)
      return {
        fg = self.colors[status],
      }
    end,
  }
end


local Overseer = {
  condition = function() return package.loaded.overseer end,
  init = function(self)
    local tasks = require("overseer.task_list").list_tasks({ unique = true })
    local tasks_by_status = require("overseer.util").tbl_group_by(tasks, "status")
    self.tasks = tasks_by_status
  end,
  static = {
    symbols = {
      ["CANCELED"] = "  ",
      ["FAILURE"] = "  ",
      ["RUNNING"] = " 省",
      ["SUCCESS"] = "  ",
    },
    colors = {
      ["CANCELED"] = "gray",
      ["FAILURE"] = "red",
      ["RUNNING"] = "yellow",
      ["SUCCESS"] = "green",
    },
  },
  OverseerTasksForStatus("CANCELED"),
  OverseerTasksForStatus("RUNNING"),
  OverseerTasksForStatus("SUCCESS"),
  OverseerTasksForStatus("FAILURE"),
  on_click = {
    callback = function() require("neotest").run.run_last() end,
    name = "sl_overseer_click",
  },
}


local FileFormat = {
  provider = function()
    local format = vim.bo.fileformat
    if format ~= "" then
      local symbols = {
        unix = icons.common.unix,
        dos = icons.common.dos,
        mac = icons.common.mac,
      }
      return " " .. symbols[format]
    end
  end,
  hl = { fg = colors.blossom.hex, bold = true },
}

local FileEncoding = {
  provider = function()
    local enc = vim.opt.fileencoding:get()
    if enc ~= "" then return " " .. enc:upper() end
  end,
  hl = { fg = colors.rose.hex, bold = true },
}

return {
  file = { FileType = FileType, FileIcon = FileIcon, FileEncoding = FileEncoding, FileFormat = FileFormat },
  overseer = Overseer,
  dap = Dap,
  slants = slants,
  heirline = heirline,
  heirline_conditions = heirline_conditions,
  heirline_highlights = heirline_highlights,
  heirline_utils = heirline_utils,
  theme_colors = colors,
  buftypes = buftypes,
  filetypes = filetypes,
  vi_mode = vi_mode,
  icons = icons,
  space = { provider = " ", hl = { bg = colors.bg.hex, fg = colors.bg.hex } },
  align = { provider = "%=", hl = { bg = colors.bg.hex, fg = colors.bg.hex } },
}
-- { "", guifg = darken_color(main_color, 7.42, main_color) },
-- { "", guifg = darken_color(main_color, 7.42, main_color) },

