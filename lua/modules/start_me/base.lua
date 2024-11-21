local config = {}

config["1_lua_rocks"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "vhyrro/luarocks.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = nil,
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup", --init,set,setup (default)

        setup_opts = function()
            local luarocks_opts = {
                rocks = { "magick", "fzy" },
                luarocks_build_args = { "--with-lua=/usr/local/bin/lua5.1" },
            }
            require("luarocks-nvim").setup(luarocks_opts)
        end,
        post_setup = nil,
    }
end

config["2_lush"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "rktjmp/lush.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = nil,
        load = "now",
        s_load = "later",
        setup_param = "setup",
        setup_type = "invoke-setup",
        setup_opts = function() end,
        post_setup = nil,
    }
end

config["3_zenbones_colortheme"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = { "rktjmp/lush.nvim", "pgdouyon/vim-yin-yang", "masar3141/mono-jade", "bettervim/yugen.nvim" },
            source = "zenbones-theme/zenbones.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = nil,
        load = "now",
        s_load = "later",
        setup_opts = function()
            -- lua
            vim.g.forestbones = { solid_line_nr = true, darken_comments = 45, transparent_background = true }
        end,
        post_setup = nil,
    }
end

config["4_auto_dark_mode"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "f-person/auto-dark-mode.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "auto-dark-mode",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            local auto_dark_mode = require("auto-dark-mode")
            auto_dark_mode.setup({
                update_interval = 2000,
                set_dark_mode = function()
                    local cd = require("configs.base.colors")
                    vim.opt.background = "dark"
                    _G.theme = cd.theme
                    _G.theme_palette = cd.palette
                    _G.DEUS_COLORS = cd.base_colors()
                    -- vim.cmd(string.format("colorscheme %s", _G.DEUS_SETTINGS.theme))

                    vim.cmd(string.format("colorscheme %s", 'yin'))
                end,
                set_light_mode = function()
                    local cl = require("configs.base.colors")
                    vim.opt.background = "light"
                    _G.theme = cl.theme
                    _G.theme_palette = cl.palette
                    _G.DEUS_COLORS = cl.base_colors()
                    -- vim.cmd(string.format("colorscheme %s", _G.DEUS_SETTINGS.theme))
                    vim.cmd(string.format("colorscheme %s", 'yang'))
                end,
            })
        end,
        post_setup = nil,
    }
end

config["5_project"] = function()
    return {
        add = {
            source = "ahmedkhalf/project.nvim",
            depends = {},
            post_install = nil,
            post_checkout = nil,
        },
        require = "project_nvim",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function()
            return {
                -- Project detection methods
                detection_methods = { "pattern", "lsp" },

                -- Patterns to detect root directory
                patterns = {
                    ".git",
                    "_darcs",
                    ".hg",
                    ".bzr",
                    ".svn",
                    "Makefile",
                    "package.json",
                    "pyproject.toml",
                    "go.mod",
                    "Cargo.toml",
                    "src",
                    "src/*",
                    "README.md",
                    "index.lua",
                    "index.py",
                    "main.py",
                    "src/main.rs",
                    "pnpm-workspace.yaml",
                    "nx.json",
                    "rush.json",
                    "turbo.json",
                    "composer.json",
                },

                -- Limit the number of recent projects shown
                max_history_size = 50,

                -- Ignore certain directories
                exclude_dirs = {
                    "~/",
                    "~/Documents",
                    "~/Downloads",
                    "~/Desktop",
                    "~/Pictures",
                    "~/.local",
                },
                -- Silent mode to prevent unnecessary messages
                silent_chdir = true,
                -- Scope projects by type of project
                scope_chdir = "tab",
                -- Additional configuration for better project management
                manual_mode = false,
                show_hidden = true,
                -- Add workspace support
                workspace_config = {
                    -- Configure per-project settings
                    ["~/projects/rust/*"] = {
                        patterns = { "Cargo.toml", "rust-toolchain.toml" },
                    },
                    ["~/projects/node/*"] = {
                        patterns = { "package.json", "tsconfig.json" },
                    },
                },
            }
        end,
        post_setup = function()
            -- Cache recently opened files per project
            local project_files_cache = {}

            local function open_project(path)
                -- Change directory
                vim.cmd("cd " .. path)

                -- Try cached file first
                if project_files_cache[path] then
                    local cached_file = project_files_cache[path]
                    if vim.fn.filereadable(cached_file) == 1 then
                        vim.cmd("edit " .. cached_file)
                        return
                    end
                end

                -- Existing file detection logic
                local ok, mini_files = pcall(require, "mini.files")
                if not ok then return end

                local default_files = {
                    "README.md",
                    "index.lua",
                    "index.py",
                    "main.py",
                    "src/main.rs",
                    "package.json",
                    "Cargo.toml",
                }

                local show_tree = true
                for _, file in ipairs(default_files) do
                    local full_path = path .. "/" .. file
                    if vim.fn.filereadable(full_path) == 1 then
                        show_tree = false
                        project_files_cache[path] = full_path
                        vim.cmd("edit " .. full_path)
                        break
                    end
                end

                if show_tree then mini_files.open(path) end
            end
            vim.keymap.set("n", "<leader>fp", "<cmd>Pick projects<cr>", { desc = "Find Projects" })
        end,
    }
