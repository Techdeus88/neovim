--Start-of-file
local vim = vim
local uv = vim.loop
local api = vim.api
local lsp = vim.lsp

local lang_configs = require('configs.languages')

_G.lsp_clients_by_root = setmetatable(_G.lsp_clients_by_root or {}, { __mode = "k" })
_G.lsp_disabled_servers = _G.lsp_disabled_servers or {}
_G.lsp_disabled_for_buffer = setmetatable(_G.lsp_disabled_for_buffer or {}, { __mode = "K" })
_G.formatters_linters_for_buffer = _G.formatters_linters_for_buffer or {}

local LSP = {}

-- Constants for better maintainability
local CONSTANTS = {
  CACHE_TTL = 300, -- 5 minutes
  MAX_CACHE_SIZE = 1000,
  ROOT_PATTERN_DEFAULT = { '.git' },
  DEBOUNCE_TIME = 100, -- ms
}

-- Enhanced caching system with proper error handling and documentation
---Create a new cache instance
---@param ttl number? Time to live in seconds
---@return table Cache instance
-- Current implementation
local Cache = {}
function Cache:new(ttl)
  local instance = {
    data = setmetatable({}, { __mode = "k" }),
    timestamps = setmetatable({}, { __mode = "k" }), -- Make timestamps weak too
    ttl = ttl or CONSTANTS.CACHE_TTL,
    size = 0,
    max_size = CONSTANTS.MAX_CACHE_SIZE
  }
  -- Use a more efficient cleanup strategy
  instance.cleanup_timer = vim.loop.new_timer()
  instance.cleanup_timer:start(60000, 60000, function() -- Run every minute
    instance:cleanup()
  end)
  return setmetatable(instance, { __index = Cache })
end

---Get value from cache
---@param self table Cache instance
---@param key string Cache key
---@return any|nil Cached value or nil
function Cache:get(key)
  -- Debug log the get operation
  Debug.log(string.format("Cache get called with key: %s", key), "lsp", "INFO")
  assert(type(key) == 'string', 'key must be a string')
  local timestamp = self.timestamps[key]
  if timestamp and (os.time() - timestamp) < self.ttl then
    return self.data[key]
  end
  return nil
end

---Set value in cache
---@param self table Cache instance
---@param key string Cache key
---@param value any Value to cache
---@return boolean Success status
function Cache:set(key, value)
  -- Debug log the set operation
  Debug.log(string.format("Cache set called with key: %s", key), "lsp", "INFO")
  assert(type(key) == 'string', 'key must be a string')
  local ok, err = pcall(function()
    self.data[key] = value
    self.timestamps[key] = os.time()
    self.size = self.size + 1
    self:cleanup()
  end)
  if not ok then
    Debug.log('Cache set error: ' .. tostring(err), 'lsp', 'ERROR')
    return false
  end
  return true
end

---Clean up old cache entries
---@param self table Cache instance
function Cache:cleanup()
  local now = os.time()
  local count = 0
  for key, timestamp in pairs(self.timestamps) do
    if (now - timestamp) >= self.ttl or count > CONSTANTS.MAX_CACHE_SIZE then
      self.data[key] = nil
      self.timestamps[key] = nil
      self.size = self.size - 1
      count = count + 1
    end
  end
end

-- Create single cache instance for the module
local function create_cache()
  local cache = Cache:new()
  -- Verify the cache instance has the required methods
  assert(cache.get, "Cache instance missing get method")
  assert(cache.set, "Cache instance missing set method")
  assert(cache.cleanup, "Cache instance missing cleanup method")
  return cache
end

local capability_cache = create_cache()
local root_pattern_cache = create_cache()
local client_attachment_cache = create_cache()

-- More efficient caching with proper key generation
local function generate_cache_key(markers)
  table.sort(markers) -- Ensure consistent key generation
  return table.concat(markers, "|")
end

