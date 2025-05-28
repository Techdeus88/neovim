local M = {}
local module_helpers = require('base.utils.modules')

-- Constants
local SETUP_PHASES = {
  {
    name = 'init',
    condition = function(c) return c.config and c.config.init end,
    action = function(c) c.config.init() end,
    timing = 'now'
  },
  {
    name = 'config',
    condition = function(c) return (c.config and c.config.config) or (c.config and c.config.opts) end,
    action = function(c)
      local merged_opts = M.merge_config(c.config)
      M.process_config(c, merged_opts)
    end,
    timing = 'dynamic'
  },
  {
    name = 'keys',
    condition = function(c) return c.base and c.base.keys end,
    action = function(c) module_helpers.set_module_keymaps(c.base.keys, c.base.name) end,
    timing = 'later'
  },
  {
    name = 'post',
    condition = function(c) return c.config and c.config.post end,
    action = function(c) c.config.post() end,
    timing = 'later'
  }
}

-- Configuration Processing
function M.merge_config(module_config)
  if not (module_config.config or module_config.opts) then return {} end

  local default_opts = type(module_config.opts) == 'table' and module_config.opts or {}
  local config_opts = type(module_config.config) == 'table' and module_config.config or {}

  return vim.tbl_deep_extend('force', default_opts, config_opts)
end

function M.process_config(Module, merged_opts)
  if type(Module.config.config) == 'function' then
    return Module.config.config(Module, merged_opts)
  elseif type(Module.config.config) == 'boolean' then
    return M.setup_with_boolean(Module, Module.config.config)
  elseif merged_opts then
    return M.setup_with_opts(Module, merged_opts)
  end
end

function M.validate_module_config(Module)
  if not Module.config then
    vim.notify('Module missing config', vim.log.levels.ERROR)
    return false
  end

  if Module.config.loaded then
    return false
  end

  return true
end

function M.setup_with_boolean(Module, opts)
  if type(Module.config == "boolean") then
    return opts
  end
end

function M.setup_with_opts(Module, opts)
  local mod_name = Module.config.require or Module.base.name
  local ok, mod = pcall(require, mod_name)
  if not ok then
    vim.notify(string.format('Failed to require plugin: ', Module.base.name), vim.log.levels.ERROR,
      { title = "Techdeus IDE Error" })
    return
  end
  return mod.setup(opts)
end

function M.setup_module(Module)
  -- Validate module configuration
  if not M.validate_module_config(Module) then return end

  -- Process setup phases
  for _, phase in ipairs(SETUP_PHASES) do
    if phase.condition(Module) then
      local timing_fn = module_helpers.get_timing_function(Module, phase)
      timing_fn(function()
      module_helpers.safe_pcall(phase.action, Module)
        Debug.log(string.format("Phase %s completed for %s", phase.name, Module.base.name), "modules")
      end)
    end
  end
end

function M.setup_event_loading(Module)
  if not Module.base.event then return false end

  for _, event in ipairs(Module.base.event) do
    Events:register_handler(event, {
      module_id = Module.base.id,
      handler = function(args)
        if Module.base.loaded then return end

        local bufnr = args.buf
        Debug.log(string.format("Event handler triggered: %s-%s-%s",
          Module.base.name, event, bufnr), "modules")

        local ok, err = pcall(M.setup_module, Module)
        if not ok then
          vim.notify(string.format('Error in event handler for %s: %s',
            Module.base.name, err), vim.log.levels.ERROR)
          return
        end

        Modules:make_loaded(Module.base.id)
        Debug.log(string.format("Module successfully loaded (event): %s-%s",
          Module.base.name, Module.base.id), "modules")
      end
    })
  end
  return true
end

function M.setup_filetype_loading(Module)
  if not Module.base.ft then return false end

  for _, filetype in ipairs(Module.base.ft) do
    Events:register_handler('FileType', {
      module_id = Module.base.id,
      ft = filetype,       -- Store the filetype for filtering
      handler = function(args)
        if Module.base.loaded then return end

        local bufnr = args.buf
        local buf_ft = vim.bo[bufnr].filetype

        if buf_ft == filetype then         -- Use the stored filetype
          local ok, err = pcall(M.setup_module, Module)
          if not ok then
            vim.notify(string.format('Error in filetype handler for %s: %s',
              Module.base.name, err), vim.log.levels.ERROR)
            return
          end

          Modules:make_loaded(Module.base.id)
          Debug.log(string.format("Module successfully loaded (filetype): %s-%s",
            Module.base.name, Module.base.id), "modules")
        end
      end
    })
  end
  return true
end

