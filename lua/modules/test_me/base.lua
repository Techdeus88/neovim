local config = {}

config.dap = function()
    return {
        add = {
            source = 'mfussenegger/nvim-dap',
            depends = { 'rcarriga/nvim-dap-ui' },
            post_install = nil,
            post_checkout = nil,
        },
        require = "dap",
        load = "now",
        s_load = "now",
        setup_param = "setup",
        setup_type = "invoke-setup",
        setup_opts = function()
            local icons = require("configs.base.ui.icons")
            local dap = require("dap")

            -- C#
            dap.adapters.coreclr = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
                args = { "--interpreter=vscode" },
            }
            dap.configurations.cs = {
                {
                    type = "coreclr",
                    name = "launch - netcoredbg",
                    request = "launch",
                    program = function()
                        -- Ask the user what executable wants to debug
                        return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Program.exe", "file")
                    end,
                },
            }

            -- F#
            dap.configurations.fsharp = dap.configurations.cs

            -- Visual basic dotnet
            dap.configurations.vb = dap.configurations.cs

            -- Java
            -- Note: The java debugger jdtls is automatically spawned and configured
            -- by the plugin 'nvim-java' in './3-dev-core.lua'.
            -- Python
            dap.adapters.python = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
                args = { "-m", "debugpy.adapter" },
            }
            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}", -- This configuration will launch the current file if used.
                },
            }

            -- Lua
            dap.adapters.nlua = function(callback, config)
                callback({
                    type = "server",
                    host = config.host or "127.0.0.1",
                    port = config.port or 8086,
                })
            end
            dap.configurations.lua = {
                {
                    type = "nlua",
                    request = "attach",
                    name = "Attach to running Neovim instance",
                    program = function() pcall(require("osv").launch({ port = 8086 })) end,
                },
            }

            -- C
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                    args = { "--port", "${port}" },
                    detached = function()
                        if false then
                            -- if is_windows then
                            return false
                        else
                            return true
                        end
                    end,
                },
            }
            dap.configurations.c = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        -- Ask the user what executable wants to debug
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/bin/program", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
            }

            -- C++
            dap.configurations.cpp = dap.configurations.c

            -- Rust
            dap.configurations.rust = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        -- Ask the user what executable wants to debug
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/bin/program", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                    initCommands = function()
                        -- add rust types support (optional)
                        -- Find out where to look for the pretty printer Python module
                        local rustc_sysroot = vim.fn.trim(vim.fn.system("rustc --print sysroot"))

                        local script_import = 'command script import "'
                            .. rustc_sysroot
                            .. '/lib/rustlib/etc/lldb_lookup.py"'
                        local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"

                        local commands = {}
                        local file = io.open(commands_file, "r")
                        if file then
                            for line in file:lines() do
                                table.insert(commands, line)
                            end
                            file:close()
                        end
                        table.insert(commands, 1, script_import)

                        return commands
                    end,
                },
            }

            -- Go
            -- Requires:
            -- * You have initialized your module with 'go mod init module_name'.
            -- * You :cd your project before running DAP.
            dap.adapters.delve = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. "/mason/packages/delve/dlv",
                    args = { "dap", "-l", "127.0.0.1:${port}" },
                },
            }
            dap.configurations.go = {
                {
                    type = "delve",
                    name = "Compile module and debug this file",
                    request = "launch",
                    program = "./${relativeFileDirname}",
                },
                {
                    type = "delve",
                    name = "Compile module and debug this file (test)",
                    request = "launch",
                    mode = "test",
                    program = "./${relativeFileDirname}",
                },
            }

            -- Dart / Flutter
            dap.adapters.dart = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter",
                args = { "dart" },
            }
            dap.adapters.flutter = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter",
                args = { "flutter" },
            }
            dap.configurations.dart = {
                {
                    type = "dart",
                    request = "launch",
                    name = "Launch dart",
                    dartSdkPath = "/opt/flutter/bin/cache/dart-sdk/", -- ensure this is correct
                    flutterSdkPath = "/opt/flutter",                  -- ensure this is correct
                    program = "${workspaceFolder}/lib/main.dart",     -- ensure this is correct
                    cwd = "${workspaceFolder}",
                },
                {
                    type = "flutter",
                    request = "launch",
                    name = "Launch flutter",
                    dartSdkPath = "/opt/flutter/bin/cache/dart-sdk/", -- ensure this is correct
                    flutterSdkPath = "/opt/flutter",                  -- ensure this is correct
                    program = "${workspaceFolder}/lib/main.dart",     -- ensure this is correct
                    cwd = "${workspaceFolder}",
                },
            }

            -- Kotlin
            -- Kotlin projects have very weak project structure conventions.
            -- You must manually specify what the project root and main class are.
            dap.adapters.kotlin = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/bin/kotlin-debug-adapter",
            }
            dap.configurations.kotlin = {
                {
                    type = "kotlin",
                    request = "launch",
                    name = "Launch kotlin program",
                    projectRoot = "${workspaceFolder}/app", -- ensure this is correct
                    mainClass = "AppKt",                    -- ensure this is correct
                },
            }

            -- Javascript / Typescript (firefox)
            dap.adapters.firefox = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/bin/firefox-debug-adapter",
            }
            dap.configurations.typescript = {
                {
                    name = "Debug with Firefox",
                    type = "firefox",
                    request = "launch",
                    reAttach = true,
                    url = "http://localhost:4200", -- Write the actual URL of your project.
                    webRoot = "${workspaceFolder}",
                    firefoxExecutable = "/usr/bin/firefox",
                },
            }
            dap.configurations.javascript = dap.configurations.typescript
            dap.configurations.javascriptreact = dap.configurations.typescript
            dap.configurations.typescriptreact = dap.configurations.typescript

            -- Javascript / Typescript (chromium)
            -- If you prefer to use this adapter, comment the firefox one.
            -- But to use this adapter, you must manually run one of these two, first:
            -- * chromium --remote-debugging-port=9222 --user-data-dir=remote-profile
            -- * google-chrome-stable --remote-debugging-port=9222 --user-data-dir=remote-profile
            -- After starting the debugger, you must manually reload page to get all features.
            -- dap.adapters.chrome = {
            --  type = 'executable',
            --  command = vim.fn.stdpath('data')..'/mason/bin/chrome-debug-adapter',
            -- }
            -- dap.configurations.typescript = {
            --  {
            --   name = 'Debug with Chromium',
            --   type = "chrome",
            --   request = "attach",
            --   program = "${file}",
            --   cwd = vim.fn.getcwd(),
            --   sourceMaps = true,
            --   protocol = "inspector",
            --   port = 9222,
            --   webRoot = "${workspaceFolder}"
            --  }
            -- }
            -- dap.configurations.javascript = dap.configurations.typescript
            -- dap.configurations.javascriptreact = dap.configurations.typescript
            -- dap.configurations.typescriptreact = dap.configurations.typescript

            -- PHP
            dap.adapters.php = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/bin/php-debug-adapter",
            }
            dap.configurations.php = {
                {
                    type = "php",
                    request = "launch",
                    name = "Listen for Xdebug",
                    port = 9000,
                },
            }

            -- Shell
            dap.adapters.bashdb = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
                name = "bashdb",
            }
            dap.configurations.sh = {
                {
                    showDebugOutput = true,
                    pathBashdb = vim.fn.stdpath("data")
                        .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
                    pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
                    trace = true,
                    file = "${file}",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    pathCat = "cat",
                    pathBash = "/bin/bash",
                    pathMkfifo = "mkfifo",
                    pathPkill = "pkill",
                    args = {},
                    env = {},
                    terminalKind = "integrated",
                },
            }

            -- Elixir
            dap.adapters.mix_task = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/bin/elixir-ls-debugger",
                args = {},
            }
            dap.configurations.elixir = {
                {
                    type = "mix_task",
                    name = "mix test",
                    task = "test",
                    taskArgs = { "--trace" },
                    request = "launch",
                    startApps = true, -- for Phoenix projects
                    projectDir = "${workspaceFolder}",
                    requireFiles = {
                        "test/**/test_helper.exs",
                        "test/**/*_test.exs",
                    },
                },
            }

            return {
                icons = { expanded = icons.ui.ArrowClosed, collapsed = icons.ui.ArrowOpen },
                mappings = {
                    expand = { '<CR>', '<2-LeftMouse>' },
                    open = 'o',
                    remove = 'd',
                    edit = 'e',
                    repl = 'r',
                    toggle = 't',
                },
                expand_lines = vim.fn.has('nvim-0.7'),
                layouts = {
                    {
                        elements = {
                            { id = 'scopes', size = 0.25 },
                            'breakpoints',
                            'stacks',
                            'watches',
                        },
                        size = 40,
                        position = 'right',
                    },
                    {
                        elements = {
                            'repl',
                            'console',
                        },
                        size = 0.25,
                        position = 'bottom',
                    },
                },
                floating = {
                    max_height = nil,
                    max_width = nil,
                    border = 'rounded',
                    mappings = {
                        close = { 'q', '<Esc>' },
                    },
                },
                windows = { indent = 1 },
                render = {
                    max_type_length = nil,
                },
            }
        end,
        post_setup = function() end,
    }
