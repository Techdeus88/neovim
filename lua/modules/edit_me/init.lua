local configs = {}

configs.load = function()
  local M = require("configs.base.utils.modules")

  local module_editor_treesitter_configs = require("modules.edit_me.treesitter")
  local module_editor_base_configs = require("modules.edit_me.base")
  local module_editor_git_configs = require("modules.edit_me.git")
  local module_editor_ui_configs = require("modules.edit_me.ui")
  local modules_windows = require("modules.edit_me.windows")

  modules_windows.load()
  M.run_modules(module_editor_base_configs, "default")
  M.run_modules(module_editor_ui_configs, "default")
  M.run_modules(module_editor_treesitter_configs, "default")
  M.run_modules(module_editor_git_configs, "default")
end

return configs
