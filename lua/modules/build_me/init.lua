local config = {}

config.load = function()
  local M = require("configs.base.utils.modules")
  ---@module 'DeusConfigFactory'
  local module_build_core_configs = require("modules.build_me.core")
  ---@module 'DeusConfigFactory'
  local module_build_tabby_config = require("modules.build_me.tabby")
  ---@module 'DeusConfigFactory'
  local module_build_sidebar_configs = require("modules.build_me.sidebar")
  ---@module 'DeusConfigFactory'
  local module_build_battery_config = require("modules.build_me.heirline.battery")
  ---@module 'DeusConfigFactory'
  local module_build_noice_config = require("modules.build_me.noice")
  local module_build_heirline_configs = require("modules.build_me.heirline")
  ---@module 'DeusConfigFactory'

  M.run_modules(module_build_tabby_config, "default")
  M.run_modules(module_build_noice_config, "default")
  M.run_modules(module_build_core_configs, "default")
  M.run_module(module_build_battery_config.jbattery, 18)
  M.run_modules(module_build_heirline_configs, "default")
  M.run_modules(module_build_sidebar_configs, "default")
end

return config
