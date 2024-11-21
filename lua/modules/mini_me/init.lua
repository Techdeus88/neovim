local is_available = require("configs.base.utils.metrics").is_available

local config = {}
config.load = function()
  if is_available("mini.nvim") then
    local M = require("configs.base.utils.modules")
    local funcs = require("core.funcs")
    local module_mini_configs = require("modules.mini_me.base")
    
    for _, config in pairs(module_mini_configs) do
      M.run_mini_module(config, _) 
    end
    -- M.run_modules(module_mini_configs, "mini")
  end
end
return config
