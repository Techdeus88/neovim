local M = {}

-- local globals = require("core.globals")
local createcmd = vim.api.nvim_create_user_command
function M.extract_name_from_path(path)
  local e_index = string.reverse(path):find("/", 1, true)
  local name = string.sub(path, -(e_index - 1))
  return name
end

function M.convert_plugins_to_table(plugins)
  local plugins_table = {}
  for _, plugin in ipairs(plugins) do
    local name = M.extract_name_from_path(plugin)
    plugins_table[name] = plugin
  end
  return plugins_table
end

function M.get_plugins_from_deps()
  local p_ins = {}
  vim.schedule(function()
    local plugins = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/opt/", "*", 0, 1)
    table.insert(p_ins, plugins)
  end)
  return p_ins
end

local function make_plural(time)
  return string.format("%ss", time)
end

function M.time_display(init_seconds)
  local key = {
      second = { value = 1, singular = "second", plural = "seconds", rank = 7 },
      minute = { value = 60, singular = "minute", plural = "minutes", rank = 6 },
      hour = { value = 3600, singular = "hour", plural = "hours", rank = 5 },
      day = { value = 86400, singular = "day", plural = "days", rank = 4 },
      week = { value = 604800, singular = "week", plural = "weeks", rank = 3 },
      month = { value = 18144000, singular = "month", plural = "months", rank = 2 },
      year = { value = 31536000, singular = "year", plural = "years", rank = 1 },
  }

  local seconds = init_seconds
  local result = {}

  while seconds > 0 do
    if seconds >= key.year.value then
      local years = math.floor(seconds / key.year.value)
      local seconds_to_remove = key.year.value * years
      seconds = seconds - seconds_to_remove
      result["years"] = { final_result = years, key = key.year }
    elseif seconds >= key.month.value then
      local months = math.floor(seconds / key.month.value)
      local seconds_to_remove = key.month.value * months
      seconds = seconds - seconds_to_remove
      result["months"] = { final_result = months, key = key.month }
    elseif seconds >= key.week.value then
      local weeks = math.floor(seconds / key.week.value)
      local seconds_to_remove = key.week.value * weeks
      seconds = seconds - seconds_to_remove
      result["weeks"] = { final_result = weeks, key = key.week }
    elseif seconds >= key.day.value then
      local days = math.floor(seconds / key.day.value)
      local seconds_to_remove = key.day.value * days
      seconds = seconds - seconds_to_remove
      result["days"] = { final_result = days, key = key.day }
    elseif seconds >= key.hour.value then
      local hours = math.floor(seconds / key.hour.value)
      local seconds_to_remove = key.hour.value * hours
      seconds = seconds - seconds_to_remove
      result["hours"] = { final_result = hours, key = key.hour }
    elseif seconds >= key.minute.value then
      local minutes = math.floor(seconds / key.minute.value)
      local seconds_to_remove = key.minute.value * minutes
      seconds = seconds - seconds_to_remove
      result["minutes"] = { final_result = minutes, key = key.minute }
    elseif seconds >= key.second.value then
      local secs = math.floor(seconds / key.second.value)
      local seconds_to_remove = key.second.value * secs
      seconds = seconds - seconds_to_remove
      result["seconds"] = { final_result = secs, key = key.second }
    else
      seconds = -1
    end
  end
  return result
end

function M.prettify_result(results)
  local parts = {}
  -- Sort by rank to ensure consistent order (years before months before days etc)
  local sorted_results = {}
  for k, v in pairs(results) do
    table.insert(sorted_results, {key = k, value = v})
  end
  table.sort(sorted_results, function(a, b)
    return a.value.key.rank < b.value.key.rank
  end)

  -- Build the time string
  for _, item in ipairs(sorted_results) do
    local value = item.value
    local time_str = value.final_result == 1
      and value.key.singular
      or value.key.plural
    table.insert(parts, string.format("%d %s", value.final_result, time_str))
  end

  if #parts > 0 then
    return table.concat(parts, ", ") .. " ago"
  end
  return "just now"
end

