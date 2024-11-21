local base = require("configs")
local M = {}
_G.ModulesRun = {}
_G.MiniModulesRun = {}

function M.reload_plugin(module_name)
  package.loaded[module_name] = nil
  return require(module_name)
end

function M.run_module(config, config_num)
  local module_start = vim.loop.hrtime()
  local c = base.default_config(config, config_num)
  local module_end = vim.loop.hrtime()
  local module_load_time = (module_end - module_start) / 1e6
  if c.result then
    table.insert(ModulesRun, { module = table.concat(c.config, ""), idx = config_num, time_elapsed = module_load_time })
  end
end

function M.run_mini_module(config, config_num)
  local mini_module_start = vim.loop.hrtime()
  local c = base.mini_config(config, config_num)
  local mini_module_end = vim.loop.hrtime()
  local mini_module_load_time = (mini_module_end - mini_module_start) / 1e6
  if c.result then
    table.insert(MiniModulesRun,
    { module = table.concat(c.config, ""), idx = config_num, time_elapsed = mini_module_load_time })
  end
end

---@return nil
---@param module_configs DeusConfigFactory
function M.run_modules(module_configs, config_type)
  config_type = config_type ~= nil and config_type or "default"
  if config_type == "mini" then
    for config_num, config in pairs(module_configs) do
      M.run_mini_module(config, config_num)
    end
  elseif config_type == "default" then
    for config_num, config in pairs(module_configs) do
      M.run_module(config, config_num)
    end
  else
    vim.notify("No config type or an incorrect one was used. Please fix the config type for the following config",
      vim.log.levels.ERROR)
  end
end

return M