end

config["6_starter"] = function()
    ---@return DeusConfig
    return {
        add = {
            source = "echasnovski/mini.starter",
            depends = {},
            post_checkout = nil,
            post_install = nil,
        },
        name = "mini.starter",
        require = "mini.starter",
        load = "now",
        s_load = "now",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            local MiniStarter = require("mini.starter")
            local items_content = function()
                return {
                    MiniStarter.sections.recent_files(7, true, true),
                    {
                        name = "Colorschemes",
                        action = "Pick colorschemes",
                        section = "Builtin & Pick",
                    },
                    {
                        name = "Deps",
                        action = function() require("mini.deps").update(nil, { force = true }) end,
                        section = "Builtin & Pick",
                    },
                    {
                        name = "Mason",
                        action = "Mason",
                        section = "Builtin & Pick",
                    },
                    {
                        name = "Projects",
                        action = "Pick projects",
                        section = "Builtin & Pick",
                    },
{
                        name = "Files",
                        action = "MiniPick.:1",
                        section = "Builtin & Pick",
                    },

                    {
                        name = "Quit",
                        action = function() vim.cmd("quitall") end,
                        section = "Builtin & Pick",
                    },
                }
            end

            local footer_content = function()
                local function display_startup_info(initial_starter_seconds)
                    local optional_plugins_count =
                        vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/opt", "*", 0, 1)
                    local plugins_count = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/start", "*", 0, 1)
                    local lines = {
                        "",
                        "Startup time: " .. string.format("%.2f", initial_starter_seconds) .. " ms",
                        "Loaded plugins: " .. #plugins_count + #optional_plugins_count .. " plugins",
                        "",
                    }
                    return lines
                end

                local footer_n_seconds = function()
                    _G.initial_render_end_time = vim.loop.hrtime()
                    _G.initial_render_total_time = (_G.initial_render_end_time - _G.start_time) / 1e6
                    return display_startup_info(_G.initial_render_total_time)
                end

                local thingy = io.popen(
                    'echo "$(LANG=en_us_88591; date +%a) $(date +%d) $(LANG=en_us_88591; date +%b)" | tr -d "\n"'
                )
                if thingy == nil then return end
                local date = thingy:read("*a")
                thingy:close()
                local datetime = os.date("%H:%M")
                -- Get number of plugins loaded
                local hi_top_section = {
                    type = "text",
                    val = "┌────────────  existence day: "
                        .. date
                        .. " ─────────────┐",
                    opts = {
                        position = "center",
                        hl = "HeaderInfo",
                    },
                }
                local hi_bottom_section = {
                    type = "text",
                    val = "└───══───══───══── "
                        .. " AND TIME: "
                        .. datetime
                        .. " ──══───══───══────┘",
                    opts = {
                        position = "center",
                        hl = "HeaderInfo",
                    },
                }
                local startup_info = {
                    type = "text",
                    val = footer_n_seconds(),
                    opts = { position = "center", hl = "Comment" },
                }

                local footer = {}
                table.insert(footer, hi_top_section.val)
                for _, m_line in pairs(startup_info.val) do
                    table.insert(footer, m_line)
                end
                table.insert(footer, hi_bottom_section.val)
                return table.concat(footer, "\n")
            end

            local header_content = function()
                local header = {}
                local handle_tip = require("modules.build_me.base.tip")
                local tip = handle_tip()
                local header_top = [[
┏━━━━┓━━━━━━━━┏┓━━━━┏┓━━━━━━━━━━━━
┃┏┓┏┓┃━━━━━━━━┃┃━━━━┃┃━━━━━━━━━━━━
┗┛┃┃┗┛┏━━┓┏━━┓┃┗━┓┏━┛┃┏━━┓┏┓┏┓┏━━┓
━━┃┃━━┃┏┓┃┃┏━┛┃┏┓┃┃┏┓┃┃┏┓┃┃┃┃┃┃━━┫
━┏┛┗┓━┃┃━┫┃┗━┓┃┃┃┃┃┗┛┃┃┃━┫┃┗┛┃┣━━┃
━┗━━┛━┗━━┛┗━━┛┗┛┗┛┗━━┛┗━━┛┗━━┛┗━━ ]]
                table.insert(header, header_top)
                for _, line in pairs(tip) do
                    table.insert(header, line)
                end
                return table.concat(header, "\n")
            end

            MiniStarter.setup({
                autoopen = true,
                evaluate_single = false,
                items = {
                    items_content(),
                },
                header = header_content(),
                footer = footer_content(),
                content_hooks = {
                    MiniStarter.gen_hook.adding_bullet(),
                    MiniStarter.gen_hook.aligning("center", "center"),
                    MiniStarter.gen_hook.padding(3, 1),
                },
                silent = true,
            })
            _G.after_render_start_end_time = vim.loop.hrtime()
            _G.after_render_total_end_time = (_G.after_render_start_end_time - _G.start_time) / 1e6
        end,
        post_setup = nil,
    }