end

config.dap_ui = function()
    return {
        add = { source = "rcarriga/nvim-dap-ui", depends = { "mfussenegger/nvim-dap" }, post_install = nil, post_checkout = nil },
        require = "dap-ui",
        load = "now",
        s_load = "later",
        setup_param = "setup",
        setup_type = "invoke-setup",
        setup_opts = function()
            local dap, dapui = require("dap"), require("dapui")
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
            dapui.setup({
                floating = {
                    border = "rounded",
                },
            })
        end,
        post_setup = function() end,
    }
end

config.dap_cmp = function()
    return { --[Debug] completion debugging--
        add = { source = "rcarriga/cmp-dap", depends = { "nvim-cmp" } },
        require = "",
        load = 'now',
        s_load = 'later',
        setup_param = "setup",       -- *setup,init,set,<custom>
        setup_type = "invoke-setup", -- invoke-setup | *full-setup
        setup_opts = function()
            require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
                sources = {
                    { name = "dap" },
                },
            })
        end,
        post_setup = function() end,
    }
end

config.neotest = function()
    return {
        enabled = true,
        add = {
            source = "nvim-neotest/neotest",
            depends = {
                "nvim-lua/plenary.nvim",
                "nvim-neotest/nvim-nio",
                "antoinemadec/FixCursorHold.nvim",
                "nvim-neotest/neotest-vim-test",
                "nvim-neotest/neotest",
                "sidlatau/neotest-dart",
                "Issafalcon/neotest-dotnet",
                "jfpedroza/neotest-elixir",
                "fredrikaverpil/neotest-golang",
                "rcasia/neotest-java",
                "nvim-neotest/neotest-jest",
                "olimorris/neotest-phpunit",
                "nvim-neotest/neotest-python",
                "rouge8/neotest-rust",
                "lawrence-laz/neotest-zig",
            },
            post_checkout = nil,
            post_install = nil,
        },
        require = "neotest",         -- Optional
        load = "now",
        s_load = "later",            -- *1=now,now | 2=now-later | 3=later-later
        setup_param = "setup",       -- *setup,init,set,<custom>
        setup_type = "invoke-setup", -- invoke-setup | *full-setup
        setup_opts = function()
            local neotest_ns = vim.api.nvim_create_namespace("neotest")
            vim.diagnostic.config({
                virtual_text = {
                    format = function(diagnostic)
                        local message =
                            diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                        return message
                    end,
                },
            }, neotest_ns)

            require("neotest").setup({
                adapters = {
                    -- require("neotest-python").setup({
                    --     dap = { justMyCode = false },
                    --     -- Command line arguments for runner
                    --     -- Can also be a function to return dynamic values
                    --     args = { "--log-level", "DEBUG" },
                    --     -- Runner to use. Will use pytest if available by default.
                    --     -- Can be a function to return dynamic value.
                    --     runner = "pytest",
                    --     -- Custom python path for the runner.
                    --     -- Can be a string or a list of strings.
                    --     -- Can also be a function to return dynamic value.
                    --     -- If not provided, the path will be inferred by checking for
                    --     -- virtual envs in the local directory and for Pipenev/Poetry configs
                    --     python = ".venv/bin/python",
                    --     -- Returns if a given file path is a test file.
                    --     -- NB: This function is called a lot so don't perform any heavy tasks within it.
                    --     is_test_file = function(file_path) end,
                    --     -- !!EXPERIMENTAL!! Enable shelling out to `pytest` to discover test
                    --     -- instances for files containing a parametrize mark (default: false)
                    --     pytest_discover_instances = true,
                    -- }),
                    require("neotest-dart"),
                    require("neotest-dotnet"),
                    require("neotest-elixir"),
                    require("neotest-golang"),
                    require("neotest-java"),
                    require("neotest-jest"),
                    require("neotest-phpunit"),
                    require("neotest-python"),
                    require("neotest-rust"),
                    require("neotest-zig"),
                },
            })
        end,
        post_setup = function() end,
    }
end

config.test_coverage = function()
    return {
        add = {
            source = "zeioth/nvim-coverage",
            depends = { "nvim-lua/plenary.nvim" },
            post_install = nil,
            post_checkout = nil,
        },
        require = "nvim-coverage",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            --[Testing]: testing coverage
            --  Shows a float panel with the [code coverage]
            --  https://github.com/andythigpen/nvim-coverage
            --  "tests": "jest --coverage"
            -- Our fork until all our PRs are merged.
            require("coverage").setup({
                summary = {
                    min_coverage = 80.0, -- passes if higher than
                },
            })
        end,
        post_setup = function() end,
    }
end

return config
