local config = {}
config.sidebar = function()
    return {
        add = { source = "sidebar-nvim/sidebar.nvim", depends = {}, post_install = nil, post_checkout = nil },
        require = "sidebar-nvim",
        setup_type = "invoke-setup",
        setup_param = "setup",
        load = "now",
        s_load = "later",
        setup_opts = function()
            local Sidebar = require("sidebar-nvim")

            local function get_current_window() return vim.api.nvim_get_current_win() end

            local function get_current_buffer() return vim.api.nvim_get_current_buf() end

            local function get_current_tabpage() return vim.api.nvim_tabpage_get_number(0) end

            local function sidebar_active_info()
                local Loclist = require("sidebar-nvim.components.loclist")
                local loclist = Loclist:new({
                    omit_single_group = false,
                    show_group_count = false,
                })
                local loclist_items = {}
                local function get_important_info(ctx)
                    local lines = {}
                    local hl = {}
                    loclist_items = {}

                    local info_sections = { "tabpage", "window", "buffer" }

                    for k, section in ipairs(info_sections) do
                        if section == "tabpage" then
                            table.insert(loclist_items, {
                                group = section,
                                left = { { text = " T-" .. get_current_tabpage(), hl = "SidebarNvimNormal" } },
                                order = k,
                            })
                        end
                        if section == "window" then
                            table.insert(loclist_items, {
                                group = section,
                                left = { { text = " W-" .. get_current_window(), hl = "SidebarNvimNormal" } },
                                order = 2,
                            })
                        end
                        if section == "buffer" then
                            table.insert(loclist_items, {
                                group = section,
                                left = { { text = " B-" .. get_current_buffer(), hl = "SidebarNvimNormal" } },
                                order = 3,
                            })
                        end
                        loclist:set_items(loclist_items, { remove_groups = true })
                    end
                    loclist:draw(ctx, lines, hl)

                    if lines == nil or #lines == 0 then
                        return "<no acitve info>"
                    else
                        return { lines = lines, hl = hl }
                    end
                end

                return {
                    title = "Active Info",
                    icon = "->",
                    draw = function(ctx) return get_important_info(ctx) end,
                    highlights = {
                        groups = {},
                        links = {
                            SidebarNvimBuffersActive = "SidebarNvimSectionTitle",
                            SidebarNvimBuffersNumber = "SidebarNvimBuffersNumber",
                        },
                    },
                    bindings = {},
                }
            end

            local function sidebar_window_info()
                local Loclist = require("sidebar-nvim.components.loclist")
                local loclist = Loclist:new({
                    omit_single_group = false,
                    show_group_count = false,
                })
                local loclist_items = {}
                local function get_windows(ctx)
                    local lines = {}
                    local hl = {}
                    loclist_items = {}

                    local all_windows = vim.api.nvim_list_wins()

                    for _, win in pairs(all_windows) do
                        local current_win = vim.api.nvim_get_current_win()

                        local curr_group = tostring("Window-" .. win)
                        loclist:add_group(curr_group)

                        local current_win_tabpage = vim.api.nvim_win_get_tabpage(win)
                        local current_win_buffer = vim.api.nvim_win_get_buf(win)
                        local current_win_number = vim.api.nvim_win_get_number(win)
                        local current_win_height = vim.api.nvim_win_get_height(win)
                        local current_win_width = vim.api.nvim_win_get_width(win)
                        local current_win_cursor = vim.api.nvim_win_get_cursor(win)
                        local current_win_position = vim.api.nvim_win_get_position(win)
                        local current_win_config = vim.api.nvim_win_get_config(win)
                        local current_win_relative = current_win_config.relative
                        local current_win_type = current_win_relative ~= "" and "Float" or "Regular"

                        local name_hl = "SidebarNvimNormal"
                        local is_current = ""

                        if win == current_win then
                            name_hl = "SidebarNvimBuffersActive"
                            is_current = "* "
                        end

                        local window_is_current = { text = is_current, hl = name_hl }

                        local window_number = "#" .. current_win_number .. " "
                        local window_text = current_win_type
                            .. " T-"
                            .. current_win_tabpage
                            .. " B-"
                            .. current_win_buffer

                        table.insert(loclist_items, {
                            group = curr_group,
                            left = {
                                window_is_current,
                                {
                                    text = window_number,
                                    hl = is_current ~= "" and "SidebarNvimBuffersActive" or "SidebarNvimNormal",
                                },
                                {
                                    text = window_text,
                                    hl = is_current ~= "" and "SidebarNvimBuffersActive" or "SidebarNvimNormal",
                                },
                            },
                            order = 1,
                        })

                        local window_specs = " Lin-" .. current_win_height .. " Col-" .. current_win_width

                        table.insert(loclist_items, {
                            group = curr_group,
                            left = { { text = window_specs, hl = "SidebarNvimNormal" } },
                            order = 2,
                        })

                        local window_pos = " Cur-"
                            .. table.concat(current_win_cursor, ", ")
                            .. " Pos-"
                            .. table.concat(current_win_position, ", ")

                        table.insert(loclist_items, {
                            group = curr_group,
                            left = { { text = window_pos, hl = "SidebarNvimNormal" } },
                            order = 3,
                        })

                        loclist:set_items(loclist_items, { remove_groups = true })
                    end

                    loclist:draw(ctx, lines, hl)
                    if lines == nil or #lines == 0 then
                        return "<no windows>"
                    else
                        return { lines = lines, hl = hl }
                    end
                end

                return {
                    title = "Windows",
                    icon = " ",
                    draw = function(ctx) return get_windows(ctx) end,
                    highlights = {
                        groups = {},
                        links = {
                            SidebarNvimBuffersActive = "SidebarNvimSectionTitle",
                            SidebarNvimBuffersNumber = "SidebarNvimBuffersNumber",
                        },
                    },
                    bindings = {
                        ["d"] = function(line)
                            local location = loclist:get_location_at(line)

                            if location == nil then return end

                            local window = location.data.window
                            local is_current = vim.api.nvim_get_current_win() == window
                            local buffer = vim.api.nvim_win_get_buf(window)

                            if is_current then
                                local action = vim.fn.input(
                                    'window "'
                                        .. location.data.window
                                        .. '" has been modified. [w]rite/[d]iscard/[c]ancel: '
                                )

                                if action == "w" then
                                    vim.api.nvim_buf_call(buffer, function() vim.cmd("silent! w") end)
                                    vim.api.nvim_buf_delete(buffer, { force = true })
                                elseif action == "d" then
                                    vim.api.nvim_buf_delete(buffer, { force = true })
                                end
                            else
                                vim.api.nvim_buf_delete(buffer, { force = true })
                            end
                        end,
                        ["e"] = function(line)
                            local location = loclist:get_location_at(line)
                            if location == nil then return end

                            vim.cmd("wincmd p")
                            vim.cmd("e " .. location.data.filepath)
                        end,
                        ["w"] = function(line)
                            local location = loclist:get_location_at(line)

                            if location == nil then return end

                            vim.api.nvim_buf_call(location.data.buffer, function() vim.cmd("silent! w") end)
                        end,
                        ["t"] = function(line) loclist:toggle_group_at(line) end,
                        ["p"] = function(line, col) print("current window: " .. line .. col) end,
                    },
                }
            end

            -- local function sidebar_options_info()
            --     local Loclist = require("sidebar-nvim.components.loclist")
            --     local loclist = Loclist:new({
            --         omit_single_group = false,
            --         show_group_count = false,
            --     })
            --     local loclist_items = {}
            --     -- local data_options_items = {}

            --     local function get_keys(t)
            --         local keys = {}
            --         for key, _ in pairs(t) do
            --             table.insert(keys, key)
            --         end
            --         return keys
            --     end
            --     local Spacer = tostring("        ")

            --     local function add_option_details(option, option_details)
            --         local option_keys = get_keys(option_details)
            --         table.sort(option_keys)

            --         for _, key in ipairs(option_keys) do
            --             local value = option_details[key]
            --             local text_left
            --             local text_right

            --             if type(value) == "table" then
            --                 text_left = tostring(key)
            --                 text_right = table.concat(value, " | ")
            --             else
            --                 text_left = tostring(key)
            --                 text_right = tostring(value)
            --             end

            --             table.insert(loclist_items, {
            --                 group = option,
            --                 lnum = 1,
            --                 col = 4,
            --                 left = {
            --                     { text = text_left, hl = "SectionMarker" },
            --                     { text = Spacer },
            --                 },
            --                 right = {
            --                     { text = text_right, hl = "Comment" },
            --                     { text = Spacer },
            --                 },
            --                 name = option,
            --             })
            --         end
            --     end
            -- end

            -- local function get_all_options_info()
            --     local all_options = vim.api.nvim_get_all_options_info()

            --     local all_o_sorted_keys = get_keys(all_options)

            --     table.sort(all_o_sorted_keys)

            --     -- data_options_items = {}
            --     loclist_items = {}

            --     for _, option in ipairs(all_o_sorted_keys) do
            --         local option_details = all_options[option]

            --         loclist:add_group(option)

            --         -- table.insert(data_options_items, { option = option_details })

            --         add_option_details(option, option_details)
            --     end

            --     loclist:set_items(loclist_items, { remove_groups = false })

            --     return {
            --         title = "Options",
            --         icon = "->",
            --         draw = function(ctx)
            --             local lines = {}
            --             local hl = {}

            --             get_all_options_info()

            --             loclist:draw(ctx, lines, hl)

            --             if lines == nil or #lines == 0 then
            --                 return "<no options>"
            --             else
            --                 return { lines = lines, hl = hl }
            --             end
            --         end,
            --         highlights = {
            --             groups = {
            --                 MyHighlightGroup = {
            --                     gui = "bold,italic",
            --                     fg = "#ffffff",
            --                     bg = "#00ff00",
            --                 },
            --             },
            --             links = { MyHighlightGroupLink = "Keyword" },
            --         },
            --         bindings = {
            --             ["t"] = function(line) loclist:toggle_group_at(line) end,
            --             ["e"] = function(line, col) print("current option: " .. line .. col) end,
            --         },
            --     }
            -- end
            local sidebar_opts = function()
                local active_info_config = sidebar_active_info()
                local windows_config = sidebar_window_info()
                -- local tabpage_config = require('plugins.sidebar.s_tabpages')
                -- local uis_configs = require('plugins.sidebar.s_misc')
                -- local buffers_config = require('plugins.sidebar.s_buffers')

                local opts = {
                    disable_default_keybindings = 0,
                    open = false,
                    side = "right",
                    initial_width = 35,
                    hide_statusline = false,
                    update_interval = 1000,
                    sections = {
                        "datetime",
                        active_info_config,
                        "buffers",
                        windows_config,
                        "files",
                        "diagnostics",
                        "todos",
                        "containers",
                        -- 'git',
                        -- tabpage_config,
                        -- uis_configs,
                        -- buffers_config,
                    },
                    section_separator = { "", "-----", "" },
                    section_title_separator = { "" },
                    ["diagnostics"] = {
                        icon = "",
                    },
                    ["git"] = {
                        icon = "",
                    },
                    bindings = {
                        ["q"] = function() require("sidebar-nvim").close() end,
                        ["<localleader>sT"] = function() require("sidebar-nvim").toggle() end,
                        ["<localleader>sO"] = function() require("sidebar-nvim").open() end,
                        ["<localleader>sC"] = function() require("sidebar-nvim").close() end,
                    },
                    symbols = {
                        icon = "ƒ",
                    },
                    buffers = {
                        icon = "",
                        ignored_buffers = {}, -- ignore buffers by regex
                        sorting = "id", -- alternatively set it to "name" to sort by buffer name instead of buf id
                        show_numbers = true, -- whether to also show the buffer numbers,
                        ignore_not_loaded = false, -- whether to ignore not loaded buffers
                        ignore_terminal = false, -- whether to show terminal buffers in the list
                    },
                    files = {
                        icon = "",
                        show_hidden = false,
                        ignored_paths = { "%.git$" },
                        initially_closed = true,
                    },
                    containers = {
                        icon = "",
                        use_podman = true,
                        enabled = false,
                        attach_shell = "/bin/zsh",
                        show_all = true, -- whether to run `docker ps` or `docker ps -a`
                        interval = 5000, -- the debouncer time frame to limit requests to the docker daemon
                    },
                    todos = {
                        icon = "",
                        ignored_paths = { "~" }, -- ignore certain paths, this will prevent huge folders like $HOME to hog Neovim with TODO searching
                        initially_closed = true, -- whether the groups should be initially closed on start. You can manually open/close groups later.
                    },
                }
                return opts
            end

            Sidebar.setup(sidebar_opts())
        end,
        post_setup = function() end,
    }