end

config["7_plenary"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "nvim-lua/plenary.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = nil,
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = nil,
        setup_opts = function() end,
        post_setup = nil,
    }
end

config["8_nui_nvim"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "MunifTanjim/nui.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = nil,
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            local base_ui_modules = require("modules.build_me.base").base_ui()

            base_ui_modules.override_ui_input()
            base_ui_modules.override_ui_select()
        end,
        post_setup = nil,
    }
end

config["9_mini_icons"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "echasnovski/mini.icons",
            post_checkout = nil,
            post_install = nil,
        },
        require = "mini.icons",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function()
            return { -- Increase icon preset size
                preset = "default",
                sign = {
                    -- Adjust padding to help with rendering
                    hl = { fg = nil, bg = nil },
                    padding = { left = 0, right = 1 },
                },
            }
        end,
        post_setup = function()
            local MiniIcons = require("mini.icons")
            MiniIcons.mock_nvim_web_devicons()
            MiniIcons.tweak_lsp_kind()
        end,
    }
end

config["A_lsp_icons"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = { "echasnovski/mini.icons" },
            source = "onsails/lspkind.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "lspkind",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "init", --init,set,setup (default)
        setup_opts = function()
            return {
                mode = "symbol",
                symbol_map = {
                    Array = "󰅪",
                    Boolean = "⊨",
                    Class = "󰌗",
                    Constructor = "",
                    Key = "󰌆",
                    Namespace = "󰅪",
                    Null = "NULL",
                    Number = "#",
                    Object = "󰀚",
                    Package = "󰏗",
                    Property = "",
                    Reference = "",
                    Snippet = "",
                    String = "󰀬",
                    TypeParameter = "󰊄",
                    Unit = "",
                },
                menu = {},
            }
        end,
        post_setup = nil,
    }
end

config["B_dressing"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "stevearc/dressing.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "dressing",
        load = "now",
        s_load = "now",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function()
            return {
                win_options = {
                    winblend = 10,
                    winhighlight = "Normal:DressingInputNormalFloat,NormalFloat:DressingInputNormalFloat,FloatBorder:DressingInputFloatBorder",
                },
                input = {
                    enabled = true,
                    default_prompt = "Input:",
                    prompt_align = "left",
                    insert_only = true,
                    start_in_insert = true,
                    border = "rounded",
                    relative = "cursor",
                    prefer_width = 40,
                    width = nil,
                    max_width = { 140, 0.9 },
                    min_width = { 20, 0.2 },
                    get_config = nil,
                },
                select = {
                    enabled = true,
                    backend = { "telescope", "fzf_lua", "fzf", "nui", "builtin" },
                    trim_prompt = true,
                },
            }
        end,
        post_setup = nil,
    }
end