function M.is_available(plugin)
  if not plugin then return false end
  local plugin_path
  -- Check if plugin exists in Mini.deps managed packages
  if plugin == "mini.nvim" then
    plugin_path = vim.fn.stdpath("data") .. "/site/pack/deps/start/" .. plugin
  else
    plugin_path = vim.fn.stdpath("data") .. "/site/pack/deps/opt/" .. plugin
  end

  local is_plugin_path_exist = vim.fn.isdirectory(plugin_path) == 1
  return is_plugin_path_exist
end

function M.display_color_palette()
  local lines = {}
  local palette = _G.theme_palette
  table.insert(lines, "-- --")
  table.insert(lines, "Loaded Colors : " .. #palette .. " palette colors")

  for _, hl in pairs(palette) do
    local color = hl.tostring()
    table.insert(lines, string.format("Color: %s", color))
  end
  table.insert(lines, "-- End of file--")

  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_open_win(buf, true, {
    win = 0,
    split = "right",
  })
end

function M.display_highlights()
  local lines = {}
  -- local highlights = execute(":! echo highlight | echo strtrans(highlights)")
  local highlights = {
    { guifg = "white", key = "love" },
    { guifg = "red",   key = "doctor" },
    { guifg = "black", key = "marlon" },
  }
  table.insert(lines, "-- --")
  table.insert(lines, "Loaded highlights : " .. #highlights .. " highlights")

  for idx, hl in ipairs(highlights) do
    local group = hl.key
    local guifg = hl.guifg ~= nil and hl.guifg or ""
    local cterm = hl.cterm ~= nil and hl.cterm or ""
    local guibg = hl.guibg ~= nil and hl.guibg or ""
    local guisp = hl.guisp ~= nil and hl.guisp or ""
    local gui = hl.gui ~= nil and hl.gui or ""
    table.insert(lines,
      string.format("#%s) Highlight group: %s fg: %s bg: %s %s %s %s ", idx, group, guibg, guifg, cterm, gui, guisp))
  end
  table.insert(lines, "-- End of file--")

  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_open_win(buf, true, {
    win = 0,
    split = "right",
  })
end

function M.display_plugins()
  local funcs = require("core.funcs")
  local lines = {}
  local plugins = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/start/", "*", 0, 1)
  local optional_plugins = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/opt/", "*", 0, 1)
  local plugs = funcs.merge_unique(optional_plugins, plugins)
  
  table.insert(lines, "Loaded plugins : " .. #plugs .. " plugins")
  table.insert(lines, "-- --")
  
  for idx, plug in ipairs(plugs) do
    local name = M.extract_name_from_path(plug)
    table.insert(lines, string.format("  %s (%s) ", name, idx))
  end

  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_open_win(buf, true, {
    win = 0,
    split = "right",
  })
end

function M.display_startup_info()
  -- local modules = Config.loaded_plugins
  -- local sf_files = Config.sourced_files
  local total_complete_screen_time = (_G.end_time - _G.start_time) / 1e6
  local optional_plugins = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/opt/", "*", 0, 1)
  local plugins = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/start/", "*", 0, 1)

  local lines = {
    "Total startup time: " .. string.format("%.2f", total_complete_screen_time) .. " ms",
    "-- --",
    "Total plugins: "
    .. #plugins + #optional_plugins
    .. " plugins",
  }
  -- table.sort(modules, function(a, b) return a.time > b.time end)
  -- table.sort(sf_files, function(a, b) return a.time > b.time end)
  -- table.insert(lines, "-- --")
  -- table.insert(lines, "MODULES LOADED DETAILS")
  -- for _, file in ipairs(modules) do
  --   table.insert(lines, string.format(" #%s  %s: %.2f ms", file.module, file.name, file.time))
  -- end
  -- table.insert(lines, "-- --")
  -- table.insert(lines, "SOURCED FILES LOADED DETAILS")
  -- for _, file in ipairs(sf_files) do
  --   table.insert(lines, string.format("  %s: %.2f ms", file.name, file.time))
  -- end
  table.insert(lines, "-- --")
  table.insert(lines, "PRINT LOGS DETAILS")
  for index, log in ipairs(globals.log) do
    if type(log) == "table" then
      for k, v in pairs(log) do
        table.insert(lines, string.format("  Key-%s: Value-%s", k, v))
      end
    else
      table.insert(lines, string.format("  Log-%s", log))
    end
  end

  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_open_win(buf, true, {
    win = 0,
    split = "right",
  })
end

function M.display_plugins_2()
  local modules = _G.loaded_plugins
  local plugins = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/opt", "*", 0, 1)
  local module_count = #modules
  local lines = {
    "-- --",
    "Loaded modules: " .. module_count .. " modules",
  }

  for _, module in ipairs(modules) do
    table.insert(lines, string.format("  %s ", module.name))
  end


  table.insert(lines, "-- --")
  table.insert(lines, "Loaded plugins : " .. #plugins + 1 .. " plugins")
  table.insert(lines, string.format("  %s (%s) ", "Mini.nvim", 1))
  for idx, plug in ipairs(plugins) do
    local name = M.extract_name_from_path(plug)
    table.insert(lines, string.format("  %s (%s) ", name, idx + 1))
  end

  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_open_win(buf, true, {
    win = 0,
    split = "right",
  })
end

function M.display_startup_info_2()
  local modules = _G.loaded_plugins
  local sf_files = _G.sourced_files
  local total_to_startup_screen_time = _G.initial_starter_total_seconds
  local total_to_render_screen_time = _G.final_start_total_time
  local total_complete_screen_time = (_G.end_time - _G.start_time) / 1e6

  local plugins_count = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/opt", "*", 0, 1)

  local lines = {
    "Initial startup time: " .. string.format("%.2f", total_to_startup_screen_time) .. " ms",
    "Final Startup time: " .. string.format("%.2f", total_to_render_screen_time) .. "  ms",
    "Total startup time: " .. string.format("%.2f", total_complete_screen_time) .. " ms",
    "-- --",
    "Loaded modules: " .. #modules .. " modules",
    "-- --",
    "Sourced files: " .. #sf_files .. " files",
    "-- --",
    "Total plugins: " .. #plugins_count .. " plugins",
  }

  -- table.sort(modules, function(a, b) return a.time > b.time end)
  -- table.sort(sf_files, function(a, b) return a.time > b.time end)
  table.insert(lines, "-- --")
  table.insert(lines, "MODULES LOADED DETAILS")
  for _, file in ipairs(modules) do
    table.insert(lines, string.format(" #%s  %s: %.2f ms", file.module, file.name, file.time))
  end

  table.insert(lines, "-- --")
  table.insert(lines, "SOURCED FILES LOADED DETAILS")
  for _, file in ipairs(sf_files) do
    table.insert(lines, string.format("  %s: %.2f ms", file.name, file.time))
  end
  table.insert(lines, "-- --")
  table.insert(lines, "PRINT LOGS DETAILS")
  for index, log in ipairs(globals.log) do
    table.insert(lines, string.format("-- Start of Log #%s --", index))
    if type(log) == "table" then
      for k, v in pairs(log) do
        table.insert(lines, string.format("  %s: %s", k, v))
      end
    else
      table.insert(lines, string.format("  %s", log))
    end
    table.insert(lines, string.format("-- End of Log #%s --", index))
  end

  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_open_win(buf, true, {
    win = 0,
    split = "right",
  })
end

createcmd(
  "StartupInfo",
  function() vim.defer_fn(M.display_startup_info, 500) end,
  { desc = "Command to view startup metrics" }
)

createcmd(
  "StartupModules",
  function() vim.defer_fn(M.display_plugins, 500) end,
  { desc = "Command to view startup modules" }
)

createcmd(
  "StartupMetrics",
  function() vim.defer_fn(M.display_startup_info, 500) end,
  { desc = "Command to view startup modules" }
)

createcmd("ShowMetricsPlugins", M.display_plugins, { desc = "Print Plugins" })
createcmd("ShowConfigHighlights", M.display_highlights, { desc = "Print Highlights" })
createcmd("ShowConfigColors", M.display_color_palette, { desc = "Print Color Palette" })

vim.keymap.set("n", "<leader>mi", ":StartupModules<cr>", { desc = "Print Plugins" })
vim.keymap.set("n", "<leader>mh", ":ShowConfigHighlights<cr>", { desc = "Print Highlights" })
vim.keymap.set("n", "<leader>mm", ":StartupMetrics<cr>", { desc = "Print Startup Metrics" })
vim.keymap.set("n", "<leader>mc", ":ShowConfigColors<cr>", { desc = "Print Color Palette" })

return M
