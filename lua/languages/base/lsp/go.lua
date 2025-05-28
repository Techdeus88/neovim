local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")
local lsp_manager = require('languages.lsp_manager')
local dap = require("dap")
local lsp_dependencies = {
    'gopls',
    'delve',
    'golangci-lint',
    'goimports',
    'gofumpt'
}

local root_markers = {
    "go.work",
    "go.mod",
    ".git",
}

local gofumpt_config = {
    name = 'gofumpt',
    command = 'gofumpt',
    args = {},
    stdin = true,
}

local goimports_config = {
    name = 'goimports',
    command = 'goimports',
    args = {},
    stdin = true,
}

local golangcilint_config = {
    name = 'golangci-lint',
    command = 'golangci-lint',
    args = {},
    stdin = true,
}

local linters = {
    ['golangci-lint'] = { 'golangci-lint', golangcilint_config },
}

local formatters = {
    ['goimports'] = { 'goimports', goimports_config },
    ['gofumpt'] = { 'gofumpt', gofumpt_config },
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    dap.adapters.go = function(callback)
        local handle
        local port = 38697
        handle = vim.loop.spawn('dlv', {
            args = { 'dap', '-l', '127.0.0.1:' .. port },
            detached = true,
        }, function(_)
            handle:close()
        end)
        vim.defer_fn(function()
            callback({ type = 'server', host = '127.0.0.1', port = port })
        end, 100)
    end
    dap.configurations = dap.configurations or {}
    dap.configurations.go = dap.configurations.go or {}
    dap.configurations.go = {
        {
            type = 'go',
            name = 'Launch',
            request = 'launch',
            program = function()
                return vim.fn.input('Path to executable: ', './', 'file')
            end,
        },
        {
            type = 'go',
            name = 'Launch test',
            request = 'launch',
            mode = 'test',
            program = function()
                return vim.fn.input('Path to executable: ', './', 'file')
            end,
        },
    }

    lsp_config = {
        name = "go",
        cmd = { "gopls" },
        filetypes = Global.file_types.go,
        settings = {
            gopls = {
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
            },
            opts = {
                inlay_hints = { enabled = true },
            },
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.omni(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_formatting(client, bufnr)
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
        elseif key == "formatters" then
            return formatters
        elseif key == "linters" then
            return linters
        end
    end,
})
