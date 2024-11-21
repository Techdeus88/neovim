local config = {}

config.img_clip = function()
    return {
        add = {
            source = "HakonHarnes/img-clip.nvim",
            depends = {},
            post_install = nil,
            post_checkout = nil,
        },
        require = "img-clip",
        load = "later",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function() end,
        post_setup = function() end,
    }
end

config.meandering_programmer = function()
    return {
        add = {
            source = "MeanderingProgrammer/render-markdown.nvim",
            depends = {},
            post_install = nil,
            post_checkout = nil,
        },
        require = "render-markdown",
        load = "later",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function()
            return {
                file_types = { "markdown", "Avante" },
                ft = { "markdown", "Avante" },
            }
        end,
        post_setup = function() end,
    }
end

config.avante = function()
    return {
        enabled = true,
        add = {
            source = "yetone/avante.nvim",
            monitor = "main",
            depends = {
                "stevearc/dressing.nvim",
                "nvim-lua/plenary.nvim",
                "MunifTanjim/nui.nvim",
                "echasnovski/mini.icons",
            },
            post_install = function()
                -- Ensure the native module is built
                vim.cmd("make")
                -- Verify the module can be loaded
                local ok, _ = pcall(require, "avante_repo_map")
                if not ok then
                    vim.notify("Failed to build avante_repo_map module", vim.log.levels.ERROR)
                end
            end,
            post_checkout = function() vim.cmd("make") end,
        },
        require = "avante_lib",
        load = "now",
        s_load = "now",
        setup_type = "invoke-setup",
        setup_param = "load",
        setup_opts = function() require("avante_lib").load() end,
        post_setup = function()
            require("avante").setup({
                -- provider = "openai", -- Only recommend using Claude
                provider = "claude", -- Recommend using Claude
                auto_suggestions_provider = "claude",
                claude = {
                    endpoint = "https://api.anthropic.com",
                    model = "claude-3-5-sonnet-20240620",
                    -- model = "claude-3-5-haiku-20241022",
                    temperature = 0,
                    max_tokens = 4096,
                },
                dual_boost = {
                    enabled = false,
                    first_provider = "openai",
                    second_provider = "claude",
                    prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
                    timeout = 60000, -- Timeout in milliseconds
                },
                behaviour = {
                    auto_suggestions = false, -- Experimental stage
                    auto_set_highlight_group = true,
                    auto_set_keymaps = true,
                    auto_apply_diff_after_generation = false,
                    support_paste_from_clipboard = false,
                },

                mappings = {
                    ask = "<leader>aa",
                    edit = "<leader>ae",
                    refresh = "<leader>ar",
                    --- @class AvanteConflictMappings
                    diff = {
                        ours = "co",
                        theirs = "ct",
                        none = "c0",
                        both = "cb",
                        next = "]x",
                        prev = "[x",
                    },
                    jump = {
                        next = "]]",
                        prev = "[[",
                    },
                    submit = {
                        normal = "<CR>",
                        insert = "<C-s>",
                    },
                    toggle = {
                        debug = "<leader>ad",
                        hint = "<leader>ah",
                    },
                },
                hints = { enabled = true },
                windows = {
                    ---@type "right" | "left" | "top" | "bottom"
                    position = "left", -- the position of the sidebar
                    wrap = true, -- similar to vim.o.wrap
                    width = 40, -- default % based on available width
                    sidebar_header = {
                        enabled = true, -- true, false to enable/disable the header
                        align = "center", -- left, center, right for title
                        rounded = true,
                    },
                    input = {
                        prefix = "> ",
                        height = 8, -- Height of the input window in vertical layout
                    },
                    edit = {
                        border = "rounded",
                        start_insert = true, -- Start insert mode when opening the edit window
                    },
                    ask = {
                        floating = false, -- Open the 'AvanteAsk' prompt in a floating window
                        start_insert = true, -- Start insert mode when opening the ask window
                        border = "rounded",
                        ---@type "ours" | "theirs"
                        focus_on_apply = "ours", -- which diff to focus after applying
                    },
                },
                highlights = {
                    ---@type AvanteConflictHighlights
                    diff = {
                        current = "DiffText",
                        incoming = "DiffAdd",
                    },
                },
                --- @class AvanteConflictUserConfig
                diff = {
                    autojump = true,
                    ---@type string | fun(): any
                    list_opener = "copen",
                    --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
                    --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
                    --- Disable by setting to -1.
                    override_timeoutlen = 500,
                },
            })
        end,
    }
