local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "astro-language-server",
    "prettierd",
}

local lsp_config = nil
local root_markers = {
    "astro.config.mjs",
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()

    lsp_config = {
        name = "astro",
        filetypes = Global.file_types.astro,
        cmd = { "astro-ls", "--stdio" },
        init_options = {
            typescript = {
                tsdk = vim.fs.normalize(
                    "~/.local/share/nvim/mason/packages/astro-language-server/node_modules/typescript/lib"
                ),
            },
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        settings = {},
        capabilities = setup_diagnostics.get_capabilities(),
    }
end)

return setmetatable({}, {
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

