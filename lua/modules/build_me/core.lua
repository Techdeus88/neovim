local config = {}

config.aerial = function()
    return {
        add = { source = "stevearc/aerial.nvim", depends = {}, post_checkout = nil, post_install = nil },
        require = "aerial",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function()
            return {
                attach_mode = "global",
                close_on_select = true,
                layout = {
                    min_width = 30,
                    default_direction = "prefer_right",
                },
                -- Use nvim-navic icons
                icons = {
                    File = "󰈙 ",
                    Module = " ",
                    Namespace = "󰌗 ",
                    Package = " ",
                    Class = "󰌗 ",
                    Method = "󰆧 ",
                    Property = " ",
                    Field = " ",
                    Constructor = " ",
                    Enum = "󰕘",
                    Interface = "󰕘",
                    Function = "󰊕 ",
                    Variable = "󰆧 ",
                    Constant = "󰏿 ",
                    String = "󰀬 ",
                    Number = "󰎠 ",
                    Boolean = "◩ ",
                    Array = "󰅪 ",
                    Object = "󰅩 ",
                    Key = "󰌋 ",
                    Null = "󰟢 ",
                    EnumMember = " ",
                    Struct = "󰌗 ",
                    Event = " ",
                    Operator = "󰆕 ",
                    TypeParameter = "󰊄 ",
                },
            }
        end,
        post_setup = function() end,
    }
end

config.trouble = function()
    return {
        add = {
            source = "folke/trouble.nvim",
            depends = {},
            post_install = nil,
            post_checkout = nil,
        },
        require = "trouble",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function()
            local icons = require("configs.base.ui.icons")

            return {
                position = "bottom", -- position of the list can be: bottom, top, left, right
                height = 10, -- height of the trouble list when position is top or bottom
                width = 50, -- width of the list when position is left or right
                mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
                fold_open = "", -- icon used for open folds
                fold_closed = "", -- icon used for closed folds
                group = true, -- group results by file
                padding = true, -- add an extra new line on top of the list
                action_keys = { -- key mappings for actions in the trouble list
                    close = "q", -- close the list
                    cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
                    refresh = "r", -- manually refresh
                    jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
                    open_split = { "<c-x>" }, -- open buffer in new split
                    open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
                    open_tab = { "<c-t>" }, -- open buffer in new tab
                    jump_close = { "o" }, -- jump to the diagnostic and close the list
                    toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
                    toggle_preview = "P", -- toggle auto_preview
                    hover = "K", -- opens a small popup with the full multiline message
                    preview = "p", -- preview the diagnostic location
                    close_folds = { "zM", "zm" }, -- close all folds
                    open_folds = { "zR", "zr" }, -- open all folds
                    toggle_fold = { "zA", "za" }, -- toggle fold of current file
                    previous = "k", -- previous item
                    next = "j", -- next item
                },
                indent_lines = true, -- add an indent guide below the fold icons
                auto_open = false, -- automatically open the list when you have diagnostics
                auto_close = false, -- automatically close the list when you have no diagnostics
                auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
                auto_fold = false, -- automatically fold a file trouble list at creation
                signs = {
                    -- icons / text used for a diagnostic
                    error = icons.diagnostics.error,
                    warning = icons.diagnostics.warn,
                    hint = icons.diagnostics.hint,
                    information = icons.diagnostics.info,
                    other = icons.diagnostics.other,
                },
                use_diagnostic_signs = true, -- enabling this will use the signs defined in your lsp client
            }
        end,
        post_setup = function() end,
    }
end

