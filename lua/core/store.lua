--Start-of-file--
local Module = {}
Module.__index = Module

-- Create a new module instance
function Module:new(mod, id, type)
  return setmetatable({ mod = mod, id = id, type = type }, self)
end

function Module:normalize_module_types()
  -- Normalize event, ft, and cmd to always be tables
  local function to_table(value)
    if type(value) == "string" then
      return { value }
    elseif type(value) == "table" then
      return value
    end
    return nil
  end

  if self.base.event then
    local updated_event_tbl = to_table(self.base.event) or nil
    self.base.event = updated_event_tbl
  end
  if self.base.ft then
    local updated_ft_tbl = to_table(self.base.ft) or nil
    self.base.ft = updated_ft_tbl
  end
  if self.base.cmd then
    local updated_cmd_tbl = to_table(self.base.cmd) or nil
    self.base.cmd = updated_cmd_tbl
  end
  return self
end


-- Format the base structure of a module
function Module:format_base(mod, id, type)
  local module_helpers = require('base.utils.modules')
  local F_mod = vim.deepcopy(mod)
  local source = F_mod[1]
  F_mod[1] = nil
  local name = module_helpers.split_plugin_name(source)
  if type == 'dependency' then
    local _, dep_require = module_helpers.split_plugin_name_to_require(source)
    dep_require = string.lower(dep_require)
    F_mod.require = dep_require
    F_mod.lazy = true
  end
  F_mod.name = name
  F_mod.path = module_helpers.get_plugin_path(name)
  F_mod.enabled = mod.enabled ~= nil and mod.enabled or true
  F_mod.source = source
  F_mod.id = id
  F_mod.type = type
  F_mod.added = false
  F_mod.loaded = false
  self.base = F_mod
  setmetatable(self.base, self)
  -- return F_mod
end

-- Format the "add" structure of a module
function Module:format_add()
  local a_module = {}
  a_module.name = self.base.name
  a_module.source = self.base.source
  a_module.depends = self.base.depends
  a_module.hooks = self.base.hooks
  a_module.checkout = self.base.checkout
  a_module.monitor = self.base.monitor
  self.add = a_module
  setmetatable(self.add, self)
end

-- Format the "config" structure of a module
function Module:format_config()
  local c_module = {}
  c_module.name = self.base.name
  c_module.cmd = self.base.cmd
  c_module.config = self.base.config
  c_module.event = self.base.event
  c_module.ft = self.base.ft
  c_module.init = self.base.init
  c_module.keys = self.base.keys
  c_module.lazy = self.base.lazy
  c_module.opts = self.base.opts
  c_module.post = self.base.post
  c_module.require = self.base.require
  self.config = c_module
  setmetatable(self.config, self)
end

-- Create a new module and format its structures
local function create_module(mod, order, type)
  local instance = Module:new(mod, order, type)
  -- instance.base = instance:format_base(mod, order, type)
  instance:format_base(mod, order, type)
  instance:normalize_module_types()
  instance:format_add()
  instance:format_config()
  return instance
end

-- Module manager to handle multiple modules
local module_manager = {
  modules = {},
  deferred_modules = {},
  cache = {
    names = {},
  },
  order = 0,
}

-- Create and format a new module
function module_manager:create_format_module(mod, type)
  self.order = self.order + 1
  local f_module = create_module(mod, self.order, type)
  return f_module
end

-- Add a module to the manager
function module_manager:add_module(Module)
  if not Module then
    vim.notify('Cannot add a nil module', vim.log.levels.ERROR)
    return
  end

  if not self.cache.names[Module.base.name] then
    self.modules[Module.base.id] = Module
    self.cache.names[Module.base.name] = Module.base.id
  end
end

function module_manager:get_module(id)
  return self.modules[id] or {}
end

function module_manager:get_value_from_attribute(id, attr)
  local module = self:get_module(id)
  if not module then
    return nil
  end
  local value = module.base[attr]
  if not value then
    return nil
  end
  return value
end

function module_manager:get_module_by_name(name)
  local id = self.cache.names[name]
  if id then
    return self:get_module(id)
  end
  return nil
end

function module_manager:get_modules()
  return self.modules
end

function module_manager:setup_modules()
  return module_manager
end