config["C_nvim_notify"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
            source = "rcarriga/nvim-notify",
            post_checkout = nil,
            post_install = nil,
        },
        require = "notify",
        load = "now",
        s_load = "now",
        setup_type = "invoke-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function()
            local icons = require("configs.base.ui.icons")
            local Notify = require("notify")
            local colors = require("configs.base.colors").base_colors()
            -- local bg_color = tostring(base_colors.bg.darken(40).hex)
            Notify.setup({
                {
                    background_color = colors.bg1.hex,
                    fps = 30,
                    icons = {
                        DEBUG = icons.common.fix,
                        ERROR = icons.diagnostics.error,
                        WARN = icons.diagnostics.warn,
                        INFO = icons.diagnostics.info,
                        TRACE = icons.common.trace,
                    },
                    level = 2,
                    render = "default",
                    stages = "fade_in_slide_out",
                    timeout = 2000,
                    top_down = true,

                    max_height = function() return math.floor(vim.o.lines * 0.75) end,
                    max_width = function() return math.floor(vim.o.columns * 0.75) end,
                    on_open = function(win) vim.api.nvim_win_set_config(win, { zindex = 100 }) end,
                },
            })
        end,
        post_setup = function()
            local Notify = require("notify")
            -- Controls noisy notifications
            local buffered_messages = {
                "Client %d+ quit",
                "No node found at cursor",
            }
            local message_notifications = {}
            vim.notify = function(msg, level, opts)
                opts = opts or {}
                for _, pattern in ipairs(buffered_messages) do
                    if string.find(msg, pattern) then
                        if message_notifications[pattern] then opts.replace = message_notifications[pattern] end

                        opts.on_close = function() message_notifications[pattern] = nil end
                        message_notifications[pattern] = Notify.notify(msg, level, opts)
                        return
                    end
                end
                Notify.print_history = function()
                    local color = {
                        DEBUG = "NotifyDEBUGTitle",
                        TRACE = "NotifyTRACETitle",
                        INFO = "NotifyINFOTitle",
                        WARN = "NotifyWARNTitle",
                        ERROR = "NotifyERRORTitle",
                    }
                    for _, m in ipairs(Notify.history()) do
                        vim.api.nvim_echo({
                            { vim.fn.strftime("%FT%T", m.time), "Identifier" },
                            { " ", "Normal" },
                            { m.level, color[m.level] or "Title" },
                            { " ", "Normal" },
                            { table.concat(m.message, " "), "Normal" },
                        }, false, {})
                    end
                end
                vim.cmd("command! Message :lua require('notify').print_history()<CR>")

                Notify.notify(msg, level, opts)
            end
        end,
    }
end

config["D_popup_nvim"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "nvim-lua/popup.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = nil,
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function() end,
        post_setup = nil,
    }
end

config["E_twilight"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "folke/twilight.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "twilight",
        load = "later",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function()
            return {
                dimming = { alpha = 0.45, color = { "Normal", "#ffffff" }, inactive = false },
                context = 9,
                treesitter = true,
                expand = { "function", "method", "table", "if_statement", "element" },
                exclude = {},
            }
        end,
        post_setup = nil,
    }
end

