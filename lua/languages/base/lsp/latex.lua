local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "texlab",
}

local lsp_config = nil
local root_markers = {
    ".latexmkrc",
    ".texlabroot",
    "texlabroot",
    "Tectonic.toml",
    ".git",
    "main.tex",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "latex",
        cmd = { "texlab" },
        filetypes = Global.file_types.latex,
        settings = {
            texlab = {
                bibtexFormatter = "texlab",
                diagnosticDelay = 100,
                formatterLineLength = 80,
                forwardSearch = {
                    executable = nil,
                    args = {},
                },
                rootDirectory = nil,
                build = {
                    executable = "latexmk",
                    args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                    onSave = false,
                    onType = false,
                    forwardSearchAfter = false,
                },
                chktex = {
                    onOpenAndSave = false,
                    onEdit = false,
                },
                diagnosticsDelay = 300,
                latexFormatter = "latexindent",
                latexindent = {
                    ["local"] = nil,
                    modifyLineBreaks = false,
                },


            },
        },
        single_file_support = true,
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
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
