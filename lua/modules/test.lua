return { -- Testing ~2 modules~
    {    -- Neotest: testing in neovim
        "nvim-neotest/neotest",
        event = "BufRead",
        depends = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "rouge8/neotest-rust",
            "nvim-neotest/neotest-go",
            "nvim-neotest/neotest-python",
            -- "olimorris/neotest-phpunit",
            -- "jfpedroza/neotest-elixir",
            -- "sidlatau/neotest-dart",
        },
        config = function()
            local neotest_status_ok, neotest = pcall(require, "neotest")
            if not neotest_status_ok then
                return
            end
            local neotest_ns = vim.api.nvim_create_namespace("neotest")
            vim.diagnostic.config({
                virtual_text = {
                    format = function(diagnostic)
                        local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+",
                            "")
                        return message
                    end,
                },
            }, neotest_ns)
            neotest.setup({
                adapters = {
                    -- require("neotest-phpunit"),
                    require("neotest-rust"),
                    require("neotest-go"),
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        args = { "--log-level", "DEBUG" },
                        runner = "pytest",
                    }),
                    -- require("neotest-elixir"),
                    -- require("neotest-dart")({
                    -- command = "flutter",
                    -- use_lsp = true,
                    -- }),
                },
            })
            vim.api.nvim_create_user_command("NeotestRun", function()
                require("neotest").run.run()
            end, {})
            vim.api.nvim_create_user_command("NeotestRunCurrent", function()
                require("neotest").run.run(vim.fn.expand("%"))
            end, {})
            vim.api.nvim_create_user_command("NeotestRunDap", function()
                require("neotest").run.run({ strategy = "dap" })
            end, {})
            vim.api.nvim_create_user_command("NeotestStop", function()
                require("neotest").run.stop()
            end, {})
            vim.api.nvim_create_user_command("NeotestAttach", function()
                require("neotest").run.attach()
            end, {})
            vim.api.nvim_create_user_command("NeotestOutput", function()
                require("neotest").output.open()
            end, {})
            vim.api.nvim_create_user_command("NeotestSummary", function()
                require("neotest").summary.toggle()
            end, {})
        end
    },
    { -- NVIM-DAP: debugging and testing in neovim
        "mfussenegger/nvim-dap",
        event = "BufReadPre",
        depends = {
            "igorlfs/nvim-dap-view",
            "jbyuki/one-small-step-for-vimkind",
            "mxsdev/nvim-dap-vscode-js",
        },
        config = function()
            local dap_status_ok, dap = pcall(require, "dap")
            if not dap_status_ok then
                return
            end
            local icons = require("base.ui.icons")
            local dap_view_status_ok, dap_view = pcall(require, "dap-view")
            if not dap_view_status_ok then
                return
            end
            vim.fn.sign_define("DapBreakpoint", {
                text = icons.dap_ui.sign.breakpoint,
                texthl = "DapBreakpoint",
                linehl = "",
                numhl = "",
            })
            vim.fn.sign_define("DapBreakpointRejected", {
                text = icons.dap_ui.sign.reject,
                texthl = "DapBreakpointRejected",
                linehl = "",
                numhl = "",
            })
            vim.fn.sign_define("DapBreakpointCondition", {
                text = icons.dap_ui.sign.condition,
                texthl = "DapBreakpointCondition",
                linehl = "",
                numhl = "",
            })
            vim.fn.sign_define("DapStopped", {
                text = icons.dap_ui.sign.stopped,
                texthl = "DapStopped",
                linehl = "",
                numhl = "",
            })
            vim.fn.sign_define("DapLogPoint", {
                text = icons.dap_ui.sign.log_point,
                texthl = "DapLogPoint",
                linehl = "",
                numhl = "",
            })
            vim.api.nvim_create_user_command("LuaDapLaunch", 'lua require"osv".run_this()', {})
            vim.api.nvim_create_user_command("DapToggleBreakpoint", 'lua require("dap").toggle_breakpoint()', {})
            vim.api.nvim_create_user_command("DapClearBreakpoints", 'lua require("dap").clear_breakpoints()', {})
            vim.api.nvim_create_user_command("DapRunToCursor", 'lua require("dap").run_to_cursor()', {})
            vim.api.nvim_create_user_command("DapContinue", 'lua require"dap".continue()', {})
            vim.api.nvim_create_user_command("DapStepInto", 'lua require"dap".step_into()', {})
            vim.api.nvim_create_user_command("DapStepOver", 'lua require"dap".step_over()', {})
            vim.api.nvim_create_user_command("DapStepOut", 'lua require"dap".step_out()', {})
            vim.api.nvim_create_user_command("DapUp", 'lua require"dap".up()', {})
            vim.api.nvim_create_user_command("DapDown", 'lua require"dap".down()', {})
            vim.api.nvim_create_user_command("DapPause", 'lua require"dap".pause()', {})
            vim.api.nvim_create_user_command("DapClose", 'lua require"dap".close()', {})
            vim.api.nvim_create_user_command("DapDisconnect", 'lua require"dap".disconnect()', {})
            vim.api.nvim_create_user_command("DapRestart", 'lua require"dap".restart()', {})
            vim.api.nvim_create_user_command("DapToggleRepl", 'lua require"dap".repl.toggle()', {})
            vim.api.nvim_create_user_command("DapGetSession", 'lua require"dap".session()', {})
            vim.api.nvim_create_user_command(
                "DapUIClose",
                'lua require"dap".close(); require"dap".disconnect(); require"dapui".close()',
                {}
            )
            vim.keymap.set("n", "<A-1>", function()
                dap.toggle_breakpoint()
            end, { noremap = true, silent = true, desc = "DapToggleBreakpoint" })
            vim.keymap.set("n", "<A-2>", function()
                local ft = vim.bo.filetype
                local dap = require("dap")
                if ft == "lua" then
                    if not dap.session() then
                        local ok, err = pcall(function()
                            require("osv").run_this()
                        end)
                        if not ok then
                            vim.notify("Could not start Lua debug session: " .. tostring(err), vim.log.levels.ERROR)
                        end
                    else
                        dap.continue()
                    end
                else
                    dap.continue()
                end
            end, { noremap = true, silent = true, desc = "Debug Start/Continue" })
            vim.keymap.set("n", "<A-3>", function()
                dap.step_into()
            end, { noremap = true, silent = true, desc = "DapStepInto" })
            vim.keymap.set("n", "<A-4>", function()
                dap.step_over()
            end, { noremap = true, silent = true, desc = "DapStepOver" })
            vim.keymap.set("n", "<A-5>", function()
                dap.step_out()
            end, { noremap = true, silent = true, desc = "DapStepOut" })
            vim.keymap.set("n", "<A-6>", function()
                dap.up()
            end, { noremap = true, silent = true, desc = "DapUp" })
            vim.keymap.set("n", "<A-7>", function()
                dap.down()
            end, { noremap = true, silent = true, desc = "DapDown" })
            vim.keymap.set("n", "<A-8>", function()
                dap.close()
                dap.disconnect()
                dap_view.close()
            end, { noremap = true, silent = true, desc = "DapUIClose" })
            vim.keymap.set("n", "<A-9>", function()
                dap.restart()
            end, { noremap = true, silent = true, desc = "DapRestart" })
            vim.keymap.set("n", "<A-0>", function()
                dap.repl.toggle()
            end, { noremap = true, silent = true, desc = "DapToggleRepl" })
            dap.listeners.after.event_initialized["dapui_config"] = function()
                vim.defer_fn(function()
                    dap_view.open()
                end, 200)
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dap_view.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dap_view.close()
            end
        end
    }
}