-- Enhanced client capability checking
function LSP.has_capability(client, capability)
  assert(type(client) == 'table', 'client must be a table')
  assert(type(capability) == 'string', 'capability must be a string')

  if not client or not capability then
    return false
  end

  local cache = capability_cache
  local cache_key = client.id .. ":" .. capability

  local cached_result = cache:get(cache_key)
  if cached_result ~= nil then
    return cached_result
  end

  local has_cap = client.server_capabilities[capability] ~= nil
  cache:set(cache_key, has_cap)
  return has_cap
end

-- Optimized root pattern detection
function LSP.root_pattern(...)
  local markers = { ... }
  local cache_key = generate_cache_key(markers)

  -- Use enhanced cache
  local cache = root_pattern_cache
  local cached_pattern = cache:get(cache_key)
  if cached_pattern then
    return cached_pattern
  end

  local pattern = function(startpath)
    if not startpath or #startpath == 0 then
      return nil
    end

    -- Use vim.fn.fnamemodify for more efficient path handling
    local path = vim.fn.fnamemodify(startpath, ':p')
    if vim.fn.isdirectory(path) == 0 then
      path = vim.fn.fnamemodify(path, ':h')
    end

    -- Use vim.fn.findfile for more efficient file searching
    for _, marker in ipairs(markers) do
      local found = vim.fn.findfile(marker, path .. ';')
      if found ~= '' then
        return vim.fn.fnamemodify(found, ':h')
      end
    end

    return nil
  end

  local ok, err = pcall(function()
    cache:set(cache_key, pattern)
  end)
  if not ok then
    Debug.log('Cache set error: ' .. tostring(err), 'lsp', 'ERROR')
  end
  return pattern
end

function LSP.safe_attach_client(bufnr, client_id)
  local ok, err = pcall(vim.lsp.buf_attach_client, bufnr, client_id)
  if not ok then
    Debug.log('Failed to attach client: ' .. tostring(err), 'lsp', 'ERROR')
    return false
  end
  return true
end

