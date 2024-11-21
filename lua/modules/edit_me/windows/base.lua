local config = {}

config.detour = function()
    return {
        --[Window]: use popups instead of splits. Nice Popup UI
        add = { source = "carbon-steel/detour.nvim", depends = {}, post_install = nil, post_checkout = nil },
        require = nil,
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function() end,
        post_setup = function()
            vim.api.nvim_create_autocmd("BufWinEnter", {
                pattern = "*",
                callback = function(event)
                    local filetype = vim.bo[event.buf].filetype
                    local file_path = event.match

                    if file_path:match("/doc/") ~= nil then
                        -- Only run if the filetype is a help file
                        if filetype == "help" or filetype == "markdown" then
                            -- Get the newly opened help window
                            -- and attempt to open a Detour() float
                            local help_win = vim.api.nvim_get_current_win()
                            local ok = require("detour").DetourCurrentWindow()

                            -- If we successfully create a float of the help file
                            -- Close the split
                            if ok then vim.api.nvim_win_close(help_win, false) end
                        end
                    end
                end,
            })
            vim.keymap.set("n", "<C-,>", "<cmd>Detour<cr>", { desc = "Detour full screen " })
            vim.keymap.set("n", "<C-.>", "<cmd>DetourCurrentWindow<cr>", { desc = "Detour current window" })
        end,
    }
end

---@type DeusConfigWrapper
config.flybuf_nvim = function()
    ---@return DeusConfig
    return {
        add = { source = "nvimdev/flybuf.nvim", depends = {}, post_checkout = nil, post_install = nil },
        require = "flybuf",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function() return {} end,
        post_setup = function() end,
    }
end

---@type DeusConfigWrapper
config.stickybuf_nvim = function()
    ---@return DeusConfig
    return {
        add = { source = "stevearc/stickybuf.nvim", depends = {}, post_checkout = nil, post_install = nil },
        require = "stickybuf",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)
        pre_setup = function()
            local excluded_filetypes = {
                "NvimTree",
                "neo-tree",
                "quickfix",
                "prompt",
                "telescope",
                "Trouble",
                "help",
                "minifiles",
                "Avante",
                "AvanteInput",
            }

            vim.api.nvim_create_autocmd("BufEnter", {
                desc = "Pin the buffer to any window that is fixed width or height",
                callback = function(args)
                    local ft = vim.bo[args.buf].filetype
                    local  GetWindowFileType = require("configs.base.utils.helpers").WindowViewFiletype
                    local WindowType = GetWindowFileType(ft, "separate").text
                    local stickybuf = require("stickybuf")
                    if not stickybuf.is_pinned() and WindowType == "Editor"  then
                       stickybuf.pin(0, { allow_type = "filetype"} )
                    end
            end, })

        end,
        setup_opts = function() end,
        post_setup = function() end,
    }
end

---@type DeusConfigWrapper
config.neozoom = function()
    ---@return DeusConfig
    return {
        add = { source = "nyngwang/NeoZoom.lua", depends = {}, post_checkout = nil, post_install = nil },
        require = "neo-zoom",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function()
            return {
                left_ratio = 0,
                top_ratio = 0,
                width_ratio = 0.6,
                height_ratio = 1,
                border = "thicc",
                scrolloff_on_zoom = 0,
                popup = { enabled = true },
                exclude_filetypes = { "lspinfo", "mason", "lazy", "fzf", "qf", "terminal" },
                winopts = {
                    offset = {
                        -- NOTE: omit `top`/`left` to center the floating window vertically/horizontally.
                        -- top = 0,
                        -- left = 0.17,
                        width = 150,
                        height = 0.65,
                    },
                    -- NOTE: check :help nvim_open_win() for possible border values.
                    border = "rounded", -- this is a preset, try it :)
                },
                presets = {
                    {
                        -- NOTE: regex pattern can be used here!
                        filetypes = { "dapui_.*", "dap-repl" },
                        winopts = {
                            offset = { top = 0.02, left = 0.26, width = 0.74, height = 0.25 },
                        },
                    },
                    {
                        filetypes = { "markdown" },
                        callbacks = {
                            function()
                                vim.wo.wrap = true
                                vim.opt.spell = true
                            end,
                        },
                    },
                },
            }
        end,
        post_setup = function() end,
    }
