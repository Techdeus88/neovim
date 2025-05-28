local setup_diagnostics = require("languages.utils.setup_diagnostics")
local schemastore = require('schemastore')
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

local lsp_config = nil

local lsp_dependencies = {
    "json-lsp",
    "jsonlint",
    "fixjson",
}

local root_markers = {
    ".git",
}

local pattern = 'line (%d+), col (%d+), (.*)'
local groups = { 'lnum', 'col', 'message' }
local severities = nil -- none provided

local fixjson_config = {
    command = 'fixjson',
    args = { '--stdin-filename', '$FILENAME', '-w' },
    stdin = true,
}

local jsonlint_config = {
    cmd = 'jsonlint',
    args = { '--sort-keys', '--compact' },
    stdin = true,
    parser = function()
        local ok, _ = pcall(require, 'lint')
        if ok then
            return require('lint.parser').from_pattern(pattern, groups, severities, {
                source = 'jsonlint',
                severity = vim.diagnostic.severity.ERROR,
            })
        end
    end,
}

local formatters = {
    ['fixjson'] = { 'fixjson', fixjson_config },
}
local linters = {
    ['jsonlint'] = { 'jsonlint', jsonlint_config },
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "json",
        on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
        end,
        filetypes = Global.file_types["json"],
        cmd = { 'vscode-json-language-server', '--stdio' },
        init_options = {
            provideFormatter = true,
        },
        root_markers = { ".git", '.luarc.json' },
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
        end,
        single_file_support = true,
        settings = {
            json = {
                schemas = schemastore.json.schemas(),
                validate = { enable = true },
            },
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            setup_diagnostics.navic(client, bufnr)
        end,
        capabilities = setup_diagnostics.get_capabilities(),
    }
    lsp_manager.handle_add_formatters(formatters)    
    lsp_manager.handle_add_linters(linters)
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