function LSP.is_real_file_buffer(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if not name or name == '' then
    return false
  end
  return name and name ~= ""
end

local function is_client_attached_to_buffer(client_id, bufnr)
  if not client_id or not bufnr then
    return false
  end

  local cache = client_attachment_cache
  local cache_key = client_id .. ":" .. bufnr

  local cached_result = cache:get(cache_key)
  if cached_result ~= nil then
    return cached_result
  end

  local client = vim.lsp.get_client_by_id(client_id)
  if not client then
    return false
  end

  local attached = false
  pcall(function()
    for _, buf_id in ipairs(vim.lsp.get_buffers_by_client_id(client_id) or {}) do
      if buf_id == bufnr then
        attached = true
        break
      end
    end
  end)

  cache:set(cache_key, attached)
  return attached
end

LSP.is_server_disabled_globally = function(server_name)
  return _G.lsp_disabled_servers[server_name] == true
end

LSP.is_server_disabled_for_buffer = function(server_name, bufnr)
  return _G.lsp_disabled_for_buffer[bufnr] and _G.lsp_disabled_for_buffer[bufnr][server_name] == true
end

LSP.is_lsp_compatible_with_ft = function(server_name, ft)
  if not ft or ft == '' then
    return false
  end
  if not Global.file_types or not Global.file_types[server_name] then
    return false
  end
  return Global.file_types and Global.file_types[server_name] and vim.tbl_contains(Global.file_types[server_name], ft)
end

LSP.get_compatible_lsp_for_ft = function(ft)
  if not ft or ft == '' then
    return {}
  end
  local compatible_servers = {}
  for server_name, filetypes in pairs(Global.file_types or {}) do
    if vim.tbl_contains(filetypes, ft) then
      table.insert(compatible_servers, server_name)
    end
  end
  -- TODO: get all formatters and linters for Buffer/LSP combo or create a separate method
  return compatible_servers
end

-- Enhanced LSP server management
function LSP.ensure_lsp_for_buffer(server_name, bufnr)
  Debug.log(string.format("Ensuring the server (%s) for buffer %s", server_name, bufnr), "lsp")
  if not LSP.is_real_file_buffer(bufnr) then
    return nil
  end

  -- Check server status
  if LSP.is_server_disabled_globally(server_name) or
      LSP.is_server_disabled_for_buffer(server_name, bufnr) then
    Debug.log(string.format("Server %s is disabled globally", server_name), 'lsp')
    return nil
  end

  local ft = vim.bo[bufnr].filetype
  if not LSP.is_lsp_compatible_with_ft(server_name, ft) then
    Debug.log(string.format("Server %s not compatible with filetype %s", server_name, ft), 'lsp')
    return nil
  end

  -- Load server configuration
  local ok, mod = pcall(require, 'languages.base.lsp.' .. server_name)
  Debug.log(vim.inspect(mod), "lsp", "INFO")
  -- Debuglog(string.format("Server module found: %s", mod.config.name), "lsp", INFO)

  if not ok or type(mod) ~= 'table' or not mod.config then
    return nil
  end
  Debug.log(string.format("Server module passes validation: %s", mod.config.name), "lsp")
  -- Get root directory
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local patterns = mod.root_patterns or CONSTANTS.ROOT_PATTERN_DEFAULT
  local finder = LSP.root_pattern(unpack(patterns))
  local root_dir = finder(fname) or vim.loop.cwd()
  -- Check existing client
  local client_id = _G.lsp_clients_by_root[server_name] and
      _G.lsp_clients_by_root[server_name][root_dir]

  if client_id then
    local client = vim.lsp.get_client_by_id(client_id)
    if client and not is_client_attached_to_buffer(client_id, bufnr) then
      local ok, err = pcall(vim.lsp.buf_attach_client, bufnr, client_id)
      if not ok then
        Debug.log('Failed to attach client: ' .. tostring(err), 'lsp', 'ERROR')
        return nil
      end
      if type(mod.config) == 'table' and type(mod.config.on_attach) == 'function' then
        pcall(mod.config.on_attach, client, bufnr)
      end
      return client_id
    end
  end

  -- Start new client
  local config = (type(mod.config) == 'function') and mod.config() or vim.deepcopy(mod.config)
  if not config then
    return nil
  end

  config.root_dir = root_dir
  local new_client_id = vim.lsp.start({
    name = config.name or server_name,
    cmd = config.cmd,
    root_dir = config.root_dir,
    settings = config.settings,
    init_options = config.init_options,
    capabilities = config.capabilities,
    on_attach = function(client, attached_bufnr)
      if attached_bufnr == bufnr and config.on_attach then
        pcall(config.on_attach, client, attached_bufnr)
      end
    end,
  }, {
    bufnr = bufnr,
  })

  if new_client_id then
    _G.lsp_clients_by_root[server_name] = _G.lsp_clients_by_root[server_name] or {}
    _G.lsp_clients_by_root[server_name][root_dir] = new_client_id
    lang_configs.add_lsp(ft, config)
    return new_client_id
  end

  return nil
end

LSP.handle_add_linters = function(ft, linters)
  for _, linter in pairs(linters) do
    local l_name, l_config = linter[1], linter[2]
    assert(type(l_name) == 'string', 'Linter name must be a string')
    assert(type(l_config) == 'table', 'Linter config must be a table')
    lang_configs.add_linter(ft, l_name, l_config)
  end
end

LSP.handle_add_formatters = function(ft, formatters)
  for _, formatter in pairs(formatters) do
    local f_name, f_config = formatter[1], formatter[2]
    assert(type(f_name) == 'string', 'Formatter name must be a string')
    assert(type(f_config) == 'table', 'Formatter config must be a table')
  
    lang_configs.add_formatter(ft, f_name, f_config)
  end
end

LSP.safe_detach_client = function(bufnr, client_id)
  if not bufnr or bufnr <= 0 or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local client = vim.lsp.get_client_by_id(client_id)
  if not client then
    return false
  end

  if is_client_attached_to_buffer(client_id, bufnr) then
    pcall(function()
      vim.lsp.buf.clear_references()
      vim.lsp.buf_detach_client(bufnr, client_id)
    end)
    return true
  end
  return false
end

LSP.disable_lsp_server_globally = function(server_name)
  _G.lsp_disabled_servers[server_name] = true
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client.name == server_name then
      for _, bufnr in ipairs(vim.lsp.get_buffers_by_client_id(client.id) or {}) do
        if vim.api.nvim_buf_is_valid(bufnr) then
          LSP.safe_detach_client(bufnr, client.id)
        end
      end
      vim.lsp.stop_client(client.id, true)
    end
  end
  return true
end

LSP.disable_lsp_server_for_buffer = function(server_name, bufnr)
  if not _G.lsp_disabled_for_buffer[bufnr] then
    _G.lsp_disabled_for_buffer[bufnr] = {}
  end
  _G.lsp_disabled_for_buffer[bufnr][server_name] = true
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == server_name then
      LSP.safe_detach_client(bufnr, client.id)
      break
    end
  end
  return true
end

LSP.enable_lsp_server_globally = function(server_name)
  _G.lsp_disabled_servers[server_name] = nil
  return true
end

LSP.enable_lsp_server_for_buffer = function(server_name, bufnr)
  if _G.lsp_disabled_for_buffer[bufnr] then
    _G.lsp_disabled_for_buffer[bufnr][server_name] = nil
  end
  if LSP.is_server_disabled_globally(server_name) then
    return false
  end
  local ft = vim.bo[bufnr].filetype
  if ft and ft ~= '' and LSP.is_lsp_compatible_with_ft(server_name, ft) and LSP.is_real_file_buffer(bufnr) then
    local already_attached = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      if client.name == server_name then
        already_attached = true
        break
      end
    end
    if not already_attached then
      local client_id
      for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == server_name then
          client_id = client.id
          break
        end
      end
      if client_id then
        pcall(vim.lsp.buf_attach_client, bufnr, client_id)
      else
        client_id = LSP.ensure_lsp_for_buffer(server_name, bufnr)
      end
    end
  end
  return true
end

LSP.start_language_server = function(server_name, force)
  if _G.lsp_installation_in_progress then
    return nil
  end
  if not force and LSP.is_server_disabled_globally(server_name) then
    return nil
  end

  local function find_compatible_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if LSP.is_real_file_buffer(buf) then
        local buf_ft = vim.bo[buf].filetype
        if buf_ft ~= '' and LSP.is_lsp_compatible_with_ft(server_name, buf_ft) then
          return buf, buf_ft
        end
      end
    end
    return nil, nil
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  if not LSP.is_real_file_buffer(bufnr) or not LSP.is_lsp_compatible_with_ft(server_name, ft) then
    bufnr, ft = find_compatible_buf()
    if not bufnr or not LSP.is_real_file_buffer(bufnr) or not LSP.is_lsp_compatible_with_ft(server_name, ft) then
      if not force then
        return nil
      end
      bufnr = nil
    end
  end

  if not bufnr or not LSP.is_real_file_buffer(bufnr) then
    return nil
  end

  local client_id = LSP.ensure_lsp_for_buffer(server_name, bufnr)

  if force and client_id then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if buf ~= bufnr and LSP.is_real_file_buffer(buf) then
        local buf_ft = vim.bo[buf].filetype
        if buf_ft ~= '' and LSP.is_lsp_compatible_with_ft(server_name, buf_ft) then
          if not LSP.is_server_disabled_for_buffer(server_name, buf) then
            pcall(vim.lsp.buf_attach_client, buf, client_id)
          end
        end
      end
    end
  end
  return client_id
end

LSP.lsp_enable = function(server_name, _)
  local bufnr = vim.api.nvim_get_current_buf()
  return LSP.ensure_lsp_for_buffer(server_name, bufnr)
end

LSP.stop_servers_for_old_project = function()
  local current_dir = vim.fn.getcwd()
  local clients = vim.lsp.get_clients()
  local stopped_count = 0
  for _, client in ipairs(clients) do
    if client.config and client.config.root_dir then
      local client_root
      if type(client.config.root_dir) == 'function' then
        goto continue
      else
        client_root = tostring(client.config.root_dir)
      end
      if client_root ~= current_dir and not vim.startswith(client_root, current_dir) then
        vim.schedule(function()
          vim.lsp.stop_client(client.id, true)
        end)
        stopped_count = stopped_count + 1
      end
    end
    ::continue::
  end
  if stopped_count > 0 then
    vim.schedule(function()
      vim.notify(string.format('Stopped %d LSP servers from other projects.', stopped_count), vim.log.levels.INFO)
    end)
  end
  return stopped_count
end

LSP.set_installation_status = function(status)
  local previous_status = _G.lsp_installation_in_progress
  _G.lsp_installation_in_progress = status
  if status == false and previous_status == true then
    vim.defer_fn(function()
      local installed_servers = {}
      for _, server_name in ipairs(installed_servers) do
        vim.schedule(function()
          LSP.start_language_server(server_name, true)
        end)
      end
      vim.defer_fn(function()
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if LSP.is_real_file_buffer(bufnr) then
            local ft = vim.bo[bufnr].filetype
            if ft and ft ~= '' then
              local servers = LSP.get_compatible_lsp_for_ft(ft)
              for _, server_name in ipairs(servers) do
                if not LSP.is_server_disabled_globally(server_name) then
                  vim.schedule(function()
                    LSP.ensure_lsp_for_buffer(server_name, bufnr)
                  end)
                end
              end
            end
          end
        end
      end, 500)
    end, 1000)
  end
end

return LSP

-- local LSP_old = {}

-- LSP_old.dependencies_ready = true
-- LSP_old.ft = ''
-- LSP_old.installed_tools = {
--   lsp = {},
--   formatter = {},
--   linter = {},
--   debugger = {},
-- }

-- LSP_old.language = ''
-- LSP_old.lsp_to_start = {}
-- LSP_old.ordered_keys = {}
-- LSP_old.tools_to_install = {}

-- -- Install a package using the language installer
--  function LSP_old.install_package(p_data)
--   local ok, err = pcall(function()
--     lang_configs.language_installer(p_data)
--   end)
--   if not ok then
--     vim.notify(string.format('Error installing package: %s', err), vim.log.levels.ERROR)
--   end
-- end

-- -- Initialize LSP setup
-- function LSP_old.init(packages)
--   local ok, mr = funcs.safe_require('mason-registry')
--   if not ok then
--     return
--   end
--   -- Prevent infinite recursion if `Global.install_process` is true
--   if Global.install_process then
--     vim.defer_fn(function()
--       init(packages)
--     end, 500)
--     return
--   end

--   local has_lint, lint = pcall(require, 'lint')
--   local has_conform, conform = pcall(require, 'conform')

--   LSP.dependencies_ready = true
--   LSP.language = ''
--   LSP.ft = ''
--   LSP.ordered_keys = {}

--   -- Collect ordered keys from the packages table
--   for k in pairs(packages) do
--     -- Debug.notify(k)
--     table.insert(LSP.ordered_keys, k)
--   end

--   local order = { 'language', 'fts', 'formatters', 'linters', 'lsps', 'dap' }
--   -- Sort keys for consistent processing order
--   table.sort(LSP.ordered_keys, funcs.custom_sort(order))

--   -- Process each package
--   for _, key in ipairs(LSP.ordered_keys) do
--     local package_data = packages[key]
--     if package_data then
--       -- Add to the appropriate LSP-related table
--       if key == 'language' then
--         LSP.language = package_data
--       end
--       if key == 'fts' then
--         LSP.ft = package_data
--       end
--       if key == 'formatters' then
--         for formatter_name, formatter_config in pairs(package_data) do
--           if not mr.is_installed(formatter_name) then
--             Global.install_process = true
--             table.insert(LSP.formatters_to_install, formatter_name)
--           end

--           local ok, err = pcall(function()
--             lang_configs.add_formatter(LSP.ft, formatter_name, formatter_config)
--           end)
--           if not ok then
--             vim.notify(string.format('Error configuring formatter %s: %s', formatter_name, err), vim.log.levels.ERROR)
--           end
--         end
--       end
--       if key == 'linters' then
--         for linter_name, linter_config in pairs(package_data) do
--           if not mr.is_installed(linter_name) then
--             Global.install_process = true
--             table.insert(LSP.linters_to_install, linter_name)
--           end

--           local ok, err = pcall(function()
--             lang_configs.add_linter(LSP.ft, linter_name, linter_config)
--           end)
--           if not ok then
--             vim.notify(string.format('Error configuring formatter %s: %s', linter_name, err), vim.log.levels.ERROR)
--           end
--         end
--       end
--       if key == 'lsps' then
--         for lsp_name, lsp_config in pairs(package_data) do
--           if not mr.is_installed(lsp_name) then
--             Global.install_process = true
--             table.insert(LSP.servers_to_install, { lsp_name, lsp_config[1], lsp_config[2] })
--           end
--           local ok, err = pcall(function()
--             lang_configs.add_lsp(LSP.ft, lsp_config)
--           end)
--           if not ok then
--             vim.notify(string.format('Error configuring formatter %s: %s', lsp_name, err), vim.log.levels.ERROR)
--           end
--           table.insert(LSP.lsp_to_start, { lsp_name, lsp_config[1], lsp_config[2] })
--         end
--       end
--       if key == 'dap' then
--         table.insert(LSP.debuggers_to_install, package_data.dap)
--       end
--     else
--       vim.notify(string.format('Package data missing for key: %s', key), vim.log.levels.WARN)
--     end
--   end

--   vim.schedule(function()
--     vim.defer_fn(function()
--       -- Install the package
--       install_package(LSP)
--     end, 1000)
--   end)
-- end

-- function LSP_old.setup_language_servers(package_data)
--   local lspconfig = require('lspconfig')
--   local lsps = package_data.lsps
--   -- Check if the package data contains LSP servers
--   if lsps ~= nil then
--     for server_name, server_config in pairs(lsps) do
--       -- Ensure server name is a string
--       local s_name = tostring(server_config[1])
--       local s_config = server_config[2]

--       if s_name and lspconfig[s_name] then
--         local ok, err = pcall(function()
--           -- Debug.notify(string.format("Setting up LSP server: %s", s_name))
--           lspconfig[s_name].setup(s_config or {})

--           -- Only start if server exists in lspconfig
--           vim.defer_fn(function()
--             vim.cmd("LspStart " .. s_name)
--           end, 100)
--         end)

--         if not ok then
--           vim.notify(string.format("Error setting up LSP server %s: %s",
--             s_name, err), vim.log.levels.ERROR)
--         end
--       else
--         -- Debug.notify(string.format("LSP server not found in lspconfig: %s", s_name), "warn")
--       end
--     end
--   end
-- end

-- -- Install tools using Mason
-- function LSP_old.install_tools(tools_list, callback)
--   local ok, mr = funcs.safe_require('mason-registry')
--   if not ok then
--     vim.notify("Mason registry not available", vim.log.levels.ERROR)
--     return
--   end

--   -- Validate tools list
--   if not tools_list or #tools_list == 0 then
--     vim.notify("No tools to install", vim.log.levels.INFO)
--     if callback then callback() end
--     return
--   end

--   -- Track installation progress
--   local tools_to_install = {}
--   local installed_count = 0
--   local total_tools = #tools_list

--   -- Validate each tool name before attempting installation
--   for _, tool_name in ipairs(tools_list) do
--     -- Convert any non-string values to strings
--     if type(tool_name) ~= "string" then
--       -- Debug.notify(string.format("Invalid tool name (converting to string): %s",
--         tostring(tool_name)), "warn")
--       tool_name = tostring(tool_name)
--     end

--     -- Only add valid tool names that aren't already installed
--     if tool_name ~= "" and not mr.is_installed(tool_name) then
--       table.insert(tools_to_install, tool_name)
--     else
--       -- Debug.notify(string.format("Tool '%s' is already installed or invalid", tool_name))
--       installed_count = installed_count + 1
--     end
--   end

--   -- If no valid tools need installation, skip
--   if #tools_to_install == 0 then
--     -- Debug.notify("All tools are already installed")
--     if callback then callback() end
--     return
--   end

--   -- Set installation flag
--   Global.install_process = true

--   -- Install tools one by one to prevent UI freezing
--   local function install_next_tool(index)
--     if index > #tools_to_install then
--       -- All installations complete
--       Global.install_process = false
--       -- Debug.notify("All tools installed successfully")
--       if callback then callback() end
--       return
--     end

--     local tool_name = tools_to_install[index]
--     -- Debug.notify(string.format("Installing tool: %s (%d/%d)",
--       tool_name, index, #tools_to_install), "languages")

--     -- Safely attempt to get package from registry
--     local pkg_ok, pkg = pcall(mr.get_package, tool_name)
--     if not pkg_ok then
--       -- Debug.notify(string.format("Cannot find package '%s' in Mason registry", tool_name), "languages")
--       -- Continue with next tool even if this one fails
--       vim.defer_fn(function() install_next_tool(index + 1) end, 100)
--       return
--     end

--     -- Install the package
--     pkg:install():once("closed", function()
--       installed_count = installed_count + 1
--       -- Debug.notify(string.format("Installed %s (%d/%d)",
--         tool_name, installed_count, total_tools))

--       -- Schedule next installation
--       vim.defer_fn(function() install_next_tool(index + 1) end, 500)
--     end)
--   end

--   install_next_tool(1) --
-- end

-- -- Add a check function to verify if tools are actually installed
-- function LSP_old.register_tools(package_data, active_ft)
--   -- Clear previous tools list
--   LSP.tools_to_install = {}

--   local ok, mr = funcs.safe_require('mason-registry')
--   if not ok then
--     vim.notify("Mason registry not available", vim.log.levels.ERROR)
--     return false
--   end

--   -- If package data or active_ft is missing, exit early
--   if not package_data or not active_ft then
--     -- Debug.notify("Missing package data or active filetype")
--     return false
--   end

--   -- Set language and filetype in LSP object
--   LSP.language = package_data.language or ""
--   LSP.ft = active_ft

--   -- Process formatters
--   if package_data.formatters then
--     for formatter_name, _ in pairs(package_data.formatters) do
--       -- Verify this name exists in Mason and isn't already installed
--       if formatter_name and formatter_name ~= "" then
--         local pkg_exists = pcall(mr.get_package, formatter_name)
--         if pkg_exists and not mr.is_installed(formatter_name) then
--           table.insert(LSP.tools_to_install, formatter_name)
--           -- Debug.notify("Need to install formatter: " .. formatter_name)
--         end
--       end
--     end
--   end

--   -- Process linters (similar pattern)
--   if package_data.linters then
--     for linter_name, _ in pairs(package_data.linters) do
--       if linter_name and linter_name ~= "" then
--         local pkg_exists = pcall(mr.get_package, linter_name)
--         if pkg_exists and not mr.is_installed(linter_name) then
--           table.insert(LSP.tools_to_install, linter_name)
--           -- Debug.notify("Need to install linter: " .. linter_name)
--         end
--       end
--     end
--   end

--   -- Process LSP servers
--   if package_data.lsps then
--     for lsp_name, _ in pairs(package_data.lsps) do
--       if lsp_name and lsp_name ~= "" then
--         local pkg_exists = pcall(mr.get_package, lsp_name)
--         if pkg_exists and not mr.is_installed(lsp_name) then
--           table.insert(LSP.tools_to_install, lsp_name)
--           -- Debug.notify("Need to install LSP server: " .. lsp_name)
--         end
--       end
--     end
--   end

-- Process debuggers
-- if package_data.dap then
--   for debugger_name, _ in pairs(package_data.dap) do
--     if debugger_name and debugger_name ~= "" then
--       local pkg_exists = pcall(mr.get_package, debugger_name)
--       if pkg_exists and not mr.is_installed(debugger_name) then
--         table.insert(LSP.tools_to_install, debugger_name)
--         -- Debug.notify("Need to install debugger: " .. debugger_name)
--       end
--     end
--   end
-- end

--   -- Debug.notify(string.format("Registered %d tools that need installation", #LSP.tools_to_install))
--   return true
-- end

-- function LSP_old.setup_tools(package_data)
--   -- Check if any tools actually need installation
--   if #LSP.tools_to_install > 0 then
--     -- Check if user has decided to skip prompts
--     local skip_prompts = false
--     local skip_file = Global.cache_path .. "/.techdeus_packages"

--     if funcs.file_exists(skip_file) then
--       local content = funcs.read_file(skip_file)
--       if content and content ~= "" then
--         skip_prompts = true
--       end
--     end

--     -- If auto-installation is enabled or user chose to skip prompts
--     if Global.deus_packages or skip_prompts then
--       -- Silently install tools without prompting
--       -- Debug.notify("Auto-installing packages (user preference)")
--       LSP.install_tools(LSP.tools_to_install, function()
--         LSP.setup_language_servers(package_data)
--       end)
--     else
--       -- Show the installation prompt
--       LSP.language_installer(package_data)
--     end
--   else
--     -- No tools to install, proceed directly with server setup
--     LSP.setup_language_servers(package_data)
--   end
-- end

-- function LSP_old.language_installer(package_data)
--   local language = package_data.language or "unknown"

--   -- Make sure we actually have tools to install
--   if #LSP.tools_to_install == 0 then
--     -- Debug.notify("No tools to install for " .. language)
--     LSP.setup_language_servers(package_data)
--     return
--   end

--   local tools_list = table.concat(LSP.tools_to_install, ", ")

--   local install_items = {
--     string.format("Install packages for %s (%s)", language, tools_list),
--     "Install packages for all languages",
--     "Don't ask me again",
--     "Skip this time"
--   }

--   local install_opts = {
--     prompt = "Techdeus IDE needs to install packages",
--     with_cancel = true -- Ensure cancel option is available
--   }
--   local select = require("configs.select").build_select
--   -- Add a small delay to prevent auto-selection issues
--   vim.defer_fn(function()
--     select(install_items, install_opts, function(choice, idx)
--       -- Default to skipping if somehow idx is nil
--       if not idx then
--         -- Debug.notify("No option selected, skipping installation")
--         return
--       end

--       if idx == 1 then
--         funcs.close_float_windows()
--         -- Debug.notify("Installing packages for " .. language)
--         -- Batch install tools
--         LSP.install_tools(LSP.tools_to_install, function()
--           LSP.setup_language_servers(package_data)
--         end)
--       elseif idx == 2 then
--         funcs.close_float_windows()
--         -- Debug.notify("Installing packages for all languages")
--         vim.defer_fn(function()
--           lang_configs.install_all_packages()
--         end, 100)
--       elseif idx == 3 then
--         funcs.close_float_windows()
--         -- Write something to the file to indicate preference
--         funcs.write_file(Global.cache_path .. "/.techdeus_packages", "skip_prompts=true")
--         -- Debug.notify("Installation prompts disabled")
--         vim.notify(
--           "To enable prompts again run command:\n:AskForPackagesFile\nand restart Techdeus IDE",
--           vim.log.levels.INFO,
--           {
--             timeout = 10000,
--             title = "Techdeus IDE",
--           }
--         )
--       else
--         funcs.close_float_windows()
--         -- Debug.notify("Skipping installation for now")
--         vim.notify("Packages not installed. Language features might be limited.",
--           vim.log.levels.WARN,
--           {
--             timeout = 5000,
--             title = "Techdeus IDE",
--           })
--       end
--     end)
--   end, 100) -- Small delay to prevent auto-selection issues
-- end

-- function LSP_old.setup_language(package_data, active_ft)
--   -- Pre-setup preparation
--   -- Debug.notify('Setup Langs: ', vim.inspect(package_data))
--   if not package_data then return end
--   local ok, _ = pcall(require, "mason-registry")
--   if not ok then
--     vim.notify("Mason registry not available", vim.log.levels.ERROR)
--     return
--   end
--   -- Apply defaults first
--   LSP.apply_defaults()
--   -- Register tools
--   LSP.register_tools(package_data, active_ft)
--   --Install tools and setup language servers
--   local is_setup = LSP.setup_tools(package_data)
--   return is_setup
-- end

--End-of-file--