config["F_zen_mode"] = function()
    ---@return DeusConfig
    return {
        add = {
            depends = { "folke/twilight.nvim" },
            source = "folke/zen-mode.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "zen-mode",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup", --init,set,setup (default)
        setup_opts = function()
            local opts = {
                window = {
                    backdrop = 0.95,
                    width = 180,
                    height = 1,
                    options = {
                        signcolumn = "no",
                        number = false,
                        relativenumber = false,
                        cursorline = false,
                        cursorcolumn = false,
                        foldcolumn = "0",
                        list = false,
                    },
                },
                plugins = {
                    options = { enabled = true, ruler = true, showcmd = true },
                    twilight = { enabled = true },
                    gitsigns = { enabled = true },
                    tmux = { enabled = true },
                    kitty = { enabled = false, font = "+4" },
                },
                on_open = function(win) vim.o.laststatus = 0 end,
                on_close = function() vim.o.laststatus = 2 end,
            }
            require("zen-mode").setup(opts)
        end,
        post_setup = nil,
    }
end

config["G_which_key"] = function()
    return {
        add = {
            source = "folke/which-key.nvim",
            depends = {},
            post_checkout = nil,
            post_install = nil,
        },
        require = "which-key",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            local WhichKey = require("which-key")
            WhichKey.setup({
                preset = "helix",
            })
        end,
        post_setup = function()
            local WhichKey = require("which-key")
            WhichKey.add({
                {
                    "<leader>b",
                    group = "+Buffers",
                    expand = function() return require("which-key.extras").expand.buf() end,
                },
                { "<leader>tab", group = "+Layouts" }, -- proxy to window mappings
                { "<leader>l", proxy = "<c-l>", group = "+Lsp" }, -- proxy to window mappings
                { "<leader>g", group = "+Git" },
                { "<leader>gh", group = "+Hunks" },
                { "<leader>t", proxy = "<c-t>", group = "+Toggles" }, -- proxy to window mappings
                { "<leader>u", proxy = "<c-u>", group = "+More Toggles" }, -- proxy to window mappings
                {
                    "<leader>w",
                    group = "+Windows",
                    proxy = "<c-w>",
                    expand = function() return require("which-key.extras").expand.win() end,
                },
                {
                    "<leader>x",
                    group = "+Diagnostics/quickfix",
                    icon = { icon = "󱖫 ", color = "green" },
                },
                { "[", group = "+Prev" },
                { "]", group = "+Next" },
                { "g", group = "+Goto" },
                { "gs", group = "+Surround" },
                { "z", group = "+Fold" },
            })
        end,
    }
end

-- config.snacks = function()
--   return {
--     add = {
--       depends = {},
--       source = "folke/snacks.nvim", -- Required
--       post_checkout = nil,
--       post_install = nil,
--     },
--     require = "snacks",          -- Optional
--     load = "now",
--     s_load = "later",            -- *1=now,now | 2=now-later | 3=later-later
--     setup_param = "setup",       -- *setup,init,set,<custom>
--     setup_type = "invoke-setup", -- invoke-setup | *full-setup
--     setup_opts = function()
--       local Snacks = require("snacks")
--       Snacks.setup({
--         bigfile = { enabled = true },
--         notifier = {
--           enabled = true,
--           timeout = 3000,
--         },
--         quickfile = { enabled = true },
--         statuscolumn = { enabled = true },
--         words = { enabled = true },
--         styles = {
--           notification = {
--             wo = { wrap = true }, -- Wrap notifications
--           },
--         },
--         debug = {
--           enabled = true,
--         },
--       })

--       _G.dd = function(...) Snacks.debug.inspect(...) end
--       _G.bt = function() Snacks.debug.backtrace() end
--       _G.dp = function(...) Snacks.debug.profile(...) end
--       vim.print = _G.dd
--       local keymaps = require("configs.base.2-keymaps").keymaps

--       keymaps["normal"] = vim.list_extend(keymaps["normal"], {
--         { "<leader>un", function() Snacks.notifier.hide() end,           "Dismiss All Notifications" },
--         { "<leader>bd", function() Snacks.bufdelete() end,               "Delete Buffer" },
--         { "<leader>gg", function() Snacks.lazygit() end,                 "Lazygit" },
--         { "<leader>gb", function() Snacks.git.blame_line() end,          "Git Blame Line" },
--         { "<leader>gB", function() Snacks.gitbrowse() end,               "Git Browse" },
--         { "<leader>gf", function() Snacks.lazygit.log_file() end,        "Lazygit Current File History" },
--         { "<leader>gl", function() Snacks.lazygit.log() end,             "Lazygit Log (cwd)" },
--         { "<leader>cR", function() Snacks.rename() end,                  "Rename File" },
--         { "<c-/>",      function() Snacks.terminal() end,                "Toggle Terminal" },
--         { "<c-_>",      function() Snacks.terminal() end,                "which_key_ignore" },
--         { "]]",         function() Snacks.words.jump(vim.v.count1) end,  "Next Reference" },
--         { "[[",         function() Snacks.words.jump(-vim.v.count1) end, "Prev Reference" },
--         {
--           "<leader>N",
--           desc = "Neovim News",
--           function()
--             Snacks.win({
--               file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
--               width = 0.6,
--               height = 0.6,
--               wo = {
--                 spell = false,
--                 wrap = false,
--                 signcolumn = "yes",
--                 statuscolumn = " ",
--                 conceallevel = 3,
--               },
--             })
--           end,
--         },
--       })
--     end,
--     post_setup = function() end,
--   }
-- end

return config