end

config.fittencode = function()
    return {
        add = {
            source = "luozhiya/fittencode.nvim",
            depends = {},
            post_install = nil,
            post_checkout = nil,
        },
        require = "fittencode",
        load = "later",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function() end,
        post_setup = function() end,
    }
end

config.co_pilot_chat = function()
    return {
        add = {
            source = "CopilotC-Nvim/CopilotChat.nvim",
            depends = { "zbirenbaum/copilot-cmp" },
            post_install = nil,
            post_checkout = nil,
        },
        require = "CopilotChat",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            local icons = require("configs.base.ui.icons")
            local CoPilotChat = require("CopilotChat")
            require("CopilotChat.integrations.cmp").setup()

            CoPilotChat.setup({
                debug = false, -- Enable debug logging
                proxy = nil, -- [protocol://]host[:port] Use this proxy
                allow_insecure = false, -- Allow insecure server connections
                model = "gpt-4o", -- model to use, :CopilotChatModels for available models
                temperature = 0.1, -- temperature
                question_header = "# " .. icons.ui.User .. "User", -- Header to use for user questions
                answer_header = "# " .. icons.ui.Copilot .. "Copilot", -- Header to use for AI answers
                error_header = "## " .. icons.ui.CopilotError .. "Error", -- Header to use for errors
                separator = "\n──────────────", -- Separator to use in chat
                show_folds = true, -- Shows folds for sections in chat
                show_help = true, -- Shows help message as virtual lines when waiting for user input
                auto_follow_cursor = true, -- Auto-follow cursor in chat
                auto_insert_mode = false, -- Automatically enter insert mode when opening window and if auto follow cursor is enabled on new prompt
                clear_chat_on_new_prompt = false, -- Clears chat on every new prompt
                highlight_selection = true, -- Highlight selection in the source buffer when in the chat window
                context = "buffers", -- Default context to use, 'buffers', 'buffer' or none (can be specified manually in prompt via @).
                history_path = vim.fn.stdpath("data") .. "/copilot_chat_history", -- Default path to stored history
                callback = nil, -- Callback to use when ask response is received

                -- default window options
                window = {
                    layout = "horizontal", -- 'vertical', 'horizontal', 'float', 'replace'
                    width = 0.5, -- fractional width of parent, or absolute width in columns when > 1
                    height = 0.4, -- fractional height of parent, or absolute height in rows when > 1
                    -- Options below only apply to floating windows
                    relative = "editor", -- 'editor', 'win', 'cursor', 'mouse'
                    border = "rounded", -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
                    row = nil, -- row position of the window, default is centered
                    col = nil, -- column position of the window, default is centered
                    title = icons.ui.Copilot .. " Copilot Chat", -- title of chat window
                    footer = nil, -- footer of chat window
                    zindex = 1, -- determines if window is on top or below other floating windows
                },
                -- default mappings
                mappings = {
                    complete = {
                        insert = "",
                    },
                    close = {
                        normal = "q",
                        insert = "<C-c>",
                    },
                    reset = {
                        normal = "<C-r>",
                        insert = "<C-r>",
                    },
                    submit_prompt = {
                        normal = "<CR>",
                        insert = "<C-m>",
                    },
                    accept_diff = {
                        normal = "<C-y>",
                        insert = "<C-y>",
                    },
                    yank_diff = {
                        normal = "gy",
                    },
                    show_diff = {
                        normal = "gd",
                    },
                    show_system_prompt = {
                        normal = "gp",
                    },
                    show_user_selection = {
                        normal = "gs",
                    },
                },
            })
        end,
    }
end

config.co_pilot = function()
    return {
        add = {
            source = "zbirenbaum/copilot.lua",
            depends = { "CopilotC-Nvim/CopilotChat.nvim", "zbirenbaum/copilot-cmp" },
            post_install = nil,
            post_checkout = nil,
        },
        require = "copilot",
        setup_param = nil,
        setup_type = "invoke-setup",
        load = "now",
        s_load = "later",
        setup_opts = function()
            vim.g.copilot_no_dtab_map = true
            local CoPilot = require("copilot")
            local CoPilotChat = require("CopilotChat")
            local CopilotCmp = require("copilot_cmp")
            CopilotCmp.setup()
            CoPilotChat.setup()
            CoPilot.setup({
                panel = {
                    enabled = true,
                    auto_refresh = false,
                    keymap = {
                        jump_prev = "[[",
                        jump_next = "]]",
                        accept = "<CR>",
                        refresh = "gr",
                        open = "<M-CR>",
                    },
                    layout = {
                        position = "bottom",
                        ratio = 0.4,
                    },
                },
                suggestion = {
                    enabled = true,
                    auto_trigger = false,
                    debounce = 75,
                    keymap = {
                        accept = "<M-l>",
                        accept_word = false,
                        accept_line = false,
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = "<C-]>",
                    },
                },
                filetypes = {
                    yaml = true,
                    markdown = true,
                    help = true,
                    gitcommit = true,
                    gitrebase = true,
                    hgcommit = true,
                    svn = true,
                    cvs = true,
                    ["."] = true,
                },
                copilot_node_command = "node", -- Node.js version must be > 16.x
                server_opts_overrides = {},
            })
        end,
        post_setup = function()
            local CoPilotChat = require("CopilotChat")

            vim.keymap.set("i", "<C-e>", [[copilot#Accept("\<CR>")]], { expr = true, replace_keycodes = false })
            vim.keymap.set("i", "<C-.>", "<Plug>(copilot-next)")
            vim.keymap.set("i", "<C-,>", "<Plug>(copilot-previous)")
            vim.keymap.set("n", "<leader>cco", "<cmd>CopilotChatOpen<cr>", { desc = "CopilotChat Open" })
            vim.keymap.set("n", "<leader>ccr", "<cmd>CopilotChatReset<cr>", { desc = "CopilotChat Reset" })
            vim.keymap.set("n", "<leader>ccq", function()
                local input = vim.fn.input("Quick Chat: ")
                if input ~= "" then CoPilotChat.ask(input, { selection = require("CopilotChat.select").buffer }) end
            end, { desc = "CopilotChat - Quick chat for buffer" })
            vim.keymap.set(
                { "n", "v" },
                "<leader>ccp",
                ':lua require("CopilotChat.integrations.telescope").pick(require("CopilotChat.actions")prompt_actions())<cr>',
                { desc = "CopilotChat Commands" }
            )
        end,
    }
end

config.companion = function()
    return {
        add = {
            source = "olimorris/codecompanion.nvim",
            depends = {
                "nvim-lua/plenary.nvim",
                "nvim-treesitter/nvim-treesitter",
                "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
                "nvim-telescope/telescope.nvim", -- Optional: For using slash commands
                "MeanderingProgrammer/render-markdown.nvim", -- Optional: For prettier markdown rendering
                "stevearc/dressing.nvim", -- Optional: Improves `vim.ui.select`
            },
            post_install = nil,
            post_checkout = nil,
        },
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        require = "codecompanion",
        setup_opts = function()
            return {
                opts = {
                    log_level = "DEBUG",
                },
                adapters = {
                    openai = function()
                        return require("codecompanion.adapters").extend("openai", {
                            env = {
                                api_key = "cmd:op read op://personal/OpenAI_API/credential --no-newline",
                            },
                        })
                    end,
                },
                strategies = {
                    chat = {
                        adapter = "copilot",
                        roles = { llm = "  CodeCompanion", user = "techdeus" },
                    },

                    inline = {
                        adapter = "copilot",
                    },
                },
                display = {
                    chat = {
                        window = {
                            layout = "vertical", -- float|vertical|horizontal|buffer
                        },
                    },
                    diff = {
                        close_chat_at = 500,
                        provider = "diffview",
                    },
                },
            }
        end,
        post_setup = function() end,
    }
end

return config
