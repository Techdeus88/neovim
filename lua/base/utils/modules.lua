--Start-of-file--
local m_helpers = {}

function m_helpers.split_plugin_name(plugin_source)
  local name = plugin_source:match "([^/]+)$"
  return name -- This retrieves the name part after the last '/'
end

function m_helpers.split_plugin_name_to_require(plugin_name)
  local developer, repo = plugin_name:match "([^.]+)/([^.]+)"
  return developer, repo
end

function m_helpers.is_disabled(Module_base)
  return Module_base.enabled ~= nil and not Module_base.enabled
end

function m_helpers.count_plugins()
  local deps_path = vim.fn.stdpath "data" .. "/site/pack/deps/start/"
  local all_modules_path = vim.fn.stdpath "data" .. "/site/pack/deps/opt/"
  local count = 0

  if vim.fn.isdirectory(deps_path) == 1 then
    -- Get all entries in the directory
    local entry = vim.fn.readdir(deps_path)
    local entries = vim.fn.readdir(all_modules_path)
    -- Count only directories (plugins)
    for _, mod in ipairs(entries) do
      if vim.fn.isdirectory(all_modules_path .. mod) == 1 then
        count = count + 1
      end
    end
    for _, Mod in ipairs(entry) do
      if vim.fn.isdirectory(deps_path .. Mod) == 1 then
        count = count + 1
      end
    end
  end
  return count
end

function m_helpers.set_module_keymaps(module_keys, module_name)
  if not module_keys or type(module_keys) ~= "table" and type(module_keys) ~= "function" then
    error "Keys must be a table or function"
    return false
  end

  local keys = type(module_keys) == "function" and (pcall(module_keys)) or module_keys
  if type(keys) ~= "table" then
    Debug.log(string.format("Invalid keys format for %s", module_name), "modules")
    return
  end

  for _, keymap in ipairs(keys) do
    if type(keymap) ~= "table" or not keymap[1] then
      Debug.log(string.format("Invalid keymap entry for %s", module_name), "modules")
    else
      local opts = {
        buffer = keymap.buffer,
        desc = keymap.desc,
        silent = keymap.silent ~= false,
        remap = keymap.remap,
        noremap = keymap.noremap ~= false,
        nowait = keymap.nowait,
        expr = keymap.expr,
      }
      for _, mode in ipairs(keymap.mode or { "n" }) do
        vim.keymap.set(mode, keymap[1], keymap[2], opts)
      end
    end
  end
end

-- Utility Functions
function m_helpers.safe_pcall(fn, ...)
  local ok, result = pcall(fn, ...)
  if not ok then
    vim.notify(string.format("Error: %s", result), vim.log.levels.ERROR)
    return nil
  end
  return result
end

function m_helpers.get_timing_function(Module, phase)
  if phase.timing == "now" then
    return MiniDeps.now
  end
  if phase.timing == "later" then
    return MiniDeps.later
  end
  return (Module.base.lazy ~= nil and Module.base.lazy) and MiniDeps.later or MiniDeps.now
end

-- File Management
function m_helpers.insert_moduleid_to_file(file, module_id)
  Global.files[file] = Global.files[file] or {}
  table.insert(Global.files[file], module_id)
end

-- Plugin Management
function m_helpers.get_plugin_path(plugin_name)
  return plugin_name == "mini.nvim" and (Global.package_path .. "/pack/deps/start/" .. plugin_name)
    or (Global.module_home .. plugin_name)
end

function m_helpers.validate_module(Module, checks)
  for _, check in ipairs(checks) do
    if not check.condition(Module) then
      vim.notify(check.message, vim.log.levels.WARN)
      return false
    end
  end
  return true
end

return m_helpers
--End-of-file--
