--Start-of-file--
local funcs = require "core.funcs"

local M = {}
M.times = {}

M.set_initial_time = function()
  M.times.initial = funcs.format_metrics_time(vim.uv.hrtime(), "initial")
  _G.duration_init_ns = M.times.initial
end

M.set_buffer_ft = function(bufnr, filetype)
  filetype = filetype or "base"
  vim.api.nvim_buf_set_option(bufnr, "filetype", "techdeus_" .. filetype)
end

M.set_essential_time = function()
  M.times.essential = funcs.format_metrics_time(vim.uv.hrtime(), "essential")
end

M.set_final_time = function()
  M.times.final = funcs.format_metrics_time(vim.uv.hrtime(), "final")
  print("Times", M.times)
end

function M.get_modules()
  if Modules ~= nil then
    return Modules:get_modules()
  end
end

function M.make_buffer()
  local buf = vim.api.nvim_create_buf(true, true)

  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "buflisted", true)
  vim.api.nvim_buf_set_option(buf, "filetype", "techdeus_metrics")
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_option(buf, "readonly", false)

  return buf
end

function M.set_buffer_option(buf, option, value)
  vim.api.nvim_buf_set_option(buf, option, value)
end

function M.set_buffer(buf)
  vim.api.nvim_set_current_buf(buf)
end

function M.create_centered_window(buf, content)
  -- Calculate dimensions
  local width = 0
  local height = #content

  for _, line in ipairs(content) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  -- Add padding
  width = width + 4
  height = height + 2

  -- Get editor dimensions
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  -- Calculate position
  local row = math.floor((editor_height - height) / 2)
  local col = math.floor((editor_width - width) / 2)

  -- Window options
  local opts = {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Metrics ",
    title_pos = "center",
  }

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Set window options
  vim.api.nvim_win_set_option(win, "winblend", 0)
  vim.api.nvim_win_set_option(win, "cursorline", false)
  vim.api.nvim_win_set_option(win, "number", false)
  vim.api.nvim_win_set_option(win, "relativenumber", false)
  vim.api.nvim_win_set_option(win, "signcolumn", "no")

  return win
end

function M.center_buffer_content(buf, content)
  -- Get window width
  local win_width = vim.api.nvim_win_get_width(0)

  -- Find longest line
  local max_width = 0
  for _, line in ipairs(content) do
    local line_width = vim.fn.strdisplaywidth(line)
    max_width = math.max(max_width, line_width)
  end

  -- Calculate left padding (equal on both sides)
  local padding = math.floor((win_width - max_width) / 2)
  local left_pad = string.rep(" ", padding)

  -- Center each line with padding on both sides
  local centered_content = {}
  for _, line in ipairs(content) do
    local line_width = vim.fn.strdisplaywidth(line)
    local right_pad = string.rep(" ", win_width - padding - line_width)
    table.insert(centered_content, left_pad .. line .. right_pad)
  end
  -- Set content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, centered_content)
  M.set_buffer_option(buf, "modifiable", false)
  M.set_buffer_option(buf, "readonly", true)
end

function M.open_window(buf, content, win_opts)
  win_opts = win_opts or {}
  local width = 0
  local height = 0
  for _, line in ipairs(content) do
    height = height + 1
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  height = height + 2

  local default_opts = {
    relative = "editor",
    row = 0,
    col = 0,
    height = height,
    width = width,
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, vim.tbl_extend("force", default_opts, win_opts))

  M.build_window(win)
  vim.api.nvim_win_set_buf(win, buf)
  M.add_content_to_buffer(buf, content)
  M.make_buffer_private(buf)

  return win
end

function M.build_window(win)
  vim.api.nvim_win_set_option(win, "number", false)
  vim.api.nvim_win_set_option(win, "relativenumber", false)
  vim.api.nvim_win_set_option(win, "cursorline", false)
  vim.api.nvim_win_set_option(win, "signcolumn", "no")
  vim.api.nvim_win_set_option(win, "colorcolumn", "")
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_win_set_option(win, "textwidth", 0)
end

