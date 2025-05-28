--Start-of-file--
local M = {}
local module_configs = require("configs.modules")

-- Constants
local MODULE_FILES = {
  'start',
  'core',
  'window',
  'diff',
  'lsp',
  'completion',
  'ai',
  'ui',
  'ui.heirline',
  'editing',
  'coding',
  'utility',
  'test',
}

-- State Management
local state = {
  failed = {},     -- Tracks plugins that failed to load
  loaded = {},     -- Tracks successfully loaded plugins
  unresolved = {}, -- Plugins with unresolved dependencies
  file_stats = {}, -- Track statistics per file
  load_count = 0,  -- Load count (plugin)
  load_order = {}, -- Track module loading order
}

-- Validate the module shape
local function validate_file_module(module, file)
  if type(module) ~= 'table' then
    vim.notify(string.format('Module %s is not a table in file: %s', module.base.name, file), vim.log.levels.WARN)
    return false
  end
  
  -- Validate required fields
  if not module[1] then
    vim.notify(string.format('Module missing source in file: %s', file), vim.log.levels.WARN)
    return false
  end
  
  return true
end

-- File Management
local function pre_init(file)
  Global.files[file] = Global.files[file] or {}
  state.file_stats[file] = {
    start_time = vim.uv.hrtime(),
    module_count = 0,
    success_count = 0,
    fail_count = 0
  }
end

-- Post init
local function post_init(file)
  local stats = state.file_stats[file]
  local duration = (vim.uv.hrtime() - stats.start_time) / 1e6

  Debug.log(string.format(
    'File Loaded: %s with %d %s in %.2f ms',
    file,
    stats.module_count,
    stats.module_count > 1 and 'plugins' or 'plugin',
    duration
  ), 'modules')
end

-- Module Loading
local function load_file_modules(file)
  local funcs = require("core.funcs")
  local modules = funcs.safe_require('modules.' .. file)
  if not modules then
    Debug.log(string.format('No modules found in file: %s', file), 'modules', 'WARN')
    return {}
  end

  local stats = state.file_stats[file]

  for _, module in ipairs(modules) do
    stats.module_count = stats.module_count + 1

    if not validate_file_module(module, file) then
      stats.fail_count = stats.fail_count + 1
      Debug.log(string.format('Invalid module in file %s: %s', file, vim.inspect(module)), 'modules', 'ERROR')
      goto continue
    end

    local Mod = module_configs.handle_register_module(module, 'module', file, state)
    if not Mod then
      Debug.log(string.format('Failed to register module in file %s: %s', file, vim.inspect(module)), 'modules', 'ERROR')
      stats.fail_count = stats.fail_count + 1
      goto continue
    end

    local setup_ok = module_configs.handle_setup_module(Mod, state.load_count, state.failed)
    if setup_ok then
      stats.success_count = stats.success_count + 1
      state.loaded[Mod.base.name] = true
      Debug.log(string.format('Successfully setup module: %s', Mod.base.name), 'modules', 'INFO')
    else
      stats.fail_count = stats.fail_count + 1
      Debug.log(string.format('Failed to setup module: %s', Mod.base.name), 'modules', 'ERROR')
    end

    ::continue::
  end

  return true
end

-- Issue Reporting
function M.report_issues()
  -- Report unresolved dependencies
  if #state.unresolved > 0 then
    local msg = "Warning: Unresolved dependencies:\n"
    for _, entry in ipairs(state.unresolved) do
      msg = msg .. string.format('- %s (missing: %s)\n',
        entry.module.source,
        table.concat(entry.missing, ', '))
    end
    vim.notify(msg, vim.log.levels.WARN)
  end

  -- Report failed modules
  if next(state.failed) then
    local msg = 'Error: Failed modules:\n'
    for source in pairs(state.failed) do
      msg = msg .. string.format('- %s\n', source)
    end
    vim.notify(msg, vim.log.levels.ERROR)
  end
end

-- Main Initialization
function M.init()
  Debug.log('Starting module initialization', 'modules')
  local start_time = vim.uv.hrtime()

  -- Verify required globals
  if not _G.Events then
    vim.notify('Event system not initialized', vim.log.levels.ERROR)
    return false
  end

  if not _G.MiniDeps then
    vim.notify('MiniDeps not initialized', vim.log.levels.ERROR)
    return false
  end

  -- Load modules
  for _, file in ipairs(MODULE_FILES) do
    Debug.log('Processing file: ' .. file, 'modules')

    pre_init(file)
    local ok, err = pcall(load_file_modules, file)
    if not ok then
      Debug.log(string.format('Failed to load file %s: %s', file, err), 'modules', 'ERROR')
      vim.notify(string.format('Failed to load file: %s', file), vim.log.levels.ERROR)
    end
    post_init(file)
  end

  -- Handle lazy loading
  Debug.log("Handling lazy loading", "modules")
  module_configs.setup_lazy_loading()

  -- Report issues
  M.report_issues()

  -- Calculate final statistics
  local duration = (vim.uv.hrtime() - start_time) / 1e6
  Debug.log(string.format('Module initialization completed in %.2f ms', duration), 'modules')

  return {
    loaded = state.load_count,
    failed = vim.tbl_count(state.failed),
    unresolved = #state.unresolved,
    total = #MODULE_FILES,
    duration = duration
  }
end

return { init = M.init }
--End-of-file--
