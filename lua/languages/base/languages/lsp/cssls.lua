local config = {}

config.cssls = function()
  return {
    settings = {
      css = {
        lint = {
          unknownAtRules = "ignore",
        },
      },
      scss = {
        lint = {
          unknownAtRules = "ignore",
        },
      },
    },
    setup = function(_, opts)
      LazyVim.lsp.on_attach(function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = true
        client.server_capabilities.documentFormattingProvider = true
      end, "cssls")
    end,
  }
end

return config