function M.handle_tbl_values_indent(tbl, indent, seen)
  indent = indent or 0
  seen = seen or {}

  if seen[tbl] then
    return { "..." }
  end
  seen[tbl] = true

  if indent > 100 then
    return { "..." }
  end
  local formatted_lines = {}
  local prefix = string.rep("  ", indent * 4) -- Indentation for nested levels
  local keys = {}
  for key, _ in pairs(tbl) do
    table.insert(keys, key)
  end
  table.sort(keys, function(a, b)
    return tostring(a) < tostring(b)
  end) -- Sort keys for consistent output

  for _, key in ipairs(keys) do
    local value = tbl[key]
    table.insert(formatted_lines, string.format("%s%s ->", prefix, tostring(key)))
    if type(value) == "table" then
      -- Recursively call handle_tbl_values_indent for nested tables
      -- Append the lines from the nested table directly
      local nested_lines = M.handle_tbl_values_indent(value, indent + 1, seen)
      for _, line in ipairs(nested_lines) do
        table.insert(formatted_lines, line)
      end
    else
      -- Use the new M.format_value for non-table values in indent format
      -- Pass only the value and the type 'indent'
      local formatted_value = M.format_value(value, "indent")
      table.insert(formatted_lines, string.format("%s  %s", prefix, formatted_value))
    end
  end
  return formatted_lines
end

function M.handle_tbl_values_json(tbl, indent, seen)
  indent = indent or 0
  seen = seen or {}

  if seen[tbl] then
    return { string.rep("  ", indent) .. '"..."' } -- Indicate cycle with JSON string and indentation
  end
  seen[tbl] = true

  if indent > 100 then
    return { string.rep("  ", indent) .. '"..."' } -- Indicate depth limit with JSON string and indentation
  end

  local formatted_lines = {}
  local prefix = string.rep("  ", indent * 4)

  -- Assuming object-like structure based on original code's output
  table.insert(formatted_lines, prefix .. "{")

  local keys = {}
  for key, _ in pairs(tbl) do
    table.insert(keys, key)
  end
  table.sort(keys, function(a, b)
    return tostring(a) < tostring(b)
  end) -- Sort keys for consistent output

  for i, key in ipairs(keys) do
    local value = tbl[key]
    local line_prefix = string.rep("  ", indent + 1) -- Indent keys/values within the object

    -- Use M.format_value for keys to ensure JSON string formatting
    local formatted_key_str = M.format_value(tostring(key), "json")

    if type(value) == "table" then
      -- Recursively call handle_tbl_values_json for nested tables
      local nested_lines = M.handle_tbl_values_json(value, indent + 1, seen)
      -- Append the lines from the nested table directly
      for _, nested_line in ipairs(nested_lines) do
        table.insert(formatted_lines, line_prefix .. nested_line)
      end
    else
      -- Use the new M.format_value for non-table values in JSON format
      -- Pass only the value and the type 'json'
      local formatted_value = M.format_value(value, "json")
      local value_line = string.format("%s: %s", formatted_key_str, formatted_value)
      -- Add a comma after each entry except the last one for valid JSON
      if i ~= #keys then
        value_line = value_line .. ","
      end
      table.insert(formatted_lines, line_prefix .. value_line)
    end
  end
  table.insert(formatted_lines, prefix .. "}") -- End object

  return formatted_lines
end

function M.handle_tbl_values_tab(tbl, depth, seen)
  depth = depth or 0
  seen = seen or {}

  if seen[tbl] then
    return { "..." }
  end
  seen[tbl] = true

  if depth > 100 then
    return { "..." }
  end

  local formatted_lines = {}
  table.insert(formatted_lines, string.format("%-20s | %-20s", "Key", "Value"))
  table.insert(formatted_lines, string.rep("-", 43))
  local keys = {}
  for key, _ in pairs(tbl) do
    table.insert(keys, key)
  end
  table.sort(keys, function(a, b)
    return tostring(a) < tostring(b)
  end) -- Sort keys for consistent output

  for _, key in ipairs(keys) do
    local value = tbl[key]
    if type(value) == "table" then
      -- In the tabular format, nested tables are indicated but not fully displayed recursively
      table.insert(formatted_lines, string.format("%-20s | %-20s", tostring(key), "{table}"))
    else
      -- Use the new M.format_value for non-table values in tab format
      -- Pass only the value and the type 'tab'
      local formatted_value = M.format_value(value, "tab")
      table.insert(formatted_lines, string.format("%-20s | %-20s", tostring(key), formatted_value))
    end
  end
  return formatted_lines