function module_manager:module_update(id, attr, value)
  local module = self:get_module(id)
  if not module then
    Debug.log(string.format('Cannot update non-existent module with id: %s', id), 'modules', 'ERROR')
    return false
  end

  -- Update the module's base attribute
  if module.base then
    module.base[attr] = value
    Debug.log(string.format('Updated module %s: %s = %s', module.base.name, attr, tostring(value)), 'modules', 'INFO')
    return true
  end

  Debug.log(string.format('Module %s has no base structure', id), 'modules', 'ERROR')
  return false
end

function module_manager:make_added(id)
  return self:module_update(id, 'added', true)
end

function module_manager:make_loaded(id)
  return self:module_update(id, 'loaded', true)
end

function module_manager:make_processed(id)
  return self:module_update(id, 'processed', true)
end

local setup_modules = function()
  local manager = module_manager:setup_modules()
  _G.Modules = manager -- Only global access if absolutely necessary
end

local function setup_load_system()
  local function safe_trigger_event(event, args)
    local handlers = Events:get_handlers(event)
    if not handlers then
      return
    end

    for _, entry in ipairs(handlers) do
      if not entry.event_data.module_id then
        goto continue
      end
      local module = module_manager:get_module(entry.event_data.module_id)
      if not module then
        goto continue
      end
      if module.loaded then
        goto continue
      end
      local ok, err = pcall(entry.event_data.handler, args)
      if not ok then
        vim.notify(
          string.format('Handler failed for %s on event %s: %s', module.name, event, err),
          vim.log.levels.ERROR
        )
      end
      ::continue::
    end
  end

  -- Create event groups for better organization
  local event_groups = {
    -- Buffer Events
    buffer = {
      'BufAdd',
      'BufDelete',
      'BufEnter',
      'BufLeave',
      'BufNew',
      'BufNewFile',
      'BufRead',
      'BufReadPost',
      'BufReadPre',
      'BufUnload',
      'BufWinEnter',
      'BufWinLeave',
      'BufWrite',
      'BufWritePre',
      'BufWritePost',
    },

    -- File Events
    file = {
      'FileType',
      'FileReadCmd',
      'FileWriteCmd',
      'FileAppendCmd',
      'FileAppendPost',
      'FileAppendPre',
      'FileChangedShell',
      'FileChangedShellPost',
      'FileReadPost',
      'FileReadPre',
      'FileWritePost',
      'FileWritePre',
    },

    -- Window Events
    window = {
      'WinClosed',
      'WinEnter',
      'WinLeave',
      'WinNew',
      'WinScrolled',
    },

    -- Terminal Events
    terminal = {
      'TermOpen',
      'TermClose',
      'TermEnter',
      'TermLeave',
      'TermChanged',
    },

    -- Tab Events
    tab = {
      'TabEnter',
      'TabLeave',
      'TabNew',
      'TabNewEntered',
    },

    -- Text Events
    text = {
      'TextChanged',
      'TextChangedI',
      'TextChangedP',
      'TextYankPost',
    },

    -- Insert Mode Events
    insert = {
      'InsertChange',
      'InsertCharPre',
      'InsertEnter',
      'InsertLeave',
    },

    -- Vim Lifecycle Events
    vim = {
      'VimEnter',
      'VimLeave',
      'VimLeavePre',
      'VimResized',
    },

    -- Custom Events
    custom = {
      'BaseDefered',
      'BaseFile',
      'BaseGitFile',
      'TechdeusStart',
      'TechdeusReady',
      'DashboardUpdate',
    },
  }

  -- Register events by group
  for group_name, events in pairs(event_groups) do
    local group = vim.api.nvim_create_augroup('Store' .. group_name, { clear = true })
    for _, event in ipairs(events) do
      if group_name == 'custom' then
        -- Register with both systems
        Events:register_handler(event, { handler = function(args)
          safe_trigger_event(event, args)
        end })

        vim.api.nvim_create_autocmd('User', {
          group = group,
          pattern = event,
          callback = function(args)
            safe_trigger_event(event, args)
          end,
        })
      else
        vim.api.nvim_create_autocmd(event, {
          group = group,
          pattern = event == 'FileType' and '*' or nil,
          callback = function(args)
            safe_trigger_event(event, args)
          end,
        })
      end
    end
  end
end

local function init()
  setup_modules()
  setup_load_system()
end

return { init = init }
--End-of-file--
