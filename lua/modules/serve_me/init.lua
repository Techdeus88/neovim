local configs = {}

configs.load = function()
  local M = require("configs.base.utils.modules")
  local module_lsp_tools_configs = require("modules.serve_me.tools")
  local module_lsp_ai_configs = require("modules.serve_me.ai")

  -- M.run_modules(module_lsp_tools_configs, "default")
  -- M.run_modules(module_lsp_ai_configs, "default")
  M.run_module(module_lsp_tools_configs.lsp_zero)
  M.run_module(module_lsp_tools_configs.lsp_config)
  M.run_module(module_lsp_tools_configs.fidget)
  M.run_module(module_lsp_tools_configs.mason)
  M.run_module(module_lsp_tools_configs.mason_lsp)
  M.run_module(module_lsp_tools_configs.mason_tool_installer)
  M.run_module(module_lsp_tools_configs.nvim_completion)
  M.run_module(module_lsp_tools_configs.luasnip)
  M.run_module(module_lsp_ai_configs.meandering_programmer)
  M.run_module(module_lsp_ai_configs.img_clip)
  M.run_module(module_lsp_ai_configs.avante)
  M.run_module(module_lsp_ai_configs.fittencode)
  M.run_module(module_lsp_ai_configs.co_pilot)
  M.run_module(module_lsp_ai_configs.companion)
  M.run_module(module_lsp_tools_configs.formatters)
  M.run_module(module_lsp_tools_configs.linters)

  local load = require("modules.serve_me.base")
  load.main()
end

return configs