end

function M.handle_tbl_values(tbl, tbl_type, depth, seen)
  -- Initialize depth and seen table on the first call if not provided
  depth = depth or 0
  seen = seen or {}

  -- Handle potential cycles at the top level or during specific format recursion
  if seen[tbl] then
    return { "..." } -- Indicate cycle
  end
  -- Mark this table as seen
  seen[tbl] = true

  -- Limit overall recursion depth
  if depth > 100 then
    return { "..." }
  end

  -- Select the appropriate table iterator/formatter based on the specified type
  local loader = tbl_type == "tab" and M.handle_tbl_values_tab
      or tbl_type == "json" and M.handle_tbl_values_json
      or tbl_type == "indent" and M.handle_tbl_values_indent
      or nil -- If type is nil or unrecognized, use the default formatting path

  if loader ~= nil then
    -- If a specific format is requested, delegate to the specialized function.
    -- These specialized functions handle their own table iteration and recursion
    -- and use the new M.format_value for non-table items.
    -- Pass depth and seen for consistent cycle detection and depth limiting across formats.
    local formatted_lines = loader(tbl, depth, seen)
    return formatted_lines
  else -- Default formatting case
    local formatted_lines = {}
    local keys = {}
    for key, _ in pairs(tbl) do
      table.insert(keys, key)
    end
    table.sort(keys, function(a, b)
      return tostring(a) < tostring(b)
    end) -- Sort keys for consistent output

    -- Iterate through key-value pairs of the table for the default format
    for _, key in ipairs(keys) do
      local value = tbl[key]
      -- Add the formatted key followed by '->'
      table.insert(formatted_lines, string.format("%s%s", tostring(key), "->"))

      if type(value) == "table" then
        -- Recursively call M.handle_tbl_values for nested tables (default format)
        -- Pass the updated depth and seen table for recursion tracking
        local nested_lines = M.handle_tbl_values(value, nil, depth + 1, seen)
        -- Append the lines from the nested table directly
        for _, line in ipairs(nested_lines) do
          table.insert(formatted_lines, "  " .. line) -- Add indentation for nested lines
        end
      else
        -- Use the new M.format_value for non-table values in default format (type=nil)
        -- Pass only the value and nil for the type
        local formatted_value = M.format_value(value, nil)
        table.insert(formatted_lines, string.format("%s", formatted_value))
      end
    end
    return formatted_lines
  end
end

function M.format_value(value, tbl_type)
  -- This function is designed to format non-table values.
  -- If a table is passed here, it's an error in the calling logic.
  -- We will return an error indicator, although the calling functions
  -- are primarily responsible for handling table recursion.
  if type(value) == "table" then
    return "[ERROR: format_value called with table]" -- Should not happen if called correctly
  end

  -- Format based on the requested type
  if tbl_type == "json" then
    -- JSON specific formatting for non-table types
    if type(value) == "boolean" then
      return value and "true" or "false" -- JSON boolean literals are lowercase
    elseif type(value) == "string" then
      -- Simple JSON string quoting; a real implementation needs proper escaping of quotes and backslashes.
      -- Also handle escaping of backslashes and double quotes within the string.
      local escaped_string = value:gsub("\\", "\\\\"):gsub('"', '\\"')
      return string.format('"%s"', escaped_string)
    elseif type(value) == "number" then
      return tostring(value) -- JSON numbers are represented as strings of digits
    elseif type(value) == "function" then
      return '"function"'    -- Represent functions as strings in JSON output
    elseif value == nil then
      return "null"          -- JSON null literal
    else
      return '"unknown"'     -- Fallback for other types, represented as a string
    end
  else                       -- Default format (type is nil or not recognized)
    -- Default formatting for non-table types
    if type(value) == "boolean" then
      return value and "true" or "false"
    elseif type(value) == "string" or type(value) == "number" then
      return tostring(value)
    elseif type(value) == "function" then
      return "function"
    elseif value == nil then
      return "nil"
    else
      return "unknown"
    end
  end
end

function M.make_buffer_private(buf)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "readonly", true)
end

