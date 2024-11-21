local notify = require("notify")

local M = {}

M.error = function(message, config)
  if config == nil then
    config = {}
  end
  notify(message, "ERROR", config)
end

M.warning = function(message, config)
  if config == nil then
    config = {}
  end
  notify(message, "WARN", config)
end

M.info = function(message, config)
  if config == nil then
    config = {}
  end
  notify(message, "INFO", config)
end

return M
