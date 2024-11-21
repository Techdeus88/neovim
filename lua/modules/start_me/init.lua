local config = {}
config.load = function()
  local M = require("configs.base.utils.modules")
  local funcs = require("core.funcs")

  ---@module 'DeusConfigFactory'
  local module_start_me_configs = require("modules.start_me.base")
  local i = 1
  for _, conf in funcs.pairsByKeys(module_start_me_configs) do
    M.run_module(conf, i)
    i = i + 1
  end

  -- M.run_module(module_start_me_configs.lua_rocks, 1)
  -- M.run_module(module_start_me_configs.lush, 2)
  -- M.run_module(module_start_me_configs.zenbones_colortheme, 3)
  -- M.run_module(module_start_me_configs.auto_dark_mode, 4)
  -- M.run_module(module_start_me_configs.starter, 5)
  -- M.run_module(module_start_me_configs.project, 6)
  -- M.run_module(module_start_me_configs.plenary, 7)
  -- M.run_module(module_start_me_configs.nui_nvim, 8)
  -- M.run_module(module_start_me_configs.mini_icons, 9)
  -- M.run_module(module_start_me_configs.lsp_icons, 10)
  -- M.run_module(module_start_me_configs.dressing, 11)
  -- M.run_module(module_start_me_configs.nvim_notify, 12)
  -- M.run_module(module_start_me_configs.popup_nvim, 13)
  -- M.run_module(module_start_me_configs.twilight, 14)
  -- M.run_module(module_start_me_configs.zen_mode, 15)
  -- M.run_modules(module_start_me_configs, "default")
  return true
end

return config
----End of File---