function M.merge_lines(lines, newlines, title, divider)
  table.insert(lines, title)
  table.insert(lines, divider)
  for _, line in ipairs(newlines) do
    table.insert(lines, line)
  end
  table.insert(lines, divider)
end

function M.display_global(show_global, show_settings, show_files, tbl_type)
  tbl_type = tbl_type or ""
  local final_global = vim.deepcopy(Global)
  local lines = {}

  -- Process global table
  if show_global then
    local lines_global = M.handle_tbl_values(final_global, tbl_type)
    local divider = string.rep("-", 50)
    local title = "-- global --"
    M.merge_lines(lines, lines_global, title, divider)
  end

  -- Process settings table
  if show_settings then
    local final_settings = final_global.settings
    local lines_settings = M.handle_tbl_values(final_settings, tbl_type)
    local divider = string.rep("-", 50)
    local title = "-- Settings --"
    M.merge_lines(lines, lines_settings, title, divider)
  end

  if show_files then
    local final_files = final_global.files
    local lines_files = M.handle_tbl_values(final_files, tbl_type)
    local divider = string.rep("-", 50)
    local title = "-- Files --"
    M.merge_lines(lines, lines_files, title, divider)
  end

  -- Create buffer and display content
  local buf = M.make_buffer()
  M.set_buffer_ft(buf, "display_" .. tbl_type)
  M.add_content_to_buffer(buf, lines)
  M.open_window(buf, lines)
end

function M.split_buffer()
  vim.cmd "vsplit"
end

function M.add_detour(t_type)
  if t_type == "full" then
    vim.cmd "Detour"
    return
  end
  vim.cmd "DetourCurrentWindow"
end

function M.add_content_to_buffer(buf, content)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
end

function M.open_metrics(content)
  local buf = M.make_buffer()
  M.set_buffer_ft(buf, "display")
  M.add_content_to_buffer(buf, content)
  M.set_buffer_option(buf, "modifiable", false)

  M.open_window(buf, content)
end

local add_line = function(tbl, line)
  table.insert(tbl, line)
end

function M.create_highlight(name, color)
  name = name or "DeusIDEIcon"
  color = color or "#8E1600"
  vim.api.nvim_set_hl(0, name, { fg = color, bg = "", bold = true })
end

local function get_char_at(buf, line, col)
  -- Ensure the column is valid
  if line < 0 then
    return nil
  end
  if col < 0 then
    return nil -- Return nil if the column is invalid
  end
  -- Get the character at the specified line and column
  local char = vim.api.nvim_buf_get_text(buf, line, col, line + 1, col + 1, {})[1]
  return char
end

function M.highlight_icons_in_buffer(buf, icon, highlight_group, condition)
  -- Get all lines in the buffer
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  -- Loop through each line
  for line_num, line in ipairs(lines) do
    -- Find the position of the icon in the line
    local start_col, end_col = string.find(line, icon, 1, true)
    if start_col and end_col then
      if condition(line_num - 1, start_col) then
        -- Apply the highlight to the icon
        vim.api.nvim_buf_add_highlight(buf, -1, highlight_group, line_num - 1, start_col, end_col)
      end
    end
  end
end

function M.plugin_info()
  local plugins = M.get_modules()
  local stats = {
    total = 0,
    added = 0,
    not_added = 0,
    loaded = 0,
    not_loaded = 0,
    lazy = 0,
    not_lazy = 0,
    type = { modules = 0, dependencies = 0 },
  }

  if plugins == nil then
    return stats
  end

  for _, plugin in pairs(plugins) do
    local name = plugin.base.name
    stats.total = stats.total + 1

    if plugin.base.type == "dependency" then
      stats.type.dependencies = stats.type.dependencies + 1
      goto continue
    end
    if plugin.base.type == "modules" then
      stats.type.modules = stats.type.modules + 1
    end
    if plugin.base.added then
      stats.added = stats.added + 1
    else
      stats.not_added = stats.not_added + 1
    end
    if plugin.base.loaded ~= nil and plugin.loaded then
      stats.loaded = stats.loaded + 1
    else
      stats.not_loaded = stats.not_loaded + 1
    end
    if plugin.config.lazy ~= nil and plugin.config.lazy then
      stats.lazy = stats.lazy + 1
    else
      stats.not_lazy = stats.not_lazy + 1
    end
    ::continue::
  end
  return stats
