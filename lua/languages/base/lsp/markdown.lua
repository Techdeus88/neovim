--Start-of-file--
local navic = require('nvim-navic')
local setup_diagnostics = require('languages.utils.setup_diagnostics')
local lsp_manager = require('languages.lsp_manager')
local lsp_installer = require('languages.lsp_installer')

local lsp_dependencies = {
  'marksman',
  'prettierd',
  'cbfmt',
}

local lsp_config = nil
local root_markers = {
  '.marksman.toml',
  '.git',
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
  local cbfmt_config = {
    {
      server_name = 'cbfmt',
      fPrefix = 'cbfmt',
      formatCommand = 'cbfmt --stdin-filepath ${FILENAME} --best-effort',
      formatStdin = true,
      rootMarkers = { '.cbfmt.toml' },
    },
  }

  lsp_config = {
    name = 'markdown',
    cmd = { 'marksman', 'server' },
    filetypes = Global.file_types.markdown,
    on_attach = function(client, bufnr)
      setup_diagnostics.keymaps(client, bufnr)
      setup_diagnostics.document_highlight(client, bufnr)
      setup_diagnostics.document_auto_format(client, bufnr)
      setup_diagnostics.inlay_hint(client, bufnr)
      if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
      end
    end,
    capabilities = setup_diagnostics.get_capabilities(),
  }
end)

return setmetatable({}, {
  __index = function(_, key)
    if key == 'config' then
      return lsp_config
    elseif key == 'root_patterns' then
      return root_markers
    end
  end,
})
--End-of-file--