end
---@type DeusConfigWrapper
config.neoterm = function()
    ---@return DeusConfig
    return {
        add = { source = "nyngwang/NeoTerm.lua", depends = {}, post_checkout = nil, post_install = nil },
        require = "neo-term",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function()
            return {
                exclude_filetypes = { "minifiles", "ministarter", "help" },
            }
        end,
        post_setup = function() end,
    }
end

config.term = function()
    return {
        add = {
            source = "2kabhishek/termim.nvim",
            depends = {},
            post_install = nil,
            post_checkout = nil,
        },
        require = nil,
        setup_type = "full-setup",
        setup_param = "setup",
        load = "now",
        s_load = "later",
        setup_opts = function() end,
        post_setup = function() end,
    }
end
---@type DeusConfigWrapper
config.winshift = function()
    ---@return DeusConfig
    return {
        add = { source = "sindrets/winshift.nvim", depends = {}, post_checkout = nil, post_install = nil },
        require = "winshift",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function()
            return {
                highlight_moving_win = true,
                focused_hl_group = "CursorLine",
            }
        end,
        post_setup = function() end,
    }
end
---@type DeusConfigWrapper
config.colorful_winsep = function()
    ---@return DeusConfig
    return {
        add = {
            source = "nvim-zh/colorful-winsep.nvim",
            depends = {},
            post_checkout = nil,
            post_install = nil,
        },
        require = "colorful-winsep",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)

        setup_opts = function()
            return {
                hi = {
                    bg = "#16161E",
                    fg = "#1F3442",
                },
                -- This plugin will not be activated for filetype in the following table.
                no_exec_files = { "packer", "TelescopePrompt", "mason", "CompetiTest", "NvimTree" },
                -- Symbols for separator lines, the order: horizontal, vertical, top left, top right, bottom left, bottom right.
                symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
                -- #70: https://github.com/nvim-zh/colorful-winsep.nvim/discussions/70
                only_line_seq = true,
                -- Smooth moving switch
                smooth = true,
                exponential_smoothing = true,
                anchor = {
                    left = { height = 1, x = -1, y = -1 },
                    right = { height = 1, x = -1, y = 0 },
                    up = { width = 0, x = -1, y = 0 },
                    bottom = { width = 0, x = 1, y = 0 },
                },
            }
        end,
        post_setup = function() end,
    }
end
---@type DeusConfigWrapper
config.navigator = function()
    ---@return DeusConfig
    return {
        add = { source = "numToStr/Navigator.nvim", depends = {}, post_checkout = nil, post_install = nil },
        require = "Navigator",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function()
            return {
                auto_save = "current",
                disable_on_zoom = false,
                mux = "auto",
            }
        end,
        post_setup = function() end,
    }
end
---@type DeusConfigWrapper
config.no_neck_pain = function()
    ---@return DeusConfig
    return {
        add = { source = "shortcuts/no-neck-pain.nvim", depends = {}, post_checkout = nil, post_install = nil },
        require = "no-neck-pain",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function()
            local today = os.date("%m-%d-%Y")
            local lfilename = string.format("scratch-pad-note-%s.md", today)

            local calculate_width = function()
                local width = vim.api.nvim_win_get_width(0)
                local min_width = 57
                return math.min(width, min_width)
            end

            return {
                width = calculate_width(),
                mappings = {
                    enabled = false,
                },
                buffers = {
                    wo = {
                        fillchars = "eob: ",
                    },
                    left = {
                        colors = { blend = -0.4 },
                        scratchPad = {
                            enabled = true,
                            filename = lfilename,
                            pathToFile = string.format("~/techdeus/work/notes/%s", lfilename),
                        },
                        bo = {
                            filetype = { "md", "markdown" },
                        },
                    },
                    right = {
                        enabled = false,
                    },
                },
            }
        end,
        post_setup = function() end,
    }
end

return config