end

local function center_line(line, columns)
  local width = columns
  local content_width = vim.fn.strdisplaywidth(line)
  local padding = math.floor((width - content_width) / 2)
  local left_pad = string.rep(" ", padding)
  local right_pad = string.rep(" ", width - content_width - padding)
  return left_pad .. line .. right_pad
end

local function add_line_center(tbl, line, columns)
  if tbl ~= nil and line ~= nil then
    local f_line = center_line(line, columns)
    table.insert(tbl, f_line)
  end
end

function M.get_module_stats()
  local icons = require "base.ui.icons"
  local modules = M.get_modules()

  local stats = {
    total = 0,
    added = 0,
    not_added = 0,
    loaded = 0,
    not_loaded = 0,
    lazy = 0,
    not_lazy = 0,
    type = { modules = 0, dependencies = 0 },
  }

  if modules ~= nil then
    for _, module in pairs(modules) do
      local mod_type = module.base.type
      if mod_type == "module" then
        stats.type.modules = stats.type.modules + 1
      elseif mod_type == "dependency" then
        stats.type.dependencies = stats.type.dependencies + 1
        goto continue
      end
      stats.total = stats.total + 1
      if module.base.added then
        stats.added = stats.added + 1
      else
        stats.not_added = stats.not_added + 1
      end
      if module.base.loaded then
        stats.loaded = stats.loaded + 1
      else
        stats.not_loaded = stats.not_loaded + 1
      end
      if module.config.lazy then
        stats.lazy = stats.lazy + 1
      else
        stats.not_lazy = stats.not_lazy + 1
      end
      ::continue::
    end
  end
  return stats
end

local function get_module_config(name)
  local module = Modules:get_module_by_name(name)

  if module == nil then
    error "A module was selected that does not exist! Investigate...."
    return
  end

  local mod_base = module.base
  local mod_add = module.add
  local mod_config = module.config

  local name = mod_base.name
  local order = mod_base.id
  local mod_type = mod_base.type

  local lines = {}

  local create_title = function(title, icon)
    local icons = require "base.ui.icons"
    local icon = icons.icon ~= nil and icons.icon or icons.lazy.keys
    return string.format("%s %s", icon, title)
  end

  local sub_title = function(title)
    return string.format("%s", title)
  end

  local separator = function(length)
    return string.rep("-", length)
  end

  -- Add content to lines table instead of using newlines in strings
  table.insert(lines, create_title(name, nil))
  table.insert(lines, string.format("Name: %s", name))
  table.insert(lines, string.format("Order: %d", order))
  table.insert(lines, string.format("Type: %s", mod_type))
  table.insert(lines, separator(50))

  if mod_base then
    table.insert(lines, sub_title "Base Config")
    for key, value in pairs(mod_base) do
      if key == "name" or key == "id" or key == "type" then
        goto continue
      end
      if type(value) == "table" then
        table.insert(lines, string.format("%s:", key))
        for k, v in pairs(value) do
          table.insert(lines, string.format("  %s: %s", k, tostring(v)))
        end
      elseif type(value) == "function" then
        table.insert(lines, string.format("%s: %s", key, vim.inspect(value)))
      else
        table.insert(lines, string.format("%s: %s", key, tostring(value)))
      end
      ::continue::
    end
    table.insert(lines, separator(50))
  end

  if mod_add then
    table.insert(lines, sub_title "Register Config")
    for key, value in pairs(mod_add) do
      table.insert(lines, string.format("%s: %s", key, tostring(value)))
    end
    table.insert(lines, separator(50))
  end

  if mod_config then
    table.insert(lines, sub_title "Setup Config")
    for key, value in pairs(mod_config) do
      if type(value) == "table" then
        table.insert(lines, string.format("%s:", key))
        for k, v in pairs(value) do
          table.insert(lines, string.format("  %s: %s", k, tostring(v)))
        end
      elseif type(value) == "function" then
        table.insert(lines, string.format("%s: %s", key, vim.inspect(value)))
      else
        table.insert(lines, string.format("%s: %s", key, tostring(value)))
      end
    end
    table.insert(lines, separator(50))
  end
  return lines
end

