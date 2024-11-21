local config = {}
config.main = function()
  local funcs = require("core.funcs")
  local Fidget = require("fidget")
  local Mason = require("mason")
  local MasonToolInstaller = require("mason-tool-installer")
  local MasonLsp = require("mason-lspconfig")
  local LspFormatters = require("languages.base.languages.lsp_formatters")
  local LspLinters = require("languages.base.languages.lsp_linters")
  local LspServers = require("languages.base.languages.lsp_servers")

  local LspConfig = require("languages.utils.setup_diagnostics")
  local ShowDiags = require("languages.utils.show_diagnostics")

  local base_capabilities = LspConfig.get_capabilities()
  -- Initialize diagnostics
  LspConfig.init_diagnostics()
  -- Get LSP server capabilities
  -- LSP attach method
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(event)
      local opts = { bufnr = event.buf }
      local id = vim.tbl_get(event, "data", "client_id")
      local client = id and vim.lsp.get_client_by_id(id)
      local bufnr = opts.bufnr

      if client == nil then return end
      -- keymaps
      LspConfig.keymaps(_, bufnr)
      -- omni
      LspConfig.omni(client, bufnr)
      -- tag
      LspConfig.tag(client, bufnr)
      -- document highlight
      LspConfig.document_highlight(client, bufnr)
      -- document formatting
      LspConfig.document_formatting(client, bufnr)
      -- inlay hints
      LspConfig.inlay_hint(client, bufnr)
      -- navic
      LspConfig.navic(client, bufnr)
    end,
  })
  -- Show diagnostics
  ShowDiags.show_line_diagnostics()
  -- LSP messaging
  Fidget.setup()
  -- LSP languages
  Mason.setup({})
  -- Tools installer
  MasonToolInstaller.setup({
    ensure_installed = vim.list_extend(funcs.merge(LspLinters, LspFormatters), LspServers),
    auto_update = false,
    run_on_start = true,
    start_delay = 5000,
    debounce_hours = 10,
    integrations = {
      ['mason-lspconfig'] = true,
      ['mason-null-ls'] = false,
      ['mason-nvim-dap'] = true,
    },
  })
  -- Configure servers
  MasonLsp.setup({
    handlers = {
      function(server_name)
        local server = require("lspconfig")[server_name]
        server.setup({
          capabilities = base_capabilities
        })
      end,
      lua_ls = require("lspconfig").lua_ls.setup({
        require("languages.base.languages.lsp.lua_ls"),
      }),
      eslint = require("lspconfig").eslint.setup({
        require("languages.base.languages.lsp.eslint")
      }),
      rust_analyzer = function()
        require("languages.base.languages.lsp.rust")
        return require("lsp-zero").noop
      end,
    },
  })
end
return config
