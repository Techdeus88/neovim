local config = {}
config.load = function()
  ---@module 'DeusConfigFactory'
  local M = require("configs.base.utils.modules")
  local module_window_configs = require("modules.edit_me.windows.base")

  M.run_modules(module_window_configs, "default")
end
return config
