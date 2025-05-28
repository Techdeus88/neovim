--Start-of-file--
local funcs = require "core.funcs"

local B = {}

function B.base_techdeus()
  -- Basic vim settings
  _G.techdeus = {}

  vim.g.mapleader = " "
  vim.g.maplocalleader = ","
  vim.keymap.set("n", " ", "", { noremap = true })
  vim.keymap.set("x", " ", "", { noremap = true })

  local disabled_built_ins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "matchit",
    "tar",
    "tarPlugin",
    "rrhelper",
    "spellfile_plugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
  }

  for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
  end

  local Select = require("configs.select").build_select
  vim.deprecate = function() end

  local function deus_theme()
    local status
    if Global.settings.theme == "ashen" then
      status = "Ashen"
    elseif Global.settings.theme == "e-ink" then
      status = "E-Ink"
    elseif Global.settings.theme == "shadow" then
      status = "Shadow"
    elseif Global.settings.theme == "neodarcula" then
      status = "Neodracula"
    elseif Global.settings.theme == "yin" then
      status = "Yin"
    elseif Global.settings.theme == "yang" then
      status = "Yang"
    elseif Global.settings.theme == "everforest" then
      status = "Everforest"
    elseif Global.settings.theme == "mies" then
      status = "Mies"
    end

    local items = {
      "Ashen",
      "Shadow",
      "Neodracula",
      "Yin",
      "E-ink",
      "Yang",
      "Mies",
      "Everforest",
    }
    local opts = { prompt = "Theme (" .. status .. ")" }

    Select(items, opts, function(choice)
      if choice == "Cancel" then
      else
        local user_choice = string.lower(choice)
        user_choice = string.gsub(user_choice, " ", "-")
        Global.settings["theme"] = user_choice
        vim.cmd("colorscheme " .. user_choice)
        funcs.write_file(_G.Global.settings_path, Global.settings)
      end
    end)
  end
  vim.api.nvim_create_user_command("DeusTheme", deus_theme, {})

  local function deus_float_height()
    local Select = require("configs.select").build_select
    local status = tostring(Global.settings.floatheight)
    if status == "1" then
      status = "1.0"
    end

    local items = {
      "0.1",
      "0.2",
      "0.3",
      "0.4",
      "0.5",
      "0.6",
      "0.7",
      "0.8",
      "0.9",
      "1.0",
    }
    local opts = { prompt = "Float height (current: " .. status .. ")" }

    Select(items, opts, function(choice)
      if choice == "Cancel" then
      else
        local user_choice = choice
        vim.notify("Float height: " .. choice, vim.log.levels.INFO, {
          title = "TECHDEUS IDE",
        })
        Global.settings["floatheight"] = tonumber(user_choice) + 0.0
        funcs.write_file(Global.settings_path, Global.settings)
      end
    end)
  end
  vim.api.nvim_create_user_command("DeusFloatHeight", deus_float_height, {})
  vim.api.nvim_create_user_command(
    "EditorConfigCreate",
    "lua require'core.funcs'.copy_file(Global.techdeus_path .. '/base/templates/.editorconfig', vim.fn.getcwd() .. '/.editorconfig')",
    { desc = "Create .editorconfig file from template" }
  )

  local function deus_module_info()
    local modules = Modules:get_modules()

    local mod_index = 1
    local mod_names = require("base.utils").map(modules, function(module)
      return module.base.name
    end)
    print(vim.inspect(mod_names))

    local opts = { prompt = "Module (" .. mod_names[mod_index] .. ")" }

    Select(mod_names, opts, function(choice)
      print("choice: " .. choice)
      if choice == "Cancel" then
      else
        local user_choice = string.lower(choice)
        require("base.metrics").show_module_info(user_choice)
      end
    end)
  end
  vim.api.nvim_create_user_command("DeusModuleInfo", deus_module_info, {})
  vim.keymap.set("n", "<leader>mi", ":DeusModuleInfo<CR>", { noremap = true, silent = true })
end

B.base_techdeus()

function B.languages()
  local base = require "languages.base.file_types"
  Global.file_types = base.lang_to_ft_map
  Global.fts = base.fts
  -- Cache filetype lookup table
  Global.valid_filetypes = {}
  for _, ft in ipairs(Global.fts) do
    Global.valid_filetypes[ft] = true
  end
end

function B.colors()
  local colors, _ = pcall(require, "modules.ui.themes")
  if not colors then
      vim.notify("Colorschemes not found", vim.log.levels.ERROR, {
        title = "TECHDEUS IDE",
      })
  end
end

B.languages()
B.colors()

return B
--End-of-file--
