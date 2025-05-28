--Start-of-file-
local Debug = {}

-- Define debug levels
Debug.levels = {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
}

-- Function to parse debug environment variables
local function parse_debug_env()
  local debug_categories = {
    default = false, -- general debug messages
    modules = false,
    lsp = false, -- lsp-related debug messages
    dap = false, -- Debug Adapter Protocol (DAP) messages
    events = false, -- Event-related debug messages
    keymaps = false, -- Keymap-related debug messages
  }

  -- Get all environment variables
  local env_vars = vim.fn.environ()

  -- Look for debug-related environment variables
  for var, value in pairs(env_vars) do
    if var:match "^Debug_" then
      local category = var:gsub("^Debug_", ""):lower()
      if debug_categories[category] ~= nil then
        -- Convert string "true"/"false" to boolean
        debug_categories[category] = value:lower() == "true"
      end
    end
  end

  return debug_categories
end

-- Initialize debug categories from environment variables
Debug.categories = parse_debug_env()

-- Current debug level (can be adjusted dynamically)
Debug.current_level = Debug.levels.DEBUG

-- Log file path (optional)
Debug.log_file = vim.fn.stdpath "cache" .. "/debug.log"

-- Helper function to log messages to a file
local function log_to_file(msg, category, level)
  local log_entry = string.format("[%s] [%s] [%s]: %s\n", os.date "%Y-%m-%d %H:%M:%S", level, category, msg)
  local file = io.open(Debug.log_file, "a")
  if file then
    file:write(log_entry)
    file:close()
  end
end

-- Main debug function
---@param msg string The debug message
---@param category string The debug category (e.g., "lsp", "dap", "keymaps")
---@param level string The debug level (e.g., "DEBUG", "INFO", "WARN", "ERROR")
---@param log_to_disk boolean Whether to log the message to a file
function Debug.log(msg, category, level, show_notify, log_to_disk)
  category = category or "default"
  level = level or "DEBUG"
  show_notify = show_notify or true
  log_to_disk = log_to_disk or false

  -- Check if the category is enabled
  if not Debug.categories[category] then
    return
  end

  -- Check if the message level meets the current debug level
  local level_value = Debug.levels[level]
  if not level_value or level_value < Debug.current_level then
    return
  end

  -- Format the message
  local formatted_msg = string.format("[%s] [%s]: %s", category, level, msg)

  -- Display the message using vim.notify
  if show_notify then
    vim.notify(formatted_msg, vim.log.levels[level], { title = "Debug: " .. category, style = "minimal" })
  end
  -- Optionally log the message to a file
  if log_to_disk then
    log_to_file(msg, category, level)
  end
end

-- Function to dynamically set the debug level
---@param level string The debug level to set (e.g., "DEBUG", "INFO", "WARN", "ERROR")
function Debug.set_level(level)
  if Debug.levels[level] then
    Debug.current_level = Debug.levels[level]
    vim.notify("Debug level set to: " .. level, vim.log.levels.INFO, { title = "Debug" })
  else
    vim.notify("Invalid debug level: " .. level, vim.log.levels.ERROR, { title = "Debug" })
  end
end

-- Function to enable or disable a debug category
---@param category string The debug category to modify
---@param state boolean Whether to enable or disable the category
function Debug.set_category(category, state)
  if Debug.categories[category] ~= nil then
    Debug.categories[category] = state
    local status = state and "enabled" or "disabled"
    vim.notify("Debug category '" .. category .. "' " .. status, vim.log.levels.INFO, { title = "Debug" })
  else
    vim.notify("Invalid debug category: " .. category, vim.log.levels.ERROR, { title = "Debug" })
  end
end

-- Function to get current debug settings
function Debug.get_settings()
  return {
    categories = Debug.categories,
    current_level = Debug.current_level,
    log_file = Debug.log_file,
  }
end

-- Add to your init.lua or a debug file
function Debug.debug_events()
  local status = {
    BaseDefered = Events:get_event_status "User BaseDefered",
    BaseFile = Events:get_event_status "User BaseFile",
    BaseGitFile = Events:get_event_status "User BaseGitFile",
  }
  Debug.log(vim.inspect(status), "default", "INFO", false, true)
end

local setup_debug_manager = function()
  _G.Debug = Debug
end

local function init()
  setup_debug_manager()
end

return { init = init }
--End-of-file--
