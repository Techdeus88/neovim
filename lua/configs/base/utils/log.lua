local L = {}
local globals = require("core.globals")
-- Log for personal use during debugging
globals.log = {}

local start_hrtime = vim.loop.hrtime()
_G.add_to_log = function(...)
  local t = { ... }
  t.timestamp = 0.000001 * (vim.loop.hrtime() - start_hrtime)
  table.insert(globals.log, vim.deepcopy(t))
end
-- _G.dp(add_to_log)

local log_buf_id
_G.log_print = function()
  if log_buf_id == nil or not vim.api.nvim_buf_is_valid(log_buf_id) then
    log_buf_id = vim.api.nvim_create_buf(true, true)
  end
  vim.api.nvim_win_set_buf(0, log_buf_id)
  vim.api.nvim_buf_set_lines(log_buf_id, 0, -1, false, vim.split(vim.inspect(globals.log), "\n"))
end

_G.log_clear = function()
  globals.log = {}
  start_hrtime = vim.loop.hrtime()
  vim.cmd('echo "Cleared log"')
end

function _G.log_table(table)
  print(vim.inspect(table))
end

_G.require_log = function(path, name, module_num)
  local times_called = 0
  return (function()
    _G.add_to_log(name, path, module_num)
    require(path)
    times_called = times_called + 1
  end)()
end

L.print_table = function(items)
  local lines = {}

  if type(items) == "table" then
    for i, o in pairs(items) do
      if type(o) == "table" then
        table.insert(lines, table.concat(o, ", "))
      end
      if type(o) == "string" or type(o) == "number" then
        table.insert(lines, o)
      end
    end
  end

  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_open_win(buf, true, {
    win = 0,
    split = "right",
  })
end
return L