end

config.obsidian = function()
    return {
        add = { source = "epwalsh/obsidian.nvim", depends = { "Vinzent03/obsidian-advanced-uri" }, post_install = nil, post_checkout = nil },
        require = "obsidian",
        setup_type = "invoke-setup",
        setup_param = "setup",
        load = "now",
        s_load = "later",
        pre_setup = function()
            vim.cmd([[ autocmd BufReadPre *.md <buffer> function() return vim.fn.expand("~") .. "/techdeus/work/notes/**.md" end ]]) 
            vim.cmd([[ autocmd BufNewFile *.md <buffer> function() return vim.fn.expand("~") .. "/techdeus/work/notes/**.md" ]]) 
            -- mappings = {
              -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
            --   ["gf"] = {
            --     action = function() return require("obsidian").util.gf_passthrough() end,
            --     opts = { noremap = false, expr = true, buffer = true },
            --   },
            --   -- Toggle check-boxes.
            --   ["<leader>ch"] = {
            --     action = function() return require("obsidian").util.toggle_checkbox() end,
            --     opts = { buffer = true },
            --   },
            --   -- Smart action depending on context, either follow link or toggle checkbox.
            --   ["<cr>"] = {
            --     action = function() return require("obsidian").util.smart_action() end,
            --     opts = { buffer = true, expr = true },
            --   },
            -- },
        end,
        setup_opts = function()
         local opts = {
            completion = { nvim_cmp = true, min_chars = 2 },
            log_level = vim.log.levels.INFO,
            new_notes_location = "~/techdeus/work/notes",
            workspaces = {
                { name = "work", path = "~/techdeus/work/notes/" },
                { name = "personal", path = "~/techdeus/home/notes/" },
                {
                    name = "no-vault",
                    path = function() return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0))) end,
                    overrides = {
                        notes_subdir = vim.NIL, -- have to use 'vim.NIL' instead of 'nil'
                        new_notes_location = "current_dir",
                        templates = {
                            folder = vim.NIL,
                        },
                        disable_frontmatter = true,
                    },
                },
            },
            use_advanced_uri = true,
            open_app_foreground = true,
            picker = {
                me = "mini.picker",
                mappings = {
                    new = "<C-x>",
                    insert_link = "<C-l>",
                },
            },
            ui = {
                enable = true, -- set to false to disable all additional syntax features
                update_debounce = 200, -- update delay after a text change (in milliseconds)
                max_file_length = 5000, -- disable UI features for files with more than this many lines
                -- Define how various check-boxes are displayed
                checkboxes = {
                    [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                    ["x"] = { char = "", hl_group = "ObsidianDone" },
                    [">"] = { char = "", hl_group = "ObsidianRightArrow" },
                    ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
                    ["!"] = { char = "", hl_group = "ObsidianImportant" },
                },
                sort_by = "modified",
                sort_reversed = true,
                search_max_lines = 1000,
                open_notes_in = "vsplit",
                bullets = { char = "•", hl_group = "ObsidianBullet" },
                external_link_icon = {
                    char = "",
                    hl_group = "ObsidianExtLinkIcon",
                },
                reference_text = { hl_group = "ObsidianRefText" },
                highlight_text = { hl_group = "ObsidianHighlightText" },
                tags = { hl_group = "ObsidianTag" },
                block_ids = { hl_group = "ObsidianBlockID" },
                hl_groups = {
                    ObsidianTodo = { bold = true, fg = "#f78c6c" },
                    ObsidianDone = { bold = true, fg = "#89ddff" },
                    ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
                    ObsidianTilde = { bold = true, fg = "#ff5370" },
                    ObsidianImportant = { bold = true, fg = "#d73128" },
                    ObsidianBullet = { bold = true, fg = "#89ddff" },
                    ObsidianRefText = { underline = true, fg = "#c792ea" },
                    ObsidianExtLinkIcon = { fg = "#c792ea" },
                    ObsidianTag = { italic = true, fg = "#89ddff" },
                    ObsidianBlockID = { italic = true, fg = "#89ddff" },
                    ObsidianHighlightText = { bg = "#75662e" },
                },
            },
         }
         require("obsidian").setup(opts)
        end,
        post_setup = function() end
    }
end

config.calendar = function()                                                 
    return { --[Calendar]-launch google calendar within neovim                  
        add = { source = "itchyny/calendar.vim", depends = {}, post_install = nil, post_checkout = nil },                              
        require = "calendar",                                                   
        setup_type = "invoke-setup",                               
        setup_params = "setup",                                  
        load = "later",
        s_load = "later",
        setup_opts = function() end,
        post_setup = function()                                       
            vim.g.calendar_google_calendar = 1                        
            vim.g.calendar_google_task = 1                                   
            vim.g.calendar_debug = 1                                         
            vim.g.calendar_cache_directory = "~/.cache/calendar.vim"
        end,                                                                
    }
end

return config
