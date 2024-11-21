local config = {}
config.load = function()
  local M = require("configs.base.utils.modules")
  ---@module 'DeusConfigFactory'
  local module_test_me_configs = require("modules.test_me.base")

  M.run_modules(module_test_me_configs, "default")
  return true
end

return config
----End of File---