function M.setup_command_loading(Module)
  if not Module.base.cmd then
    return false
  end

  local is_loaded = false
  for _, cmd in ipairs(Module.base.cmd) do
    vim.api.nvim_create_user_command(cmd, function()
      if Module.base.loaded then
        return
      end
      local setup_ok, err = pcall(M.setup_module, Module)
      if not setup_ok then
        vim.notify(string.format('Error launching module via command %s: %s', cmd, err), vim.log.levels.ERROR)
      end
      Modules:make_loaded(Module.base.id)
      Debug.log(string.format("Module successfully loaded (command): %s-%s", Module.base.name, Module.base.id), "modules")
      vim.cmd(cmd)
    end, { desc = 'Load plugin: ' .. Module.base.id })
    is_loaded = true
  end

  return is_loaded
end

function M.setup_immediate_loading(Module)
  MiniDeps.now(function()
    if Module.base.loaded then
      return
    end
    if Module.base.lazy or Module.base.type == 'dependency' then
      Modules.deferred_modules[Module.base.id] = Module
      return
    end
    local ok, err = pcall(M.setup_module, Module)
    if not ok then
      vim.notify('Error launching module immediately: ' .. err, vim.log.levels.ERROR)
    end
    Modules:make_loaded(Module.base.id)
    Debug.log(string.format("Module successfully loaded (immediate): %s-%s", Module.base.name, Module.base.id), "modules")
  end)
end

function M.setup_lazy_loading()
  MiniDeps.later(function()
    for _, module in pairs(Modules.deferred_modules) do
      if not module.base.loaded then
        local ok, err = pcall(M.setup_module, module)
        if not ok then
          vim.notify('Error launching lazy module: ' .. err, vim.log.levels.ERROR)
        end
        module.base.loaded = true
        Modules:make_loaded(module.base.id)
        Debug.log(string.format("Module successfully loaded (lazy): %s-%s", module.base.name, module.base.id), "modules")
      end
    end
  end)
end

-- Setup and load all plugins, resolving dependencies and handling lazy loading
function M.handle_setup_module(Module, load_count, failed)
  if Module.base.processed or Module.base.loaded then
    return false
  end

  local is_event = M.setup_event_loading(Module)
  local is_ft = M.setup_filetype_loading(Module)
  local is_cmd = M.setup_command_loading(Module)

  if Module.base.type == 'dependency' or not (is_event or is_ft or is_cmd) then
    M.setup_immediate_loading(Module)
  end

  Modules:make_processed(Module.base.id)
  load_count = load_count + 1
  return true
end

function M.register_module(Module)
  local register_checks = {
    {
      condition = function(m)
        return (m.base.enabled == nil or m.base.enabled)
      end,
      message = 'Module is disabled and will not be included in this session',
    },
    {
      condition = function(m)
        return (m.base ~= nil and type(m.base.id) == 'number')
      end,
      message = string.format('Module %s: does not have a valid base/id with the appropriate types', Module.base.name),
    },
  }
  -- Validate module
  if not module_helpers.validate_module(Module, register_checks) then
    vim.notify('Module validation failed: ' .. Module.base.name, vim.log.levels.ERROR)
    return false
  end
  -- Add to Modules store
  Modules:add_module(Module)
  -- Add to current session
  local session_ok, _ = pcall(MiniDeps.add, Module.add) -- Add to session
  Debug.log(string.format("Module added to session: %s-%s", Module.base.name, Module.base.id), "modules")
  if not session_ok then
    vim.notify('Error adding module to session: ' .. Module.base.name, vim.log.levels.ERROR)
    return false
  end
  Modules:make_added(Module.base.id)
  Debug.log(string.format("Module marked as added: %s-%s", Module.base.name, Module.base.id), "modules")
  return true
end

-- Register a module and its dependencies
function M.handle_register_module(module, mod_type, file, stats, seen)
  seen = seen or {}
  local module = type(module) == 'string' and { module } or module
  local Module = Modules:create_format_module(module, mod_type)

  if seen[Module.base.name] then
    Debug.log(string.format('Module %s already registered, skipping', Module.base.name), 'modules', 'INFO')
    return Module
  end
  seen[Module.base.name] = true

  -- Handle dependencies first
  if Module.add and Module.add.depends then
    for _, dep in ipairs(Module.add.depends) do
      local dep_module = M.handle_register_module(dep, 'dependency', file, stats, seen)
      if not dep_module then
        Debug.log(string.format('Failed to register dependency %s for module %s', dep, Module.base.name), 'modules', 'ERROR')
        stats.fail_count = stats.fail_count + 1
        return nil
      end
    end
  end

  if Module ~= nil then
    local reg_ok, err = pcall(M.register_module, Module)
    if not reg_ok then
      Debug.log(string.format('Error registering module %s: %s', Module.base.name, err), 'modules', 'ERROR')
      return nil
    end

    module_helpers.insert_moduleid_to_file(file, Module.base.id)
    Debug.log(string.format('Successfully registered module %s', Module.base.name), 'modules', 'INFO')
  end

  return Module
end

return M
--End-of-file--
