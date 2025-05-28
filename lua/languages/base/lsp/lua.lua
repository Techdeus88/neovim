local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")
local lsp_manager = require('languages.lsp_manager')
local dap = require("dap")

local lsp_config = nil

local lsp_dependencies = {
    "lua-language-server",
    "luacheck",
    "stylua",
}

local root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
}

local severities = {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
    info = vim.diagnostic.severity.INFO,
    hint = vim.diagnostic.severity.HINT,
}
local groups = { 'lnum', 'col', 'end_lnum', 'end_col', 'severity', 'message' }
local pattern = '(%d+):(%d+)-(%d+):(%d+): (%w+): (.+)'
local function parser(output)
    local diagnostics = {}
    for _, line in ipairs(vim.fn.split(output, '\n')) do
        local matches = { line:match(pattern) }
        if #matches == #groups then
            local diagnostic = {}
            for i, group in ipairs(groups) do
                diagnostic[group] = matches[i]
            end
            diagnostic.severity = severities[diagnostic.severity]
            diagnostic.lnum = tonumber(diagnostic.lnum) - 1
            diagnostic.col = tonumber(diagnostic.col) - 1
            diagnostic.end_lnum = tonumber(diagnostic.end_lnum) - 1
            diagnostic.end_col = tonumber(diagnostic.end_col) - 1
            table.insert(diagnostics, diagnostic)
        end
        if #matches ~= #groups then
            vim.notify('Unmatched line in luacheck output: ' .. line, vim.log.levels.DEBUG)
        end
    end
    return diagnostics
end

local luacheck_config = {
    cmd = 'luacheck',
    stdin = true,
    args = { '--formatter', 'plain', '--codes', '--ranges', '-' },
    ignore_exitcode = true,
    parser = parser,
}

local stylua_config = {
    command = 'stylua',
    args = {
        '--search-parent-directories',
        '--stdin-filepath',
        '$FILENAME',
        '-',
    },
    stdin = true
}

local selene_severities = {
    Error = vim.diagnostic.severity.ERROR,
    Warning = vim.diagnostic.severity.WARN,
}

local selene_config = {
    cmd = 'selene',                            -- Ensure Selene is installed and available in your PATH
    stdin = true,
    args = { '--display-style', 'json', '-' }, -- JSON output for diagnostics
    stream = 'stdout',
    ignore_exitcode = true,                    -- Don't fail if Selene exits with a non-zero code
    parser = function(output, bufnr)
        local diagnostics = {}
        local lines = vim.split(output, '\n')
        for _, line in ipairs(lines) do
            local ok, decoded = pcall(vim.json.decode, line)
            if not ok or not decoded then
                return diagnostics
            end

            local labels = decoded.secondary_labels or {}
            table.insert(labels, decoded.primary_label)

            for _, label in ipairs(labels) do
                local message = decoded.message
                if label.message ~= "" then
                    message = message .. ". " .. label.message
                end
                table.insert(diagnostics, {
                    bufnr = bufnr,
                    lnum = label.span.start.line - 1,                                                         -- Convert to 0-based indexing
                    col = label.span.start.column - 1,                                                        -- Convert to 0-based indexing
                    end_lnum = label.span["end"] and label.span["end"].line - 1 or label.span.start.line - 1, -- Fallback to start line
                    end_col = label.span["end"] and label.span["end"].column - 1 or label.span.start.column,  -- Fallback to start column
                    severity = decoded.severity == "Error" and vim.diagnostic.severity.ERROR
                        or vim.diagnostic.severity.WARN,
                    source = "selene",
                    message = message,
                })
            end
        end
        return diagnostics
    end,
}

local linters = {
    ['luacheck'] = { "luacheck", luacheck_config },
}

local formatters = {
    ['stylua'] = { "stylua", stylua_config }
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    dap.adapters.nlua = function(callback, config)
        callback({ type = "server", host = config.host, port = config.port })
    end
    ---@type table<string, any>
    dap.configurations = dap.configurations or {}
    dap.configurations.lua = dap.configurations.lua or {}
    dap.configurations.lua = {
        {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
            host = function()
                local value = vim.fn.input("Host [127.0.0.1]: ")
                if value ~= "" then
                    return value
                end
                return "127.0.0.1"
            end,
            port = function()
                local input = vim.fn.input("Port [8086]: ")
                if input == "" then
                    return 8080
                end
                local value = tonumber(input)
                if not value then
                    vim.notify("Invalid port number, using default 8086", vim.log.levels.WARN)
                    return 8086
                end
                return value
            end,
        },
    }

    lsp_config = {
        name = "lua-ls",
        cmd = { "lua-language-server" },
        filetypes = Global.file_types.lua,
        settings = {
            Lua = {
                format = {
                    enable = false,
                },
                hint = {
                    enable = true,
                    arrayIndex = "All",
                    await = true,
                    paramName = "All",
                    paramType = true,
                    semicolon = "Disable",
                    setType = true,
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                runtime = {
                    version = "LuaJIT",
                    special = {
                        reload = "require",
                    },
                },
                diagnostics = {
                    globals = {
                        "vim",
                        "use",
                        "packer_plugins",
                        "NOREF_NOERR_TRUNC",
                    },
                },
                telemetry = {
                    enable = false,
                },
            },
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            setup_diagnostics.omni_tags(client, bufnr)
            setup_diagnostics.navic(client, bufnr)
        end,
        capabilities = setup_diagnostics.get_capabilities(),
    }
    lsp_manager.handle_add_linters(Global.file_types.lua[1], linters)
    lsp_manager.handle_add_formatters(Global.file_types.lua[1], formatters)
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
--End-of-file--
