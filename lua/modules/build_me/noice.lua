local config = {}

config.noice = function()
    return {
        enabled = false,
        add = { 
            source = "folke/noice.nvim", 
            depends = {}, 
            post_install = nil, 
            post_checkout = nil 
        },
        require = "noice",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        pre_setup = function()
            vim.api.nvim_set_hl(0, "NoiceMini", { link = "Normal" })
            vim.api.nvim_set_hl(0, "NoiceMiniIncSearch", { link = "IncSearch" })
            vim.api.nvim_set_hl(0, "NoiceMiniSearch", { link = "Search" })
        end,
        setup_opts = function()
            local icons = require("configs.base.ui.icons")
            require("noice").setup {
                -- Command line configuration
                cmdline = {
                    enabled = true,
                    view = "cmdline_popup",
                    format = {
                        cmdline = { icon = icons.ui.Terminal, pattern = "^:", icon_hl_group = "NoiceCmdlineIcon" },
                        search_down = { icon = icons.ui.Search, pattern = "^/", icon_hl_group = "NoiceSearchIcon", view = "cmdline_popup" },
                        search_up = { icon = icons.ui.SearchUp, pattern = "^%?", icon_hl_group = "NoiceSearchIcon", view = "cmdline_popup" },
                        filter = { icon = icons.ui.Filter, pattern = "^:%s*!", icon_hl_group = "NoiceFilterIcon", view = "cmdline_popup" },
                        lua = { icon = icons.ui.Code, pattern = "^:%s*lua%s+", icon_hl_group = "NoiceLuaIcon", view = "cmdline_popup" },
                        help = { icon = icons.ui.Question, pattern = "^:%s*he?l?p?%s+", icon_hl_group = "NoiceHelpIcon", view = "cmdline_popup" },
                    },
                },

                notify = {
                    enabled = false,
                },
                -- Message configuration
                messages = {
                    enabled = true,
                    view = "mini",
                    view_error = "mini",
                    view_warn = "mini",
                    view_history = "messages",
                    view_search = "virtualtext",
                },
                -- Disable LSP features
                lsp = {
                    progress = { enabled = false },
                    hover = { enabled = false },
                    signature = { enabled = false },
                    message = { enabled = false },
                    documentation = { enabled = false },
                },
                -- Views configuration
                views = {
                    mini = {
                        position = {
                            row = -2,
                            col = "99%",
                        },
                        size = {
                            width = "auto",
                            height = "auto",
                        },
                        win_options = {
                            winblend = 0,
                            winhighlight = {
                                Normal = "NoiceMini",
                                IncSearch = "NoiceMiniIncSearch",
                                Search = "NoiceMiniSearch",
                            },
                        },
                        border = { style = "none" },
                    },
                    cmdline_popup = {
                        position = {
                            row = 5,  -- Adjust this value to move the command line up/down
                            col = "50%",
                        },
                        size = {
                            width = 60,
                            min_width = 10,
                            height = "auto",
                        },
                        border = {
                            style = "rounded",
                            padding = { 0, 1 },
                        },
                    },
                    popupmenu = {
                        relative = "cmdline",  -- Position relative to cmdline instead of editor
                        position = {
                            row = 1,  -- Position 1 row below the cmdline
                            col = 0,
                        },
                        size = {
                            width = 60,
                            height = 10,
                        },
                        border = {
                            style = "rounded",
                            padding = { 0, 1 },
                        },
                        win_options = {
                            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
                        },
                    },
                },
                routes = {
                    -- Skip duplicate messages
                    {
                        filter = { event = "msg_show", kind = "", find = "written" },
                        opts = { skip = true },
                    },
                    {
                        filter = { event = "msg_show", kind = "search_count" },
                        opts = { skip = true },
                    },
                },
                -- Format configuration
                format = {
                    level = {
                        icons = {
                            error = icons.diagnostics.Error,
                            warn = icons.diagnostics.Warn,
                            info = icons.diagnostics.Info,
                        },
                    },
                },
            }
        end,
        post_setup = nil,
    }
end

return config