local function get_module_content(columns)
  local icons = require "base.ui.icons"
  local plugins = M.get_modules()
  local stats = M.get_module_stats()
  local the_icon = {
    added = icons.ui.Check,
    not_added = string.format("%s%s", "!", icons.ui.Check),
    loaded = icons.common.lock,
    not_loaded = string.format("%s%s", "!", icons.common.lock),
    lazy = icons.lazy.lazy,
    not_lazy = string.format("%s%s", "!", icons.lazy.lazy),
    order = icons.Run,
    not_order = string.format("%s%s", "!", icons.Run),
  }

  local lines = {}

  if plugins ~= nil then
    local dotted_line = string.rep("-", columns)
    local blank_line = string.rep(" ", columns)
    local Headline = string.format("%s", "The Plugins")
    local Title = string.format("%-10s %-50s %-20s %-40s %-20s", "Order", "Source", "Type", "Load Type", "State")
    local STitle1 = string.format("%s %s %s", the_icon.order, "->", "id & load matches")
    local STitle2 = string.format("%s %s %s", the_icon.added, "->", "added to session")
    local STitle3 = string.format("%s %s %s", the_icon.loaded, "->", "loaded configuration")
    local STitle4 = string.format("%s %s %s", the_icon.lazy, "->", "lazy loaded")
    local STitle5 = string.format("%s %s %s", "!", "->", "opposite of (aka NOT)")

    add_line_center(lines, Headline, columns)
    add_line(lines, dotted_line)
    add_line_center(lines, STitle1, columns)
    add_line_center(lines, STitle2, columns)
    add_line_center(lines, STitle3, columns)
    add_line_center(lines, STitle4, columns)
    add_line_center(lines, STitle5, columns)
    add_line(lines, dotted_line)
    add_line_center(lines, Title, columns)
    add_line(lines, dotted_line)

    for id, plugin in pairs(plugins) do
      local mod_type = plugin.base.type
      if mod_type == "module" then
      elseif mod_type == "dependency" then
      end
      local source = plugin.base.source
      local in_order = plugin.base.id == id and the_icon.order or the_icon.not_order
      local is_added = plugin.base.added and the_icon.added or the_icon.not_added
      if plugin.base.added then
      else
      end
      local is_loaded = plugin.base.loaded and the_icon.loaded or the_icon.not_loaded
      if plugin.base.loaded then
      else
      end
      local is_lazy = nil
      local is_event = nil
      local is_cmd = nil
      local is_ft = nil
      
      if plugin.base.event ~= nil then
        is_event = string.format(
          "%s %s",
          icons.ui.Electric,
          type(plugin.base.event) == "table" and table.concat(plugin.base.event, "-") or tostring(plugin.base.event)
        )
      elseif plugin.base.cmd ~= nil then
        is_cmd = type(plugin.base.cmd) == "table" and table.concat(plugin.base.cmd, "-") or tostring(plugin.base.cmd)
      elseif plugin.base.ft ~= nil then
        is_ft = type(plugin.base.ft) == "table" and table.concat(plugin.base.ft, "-") or tostring(plugin.base.ft)
      elseif plugin.base.lazy then
        is_lazy = the_icon.lazy
      end

      local load_type = is_event ~= nil and "Evt: " .. is_event or is_cmd ~= nil and "Cmd: " .. is_cmd ~= nil or
          is_ft ~= nil and "Ft: " .. is_ft or is_lazy ~= nil and "Lazy" or "Immediate"
      if plugin.base.lazy then
      else
      end

      local id_line = string.format("%s%-3d %s", "#", id, in_order)
      local name_line = string.format("%-50s %-20s", source, mod_type)
      local sub_line = string.format("%-6s %-6s %-6s", is_added, is_loaded, is_lazy)
      local load_type_line = string.format("%s", load_type)
      local line = string.format("%-10s %-70s %-40s %-20s", id_line, name_line, load_type_line, sub_line)

      add_line_center(lines, line, columns)
      add_line(lines, dotted_line)
    end

    add_line_center(lines, blank_line, columns)
    add_line_center(lines, string.format("%-20s %3d", "Total Modules:", stats.total), columns)
    add_line_center(lines, string.format("%-20s %3d", "Added Modules:", stats.type.modules), columns)
    add_line_center(lines, string.format("%-20s %3d", "Added Dependencies:", stats.type.dependencies), columns)
    add_line_center(lines, string.format("%-20s %3d", "Not Added:", stats.not_added), columns)
    add_line_center(lines, string.format("%-20s %3d", "Loaded Modules:", stats.loaded), columns)
    add_line_center(lines, string.format("%-20s %3d", "Not Loaded:", stats.not_loaded), columns)
    add_line_center(lines, string.format("%-20s %3d", "Lazy Modules:", stats.lazy), columns)
    add_line_center(lines, string.format("%-20s %3d", "Not Lazy:", stats.not_lazy), columns)
    add_line_center(
      lines,
      string.format("%-20s %3d", "Grand Total (M+D)", stats.type.modules + stats.type.dependencies),
      columns
    )
    add_line_center(lines, blank_line, columns)
  end
  return lines
