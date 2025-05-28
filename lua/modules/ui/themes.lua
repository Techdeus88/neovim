local Themes = {}
Themes.__index = Themes

local IS_LOADED = false

function Themes:add(id, mod)
  self[id] = mod
end

function Themes:get(id)
  return self[id]
end

function Themes:get_all()
  return self
end

local function load_color(theme)
  local ok, _ = pcall(vim.cmd, "colorscheme " .. theme)
  if not ok then
    vim.notify("Error loading theme: " .. theme, vim.log.levels.ERROR)
  end
end

function Themes:write_file(updated_settings)
  require("core.funcs").write_file(Global.settings_path, updated_settings)
end

function Themes:load_color_mod(theme, opts)
  opts = opts or { save_write = false }
  MiniDeps.now(function()
    local color_mod = self:get(theme)
    MiniDeps.add(color_mod[1])

    if type(color_mod.config) == "function" then
      color_mod.config()
    end

    load_color(color_mod.require)
    Global.settings.theme = theme

    if opts.save_write then
      self:write_file(Global.settings)
    end
  end)
end

function Themes:load()
  Themes:add("ashen", {
    "ashen-org/ashen.nvim",
    lazy = false,
    require = "ashen",
    config = function()
      require("ashen").setup {
        bold_functions = true,
        italic_comments = true,
        transparent = false,
        plugins = {
          autoload = false,
          override = {
            "blink",
            "mini-icons",
            "obsidian",
            "oil",
            "render-markdown",
            "telescope",
            "minimap",
            "neogit",
            "fzflua",
            "fzf",
          },
        },
      }
    end,
  })

  Themes:add("e-ink", {
    "alexxGmZ/e-ink.nvim",
    lazy = false,
    require = "e-ink",
    config = function()
      local set_hl = vim.api.nvim_set_hl
      local mono = require("e-ink.palette").mono()
      local everforest = require("e-ink.palette").everforest()
      set_hl(0, "Group", {
        fg = mono[15],
      })
      set_hl(0, "Group", {
        fg = everforest.green,
      })
      require("e-ink").setup()
    end,
  })

  Themes:add("everforest", {
    "neanias/everforest-nvim",
    lazy = false,
    require = "everforest",
    config = function()
      require("everforest").setup {
        transparent = true, -- Enable transparent background
        dim = true, -- Dim inactive windows with a black background
      }
    end,
  })

  Themes:add("mies", {
    "jaredgorski/Mies.vim",
    lazy = false,
    require = "mies",
    config = true,
  })

  Themes:add("neodarcula", {
    "pmouraguedes/neodarcula.nvim",
    lazy = false,
    require = "neodarcula",
    config = function()
      require("neodarcula").setup {
        -- transparent = false, -- enable transparent background
        transparent = true, -- Enable transparent background
        dim = true, -- Dim inactive windows with a black background
      }
    end,
  })

  Themes:add("okcolors", {
    "e-q/okcolors.nvim",
    lazy = false,
    require = "okcolors",
    config = function()
      local ok, ok_colors = pcall(require, "okcolors")
      if not ok then
        return
      end
      ok_colors.setup { variant = "smooth" }
    end,
  })

  Themes:add("shadow", {
    "rjshkhr/shadow.nvim",
    require = "shadow",
    lazy = false,
    config = function()
      local shadow_ok, shadow = pcall(require, "shadow")
      if not shadow_ok then
        return
      end
      shadow.setup()
    end,
  })

  Themes:add("yang", {
    "pgdouyon/vim-yin-yang",
    lazy = false,
    require = "yang",
    config = true,
  })

  Themes:add("yin", {
    "pgdouyon/vim-yin-yang",
    lazy = false,
    require = "yin",
    config = true,
  })

  IS_LOADED = true
end

if not IS_LOADED then
  Themes:load()
end

function Themes:active()
  local theme = Global.settings.theme
  if theme == nil then
    return Themes.ashen
  end
  return Themes:get(theme)
end

function Themes:get_names()
  return vim.tbl_keys(self:get_all())
end

Themes.names = {
  "ashen",
  "e-ink",
  "everforest",
  "mies",
  "neodarcula",
  "okcolors",
  "shadow",
  "yang",
  "yin",
}

return Themes