config.mini_files = function()
    return {
        add = { source = nil, depends = {}, post_checkout = nil, post_install = nil },
        require = "mini.files",
        load = "now",
        s_load = "now",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function()
            return {
                options = {
                    open_files_do_not_replace_types = {
                        "terminal",
                        "Trouble",
                        "qf",
                        "aerial",
                        "NoNeckPain",
                        "edgy",
                    },
                    -- Whether to delete permanently or move into module-specific trash
                    permanent_delete = false,
                    -- Whether to use for editing directories
                    use_as_default_explorer = true,
                },
                mappings = {
                    close = "q",
                    go_in = "l",
                    go_in_plus = "<S-CR>",
                    go_out = "h",
                    reset = "<BS>",
                    reveal_cwd = "@",
                    show_help = "g?",
                    synchronize = "=",
                    trim_left = "<",
                    trim_right = ">",
                },
                file = {
                    [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
                    [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
                    [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
                    [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
                    ["eslint.configs.js"] = {
                        glyph = "󰱺",
                        hl = "MiniIconsYellow",
                    },
                    ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
                    ["ts.configs.json"] = { glyph = "", hl = "MiniIconsAzure" },
                    ["ts.configs.build.json"] = {
                        glyph = "",
                        hl = "MiniIconsAzure",
                    },
                    ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
                },
                windows = {
                    max_number = math.huge,
                    preview = true,
                    width_focus = 30,
                    width_nofocus = 30,
                    width_preview = 80,
                },
            }
        end,
        post_setup = function() end,
    }
end

config.boo_incline = function()
    return {
        add = { source = "b0o/incline.nvim", depends = {}, post_checkout = nil, post_install = nil },
        require = "incline",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            local colors = require("configs.base.colors").base_colors()
            local B = {}

            function B.Spacer() return { " " } end

            function B.is_type_editor(win_buf)
                local helpers = require("configs.base.utils.helpers")
                local ft_type = vim.api.nvim_get_option_value("filetype", { buf = win_buf })
                return helpers.WindowViewFiletype(ft_type, "tO") == "Editor"
            end

            function B.get_file_name(props)
                local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                local modified = vim.bo[props.buf].modified
                if filename == "" then filename = "[No name]" end
                return {
                    {
                        { " ", guifg = modified and colors.rose.hex or colors.leaf.hex, gui = "bold" },
                        B.Spacer(),
                        {
                            filename,
                            guifg = modified and colors.rose.hex or colors.leaf.hex,
                            gui = modified and "bold,italic" or "bold",
                        },
                        B.Spacer(),
                    },
                },
                    #filename + 8
            end

            function B.get_window_info(props)
                local win_id = props.win
                local win_number = vim.api.nvim_win_get_number(props.win)
                local total_windows = #vim.api.nvim_list_wins()
                local ft_type = vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_win_get_buf(props.win) })
                local color = require("configs.base.colors").vi_mode.static.mode_colors[_G.TECHDEUS_MODE]

                local helpers = require("configs.base.utils.helpers")
                return {
                    { win_number, group = "Special", gui = "italic" },
                    { " of ", guifg = color },
                    { total_windows, group = "Special", gui = "italic" },
                    { "-" },
                    { win_id, gui = "bold,italic", group = "Special" },
                    {
                        helpers.WindowViewFiletype(ft_type, "tO") == "Editor" and " " or "  ",
                        gui = "bold,italic",
                        group = "Special",
                    },
                    { helpers.WindowViewFiletype(ft_type, "combo"), gui = "bold,italic", group = "Special" },
                }
            end

            function B.toggle_feature(icon, label, condition, color)
                local f_color = condition and color.lighten(40).hex or colors.fg.hex
                return { " " .. (icon or label), guifg = f_color }, #label + 8
            end

            function B.toggle_all(buf, win)
                local icons = require("configs.base.ui.icons")
                if B.is_type_editor(buf) then
                    local s_content, s_length =
                        B.toggle_feature(icons.outline.String.icon, "SPELL", vim.wo.spell, colors.water)

                    local w_content, w_length = B.toggle_feature(
                        icons.ctrlspace.SLeft .. " " .. icons.ctrlspace.SRight,
                        "WRAP",
                        vim.wo.wrap,
                        colors.wood
                    )

                    local p_content, p_length = B.toggle_feature(
                        icons.outline.Constant.icon,
                        "PIN",
                        require("stickybuf").is_pinned(win),
                        colors.rose
                    )
                    return {
                        B.Spacer(),
                        p_content,
                        B.Spacer(),
                        s_content,
                        B.Spacer(),
                        w_content,
                        B.Spacer(),
                        group = "Special",
                        gui = "bold",
                    },
                        s_length + w_length + p_length
                end
            end

            local function is_toggleterm(bufnr) return vim.bo[bufnr].filetype == "toggleterm" end

            local function get_toggleterm_id(props)
                local id = " " .. vim.fn.bufname(props.buf):sub(6) .. " "
                return { { id, group = props.focused and "FloatTitle" or "Title" } }
            end

            local incline_opts = {
                debounce_threshold = { falling = 500, rising = 250 },
                window = {
                    zindex = 30,
                    padding = { left = 0, right = 0 },
                    margin = {
                        vertical = { top = vim.o.laststatus == 3 and 0 or 1, bottom = 0 }, -- shift to overlap window borders
                        horizontal = { left = 0, right = 0 },
                    },
                    placement = { vertical = "bottom", horizontal = "center" },
                    width = "fit",
                },
                hide = { cursorline = true },
                ignore = {
                    buftypes = {},
                    filetypes = {
                        "dashboard",
                        "alpha",
                        "aerial",
                        "incline",
                        "Minimap",
                        "Outline",
                        "Scratch",
                        "markdown",
                        "ministarter",
                    },
                    wintypes = function(winid, wintype)
                        local zen_view = package.loaded["zen-mode.view"]
                        if zen_view and zen_view.is_open() then return winid ~= zen_view.win end
                        return wintype ~= ""
                    end,
                    unlisted_buffers = false,
                    floating_wins = false,
                },
                highlight = {
                    groups = {
                        InclineNormal = { default = true, group = "Normal" },
                        InclineNormalNC = { default = true, group = "NormalNC" },
                    },
                },
                render = function(props)
                    -- local total_width = vim.api.nvim_win_get_width(props.win)
                    local toggle_content, _ = B.toggle_all(props.buf, props.win)
                    -- local right_content, _ = B.get_file_name(props)
                    -- local extra_padding_from_edge = 8
                    -- local center_padding = string.rep(" ",
                    --   (total_width - left_content_width - right_content_width - extra_padding_from_edge) / 0)
                    if is_toggleterm(props.buf) then
                        return get_toggleterm_id(props)
                    elseif props.focused then
                        return {
                            toggle_content,
                        }
                    end
                end,
            }
            require("incline").setup(incline_opts)
        end,
        post_setup = function() end,
    }
end

config.lvim_linguistics = function()
    ---@return DeusConfig
    return {
        add = {
            depends = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify", "lvim-tech/lvim-ui-config" },
            source = "lvim-tech/lvim-linguistics",
            post_checkout = nil,
            post_install = nil,
        },
        require = "lvim-linguistics",
        load = "now",
        s_load = "later", -- now | later (default)
        setup_param = "setup",
        setup_type = "full-setup", -- invoke-setup | full-setup (default)
        setup_opts = function() end,
        post_setup = function() end,
    }
end

config.wilder = function()
    return {
        enabled = true,
        add = {
            source = "gelguy/wilder.nvim",
            depends = {},
            post_install = function() vim.cmd("UpdateRemotePlugins") end,
            post_checkout = function() vim.cmd("UpdateRemotePlugins") end,
        },
        require = "wilder",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            local wilder = require('wilder')
            local icons = require("configs.base.ui.icons")
            local colors = require("configs.base.colors").base_colors()

            -- Create accent highlight
            local accent = wilder.make_hl('WilderAccent', 'Pmenu', {{a = 1}, {a = 1}, { foreground = colors.rose.darken(40).hex }})

            -- Configure popup menu with palette theme
            local popupmenu_renderer = wilder.popupmenu_renderer(
                wilder.popupmenu_palette_theme({
                    border = 'rounded',
                    max_height = '75%',
                    min_height = 0,
                    prompt_position = 'top',
                    reverse = 0,
                    empty_message = wilder.popupmenu_empty_message_with_spinner(),
                    highlighter = wilder.basic_highlighter(),
                    highlights = {
                        accent = accent,
                        border = 'Normal',
                    },
                    left = {
                        ' ',
                        wilder.popupmenu_devicons(),
                        wilder.popupmenu_buffer_flags({
                            flags = ' a + ',
                            icons = {
                                ['+'] = icons.ui.Pencil,
                                a = icons.documents.File,
                                h = icons.documents.FileEmpty,
                            },
                        }),
                    },
                    right = {
                        ' ',
                        wilder.popupmenu_scrollbar(),
                    },
                })
            )

            local wildmenu_renderer = wilder.wildmenu_renderer({
                highlighter = wilder.basic_highlighter(),
                highlights = { accent = accent },
                separator = ' | ',
                left = { ' ', wilder.wildmenu_spinner(), ' ' },
                right = { ' ', wilder.wildmenu_index() },
            })
            -- Create the initialization function
            local function wilder_init()
                wilder.setup({
                    modes = { ':', '/', '?' },
                    next_key = '<Tab>',
                    previous_key = '<S-Tab>',
                    accept_key = '<Down>',
                    reject_key = '<Up>',
                })

                -- Enhanced pipeline with Python features
                wilder.set_option('pipeline', {
                    wilder.branch(
                        wilder.python_file_finder_pipeline({
                            file_command = { 'rg', '--files', '--hidden' },
                            dir_command = { 'fd', '-td' },
                            filters = {'fuzzy_filter', 'difflib_sorter'},
                        }),
                       wilder.cmdline_pipeline({ language = 'python', fuzzy = 2 }),
                        wilder.python_search_pipeline({
                            pattern = wilder.python_fuzzy_delimiter_pattern(),
                            sorter = wilder.python_difflib_sorter(),
                            engine = 're',
                        })
                    ),
                })

                -- Set renderer
                wilder.set_option(
                    'renderer',
                    wilder.renderer_mux({
                        [':'] = popupmenu_renderer,
                        ['/'] = popupmenu_renderer,
                        ['?'] = popupmenu_renderer,
                        substitute = wildmenu_renderer,
                    })
                )
            end

            -- Create the autocmd for delayed initialization
            vim.api.nvim_create_autocmd("CmdlineEnter", {
                callback = function()
                    wilder_init()
                    return true  -- Remove the autocmd after first trigger
                end,
                once = true,
            })
        end,
        post_setup = function()
            vim.cmd("UpdateRemotePlugins")
        end,
    }
end

return config
