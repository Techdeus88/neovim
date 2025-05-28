local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

local lsp_dependencies = {
    "python-lsp-server",
    "pyright-lagserver",
    "debugpy",
    "black",
}

local lsp_config = nil
local pyright_config = nil
local root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
}
local ruff_config = {
    filetypes = { "python" },
    cmd = { "ruff", "server" },
    root_markers = { ".git", "pyproject.toml" },
    init_options = {
        settings = {
            organizeImports = false,
            lint = {
                extendSelect = {
                    "A",
                    "ARG",
                    "B",
                    "COM",
                    "C4",
                    "DOC",
                    "FBT",
                    "I",
                    "ICN",
                    "N",
                    "PERF",
                    "PL",
                    "Q",
                    "RET",
                    "RUF",
                    "SIM",
                    "SLF",
                    "TID",
                    "W",
                },
            },
        },
    },
    settings = {},
}
local black_config = {
    command = "black",             -- Ensure Black is installed and available in your PATH
    args = { "--quiet", "-" },     -- Use `--quiet` to suppress output and `-` for stdin
    stdin = true,                  -- Black reads from stdin
}

local formatters = {
    ["black"] = { "black", black_config }
}
local linters = {
    ["ruff"] = { "ruff", ruff_config }
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    dap.adapters.python = {
        type = "executable",
        command = Global.mason_path .. "/packages/debugpy/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
    }

    dap.adapters.python = {
        type = "executable",
        command = Global.mason_path .. "/packages/debugpy/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
    }
    ---@type table<string, any>
    dap.configurations = dap.configurations or {}
    dap.configurations.python = dap.configurations.python or {}
    dap.configurations.python = {
        {
            type = "python",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            console = "integratedTerminal",
            stopOnEntry = true,
            justMyCode = false,
            pythonPath = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                end
                if vim.fn.executable(Global.mason_path .. "/packages/debugpy/venv/" .. "bin/python") == 1 then
                    return Global.mason_path .. "/packages/debugpy/venv/" .. "bin/python"
                else
                    return "python"
                end
            end,
            cwd = "${workspaceFolder}",
            postDebugTask = "Python: Close debugger",
        },
        {
            type = "python",
            request = "launch",
            name = "Debug Current File",
            program = "${file}",
            console = "integratedTerminal",
            stopOnEntry = true,
            justMyCode = false,
            cwd = "${workspaceFolder}",
            pythonPath = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                end
                if vim.fn.executable(Global.mason_path .. "/packages/debugpy/venv/" .. "bin/python") == 1 then
                    return Global.mason_path .. "/packages/debugpy/venv/" .. "bin/python"
                else
                    return "python"
                end
            end,
        },
    }

    pyright_config = {
        name = "python",
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = Global.file_types.python,
        root_markers = { ".git", "pyproject.toml" },
        settings = {
            pyright = {
                disableorganizeimports = true,
            },
            python = {
                analysis = {
                    autoimportcompletions = true,
                    autoseachpaths = false,
                    diagnosticmode = "openfilesonly",
                    typecheckingmode = "basic",
                    diagnosticseverityoverrides = {
                        reportprivateimportusage = "none",
                    },
                }
            },
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
        },
    }

    lsp_config = {
        name = "python",
        cmd = { "pylsp" },
        filetypes = Global.file_types.python,
        settings = {
            pylsp = {
                plugins = {
                    black = { enabled = true, line_length = 79 },
                    autopep8 = { enabled = false },
                    yapf = { enabled = false },
                },
            },
        },
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

    lsp_manager.handle_add_formatters(formatters)
    lsp_manager.handle_add_linters(linters)
end)

return setmetatable({}, {
    __index = function(_, key)
        if key == "config" then
            return { lsp_config, pyright_config }
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