end

function M.show_module_info(name)
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines
  local win_width = math.floor(editor_width * 0.9)         -- Use 90% of the editor width
  local win_height = math.floor(editor_height * 0.8)       -- Use 80% of the editor height
  local row = math.floor((editor_height - win_height) / 2) -- Center vertically
  local col = math.floor((editor_width - win_width) / 2)   -- Center horizontally

  -- Window options
  local opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = "Module " .. name .. " info",
    title_pos = "center",
  }

  -- Create buffer and populate content
  local buf = M.make_buffer()
  M.set_buffer_ft(buf, "display_module_info")
  local content = get_module_config(name) -- Pass the dynamic width for proper formatting
  M.open_window(buf, content, opts)
end

local function show_plugin_info()
  -- Dynamically calculate window size based on editor dimensions
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines
  local win_width = math.floor(editor_width * 0.9)         -- Use 90% of the editor width
  local win_height = math.floor(editor_height * 0.8)       -- Use 80% of the editor height
  local row = math.floor((editor_height - win_height) / 2) -- Center vertically
  local col = math.floor((editor_width - win_width) / 2)   -- Center horizontally

  -- Window options
  local opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Plugin Metrics ",
    title_pos = "center",
  }

  -- Create buffer and populate content
  local buf = M.make_buffer()
  M.set_buffer_ft(buf, "display_plugins")
  local content = get_module_content(win_width, buf) -- Pass the dynamic width for proper formatting
  M.open_window(buf, content, opts)
end

function M.get_load_state()
  local load_state = M.get_module_stats()
  if load_state == nil then
    return {}
  end
  local total_modules = load_state.type.modules
  local total_dependencies = load_state.type.dependencies
  local added = load_state.added
  local not_added = load_state.not_added
  local loaded = load_state.loaded
  local not_loaded = load_state.not_loaded
  local lazy = load_state.lazy
  local not_lazy = load_state.not_lazy
  local total = load_state.total

  return {
    total_modules = total_modules,
    total_dependencies = total_dependencies,
    added = added,
    not_added = not_added,
    loaded = loaded,
    not_loaded = not_loaded,
    lazy = lazy,
    not_lazy = not_lazy,
    total = total,
  }
end

vim.api.nvim_create_user_command("ShowPluginInfo", function()
  show_plugin_info()
end, { nargs = 0 })

vim.api.nvim_create_user_command("DisplayglobalJson", function()
  return M.display_global(true, false, false, "json")
end, {
  desc = "global: Current state json ",
})
vim.api.nvim_create_user_command("DisplayglobalIndent", function()
  return M.display_global(true, false, false, "indent")
end, {
  desc = "global: Current state indent ",
})
vim.api.nvim_create_user_command("DisplayglobalTab", function()
  return M.display_global(true, false, false, "tab")
end, {
  desc = "global: Current state tab",
})

vim.api.nvim_create_user_command("Displayglobal", function()
  return M.display_global(true, false, false)
end, {
  desc = "global: Current state tab",
})

vim.api.nvim_create_user_command("ModuleStats", function()
  return M.get_module_stats()
end, {
  desc = "global: Current module stats ",
})

vim.api.nvim_create_user_command("ModuleInfo", function(opts)
  return M.show_module_info(opts.args)
end, {
  nargs = 1,
  desc = "Show module info",
})

vim.api.nvim_create_user_command("LoadState", function()
  return M.get_load_state()
end, {
  desc = "Get the load state of plugins",
})

return M
--End-of-file--
