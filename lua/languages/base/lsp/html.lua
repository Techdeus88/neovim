local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "html-lsp",
    "prettierd",
}
local lsp_config = nil
local root_markers = {
    "package.json",
    ".git",
    ".prettierrc"
}

local prettierd_config = {
    cmd = "prettierd --tab-width=4 --stdin-filepath ${FILENAME}",
    exe = "prettierd",
    args = { vim.api.nvim_buf_get_name(0) },
    stdin = true,
}

local formatters = {
    stylua = { "prettierd", prettierd_config }
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "html",
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = Global.file_types.html,
        settings = {
            html = {
                format = true,
            },
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
    }
    lsp_manager.handle_add_formatters(formatters)
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

-- vim: foldmethod=indent foldlevel=1
