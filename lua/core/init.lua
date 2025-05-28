--Start-of-file--
local vim = vim

-- Constants
local CORE_MODULES = {
  start = { "debug", "events", "global" },
  pre = { "store", "mini" },
  main = { "base", "modules" },
}
-- Performance Measurement
local function create_timer()
  local start = vim.uv.hrtime()
  return function(message)
    return string.format("%s in %.2f ms", message, (vim.uv.hrtime() - start) / 1e6)
  end
end

-- Module Initialization
local function initialize_module(module_name, phase)
  local mod_ok, module = pcall(require, module_name)
  if not mod_ok then
    vim.notify(string.format("Failed to load core module: %s", module_name), vim.log.levels.ERROR)
    return false
  end

  if module.init then
    local init_ok, err = pcall(module.init)
    if not init_ok then
      vim.notify(string.format("Failed to initialize %s: %s", module_name, err), vim.log.levels.ERROR)
      return false
    end
    return true
  end
  return true
end

local function initialize_core_modules()
  for _, mod in ipairs(CORE_MODULES.start) do
    local module_name = string.format("core.%s", mod)
    if not initialize_module(module_name, "core") then
      vim.notify(string.format("Failed to load required-module: %s", module_name), vim.log.levels.ERROR)
      return false
    end
  end
  return true
end

local function initialize_pre_modules()
  _G.Debug.log("Initializing pre-modules", "default")

  for _, mod in ipairs(CORE_MODULES.pre) do
    local module_name = string.format("core.%s", mod)
    if not initialize_module(module_name, "pre") then
      vim.notify(string.format("Failed to initialize pre-module: %s", module_name), vim.log.levels.ERROR)
    end
  end
  return true
end

local function initialize_main_modules()
  _G.Debug.log("Initializing main modules", "default")

  for _, mod in ipairs(CORE_MODULES.main) do
    if not initialize_module(mod, "main") then
      vim.notify(string.format("Failed to initialize main module: %s", mod), vim.log.levels.ERROR)
    end

    -- Special handling for base module
    if mod == "base" then
      vim.api.nvim_exec_autocmds("User", { pattern = "TechdeusStart" })
    end
  end
end

local function init()
  _G.get_duration = create_timer()

  if not initialize_core_modules() then
    vim.notify("Failed to initialize core modules", vim.log.levels.ERROR)
    return
  end

  if _G.Global and _G.Global.os == "unsupported" then
    vim.notify("Your OS is unsupported", vim.log.levels.ERROR)
    return
  end

  local funcs_ok, funcs = pcall(require, "core.funcs")
  if not funcs_ok then
    vim.notify("Failed to load core functions", vim.log.levels.ERROR)
    return
  end

  if funcs.deus_notify then
    -- funcs.deus_notify()
  end

  if not initialize_pre_modules() then
    -- Ensure MiniDeps is available
    if not _G.MiniDeps then
      vim.notify("MiniDeps not initialized", vim.log.levels.ERROR)
      return
    end
  end

  initialize_main_modules()

  vim.api.nvim_exec_autocmds("User", { pattern = "TechdeusReady" })
end

init()
--End-of-file--
