local globals = require("core.globals")
local funcs = require("core.funcs")
local Mini = {}

-- Load core mini.nvim module -> manages the package mamnager and all mini.nvim packages
Mini.load = function()
  -- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
  -- local mini_path = globals.path_package .. "pack/deps/opt/mini.nvim"
  local mini_path = globals.path_package .. "pack/deps/start/mini.nvim" -- original path

  if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/echasnovski/mini.nvim",
      mini_path,
    }
    vim.fn.system(clone_cmd)
    vim.cmd("packadd mini.nvim | helptags ALL")
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
  end
end

-- Load package manager
Mini.load_mini_deps = function()
  -- Mini.deps: package to manage plugins -> Install, update or remove --
  _G.MiniDeps = require("mini.deps")
  MiniDeps.setup({ path = { package = globals.path_package } })
  _G.add, _G.later, _G.now = MiniDeps.add, MiniDeps.later, MiniDeps.now

  _G.reload_plugin = function(plugin_name)
    package.loaded[plugin_name] = nil
    MiniDeps.now(function()
      require(plugin_name)
    end)
  end

  _G.manage_plugin_state = function(plugin_name, state_fn)
    return function()
      local plugin = require(plugin_name)
      if (type(state_fn) == "function") then
        state_fn(plugin)
      end
    end
  end
end

-- Load modules/configurations
Mini.load_modules = function()
  local module_configs = require("modules")
  for module_name, module_config in funcs.pairsByKeys(module_configs) do
    if (type(module_config) == "function") then
      add_to_log(module_name)
      module_config()
    end
  end
end

return Mini
