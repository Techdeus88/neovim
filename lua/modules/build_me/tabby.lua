local config = {}

local function rename_tab()
    local ui_config = require("modules.build_me.base.config")
    local select = require("modules.build_me.base.select")

    -- Predefined options
    local options = {
         "Dev",
         "Frontend" ,
         "Backend"  ,
         "Terminal" ,
         "Services" ,
         "Testing"  ,
         "Docs"     ,
         "Help"     ,
         "Configs"  ,
         "Custom",
    }

    -- Format options for display
    local function format_option(option)
        return string.format("%s", option)
    end

    local tabname = ""
    local opts = ui_config.select(options, { prompt = "Select tab name (" .. tabname .. ")", format_item = format_option }, {})

    select(opts, function(choice)
            if not choice then
                return -- User cancelled
            end

            if choice == "Custom" then
                -- Show input prompt for custom name
                 vim.ui.input(
                    {
                        prompt = "Enter custom tab name: ",
                        default = "",
                    },
                    function(custom_name)
                        if custom_name and #custom_name > 0 then
                            -- Call tabby's rename function with custom name
                            require("tabby.feature.tab_name").set(0, custom_name)
                        end
                    end
                )
            else
                -- Use selected predefined name
                require("tabby.feature.tab_name").set(0, choice)
            end
        end
    )
end

config.tabby_nvim = function()
    return {
        add = { source = "nanozuki/tabby.nvim", depends = {}, post_checkout = nil, post_install = nil },
        require = "tabby.tabline",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",

        setup_opts = function()
            local Tabby = require("tabby")
            local util = require('tabby.util')
            local BaseColors = require("configs.base.colors").base_colors()
            local BaseIcons = require("configs.base.ui.icons")
            --
            -- local hl_tabline_fill = util.extract_nvim_hl('lualine_c_normal')
            -- local hl_tabline = util.extract_nvim_hl('lualine_b_normal')
            -- local hl_tabline_sel = util.extract_nvim_hl('lualine_a_normal')

            local Theme = {
                fill = "TabLine",
                -- tabwinfill = { fg = '#f2e9de', bg = '#907aa9', style = 'italic' },
                separator = { fg = BaseColors.fg.hex, bg = BaseColors.bg.hex },
                tab = "TabLine",

                current_tab = "TabLine",
                -- current_tab = { bg=BaseColors.leaf.darken(40).hex, fg=BaseColors.leaf.lighten(30).hex, style='italic' },
                -- current_window = { bg = BaseColors.rose.darken(40).hex, fg = BaseColors.rose.lighten(30).hex, style='italic' },
                win = { fg = "#ffffff", bg = "#222222" },
                win_separator = { fg = "", bg = "#222222" },
                current_win = { fg = "#ffffff", bg = BaseColors.fg.darken(30).hex},
                tail = "TabLine",
            }
            local tab_names = {
                    { id = 1, label = "Dev",    icon = BaseIcons.ui.Test },
                    { id = 2, label = "Frontend",     icon = BaseIcons.ui.Test },
                    { id = 3, label = "Backend",     icon = BaseIcons.ui.Test },
                    { id = 4, label = "Terminal",   icon = BaseIcons.ui.Test },
                    { id = 5, label = "Services",    icon = BaseIcons.ui.Test },
                    { id = 6, label = "Testing",   icon = BaseIcons.ui.Test },
                    { id = 7, label = "Docs",   icon = BaseIcons.ui.Test },
                    { id = 8, label = "Help",   icon = BaseIcons.ui.Test },
                    { id = 9, label = "Configs", icon = BaseIcons.ui.Test },
                }

            local TabInfo = function(tab_id)
                local tabs = {
                    { id = 1, label = "Dev",    icon = BaseIcons.ui.Test },
                    { id = 2, label = "Frontend",     icon = BaseIcons.ui.Test },
                    { id = 3, label = "Backend",     icon = BaseIcons.ui.Test },
                    { id = 4, label = "Terminal",   icon = BaseIcons.ui.Test },
                    { id = 5, label = "Services",    icon = BaseIcons.ui.Test },
                    { id = 6, label = "Testing",   icon = BaseIcons.ui.Test },
                    { id = 7, label = "Docs",   icon = BaseIcons.ui.Test },
                    { id = 8, label = "Help",   icon = BaseIcons.ui.Test },
                    { id = 9, label = "Configs", icon = BaseIcons.ui.Test },
                }
                for _, tab in ipairs(tabs) do
                    if tab.id == tab_id then return tab end
                end
                return { id = nil, label = nil, icon = nil }
            end

            local GitBranch = function()
                if vim.fn.isdirectory(".git") ~= 0 then
                    local git_branch = vim.fn.system("git branch --show-current | tr -d '\n'")
                    return {
                        { "", hl = { fg = BaseColors.leaf.darken(30).hex, bg = BaseColors.bg.hex } },
                        BaseIcons.git.Branch .. " " ..  git_branch .. " ", hl = { fg = BaseColors.fg.hex, bg = BaseColors.leaf.darken(30).hex },
                    }
                end
            end

            local DeusWinFileIcon = function(ft)
                local MiniIcon = require("mini.icons").get("extension", ft)
                -- local GetWindowFileType = require("configs.base.utils.helpers").WindowViewFiletype
                local FileTypeIcon = MiniIcon ~= nil and MiniIcon or BaseIcons.documents.File
                -- local WinTypeIcon = GetWindowFileType(ft, "separate").icon
                return { " " .. FileTypeIcon .. " " }
            end

            local DeusWinLabel = function(ft)
                local GetWindowFileType = require("configs.base.utils.helpers").WindowViewFiletype
                local WindowType = GetWindowFileType(ft, "separate").text
                return { WindowType == "Editor" and ft or WindowType }

            end
            -- if vim.bo[vim.api.nvim_win_get_buf(win)].modified then return "" end
            local Spacer = function(spaces) return { string.rep(" ", spaces) } end

            local BuildWindow = function(win, tab, line, idx)
                local TabbyApi = require("tabby.module.api")
                local WinId = win.id
                local IsWindowCurrent = win.is_current()
                local IsTabCurrent = tab.is_current()
                local WinNumber = vim.api.nvim_win_get_number(WinId)
                local buffer = TabbyApi.get_win_buf(WinId)
                local BufChanged = TabbyApi.get_buf_is_changed(buffer)
                local BufFileType = vim.bo[buffer].filetype
                local GetIcons = function(ft) return DeusWinFileIcon(ft) end
                local GetLabel = function(ft) return DeusWinLabel(ft) end


                local hlWin = IsWindowCurrent and Theme.current_win or Theme.win
               if IsTabCurrent then
                return {
                     line.sep('', { fg = IsWindowCurrent and BaseColors.leaf.darken(30).hex or "#ffffff", bg = idx == 1 and BaseColors.bg1.hex or "#222222", style = IsWindowCurrent and 'Italic,Bold' or 'bold' }, { bg = "#222222", fg = "" }),
                    GetIcons(BufFileType),
                    GetLabel(BufFileType),
                    hl = { bg = "#222222", fg = IsWindowCurrent and BaseColors.leaf.darken(30).hex or "#ffffff", style = 'bold' },
                }
                end

                return {
                  Spacer(2),
                  WinNumber,
                  Spacer(2),
                  hl = { bg = "#222222", fg = "#ffffff", style = 'bold' },
                }
            end

            Tabby.setup({
                line = function(line)
                    return {
                        {
                            { '  ', hl = { fg = BaseColors.fg.hex, bg = BaseColors.leaf.darken(30).hex } },
                            { '', hl = { fg = BaseColors.leaf.darken(30).hex, bg = BaseColors.bg.hex } },
                        },

                        line.tabs().foreach(function(tab)
                            local IsTabCurrent = tab.is_current()
                            local CurrentWindow = tab.current_win()
                            local TabInfoDetail = TabInfo(tab.id)
                            local hlTab = IsTabCurrent and Theme.current_tab or Theme.tab
                            local hlWin = Theme.win

                            local wins = line.wins_in_tab(tab.id)
                            local WindowTabs = wins.foreach(function(win, idx)
                                local RWin = BuildWindow(win, tab, line, idx)
                                return RWin
                            end)

                            return {
                                Spacer(8),
                                {
                                    line.sep("", { fg = "#ffffff", bg = BaseColors.bg1.hex, style = 'bold' }, { bg = BaseColors.bg.hex, fg = "" }),
                                    { tab.is_current() and "" or "󰆣", hl = { fg = tab.is_current() and BaseColors.rose.lighten(40).hex or "#ffffff", bg = BaseColors.bg1.hex}},
                                    { "  " .. tab.name() .. " "},
                                    line.sep('', { fg = "#ffffff", bg = BaseColors.bg1.hex, style = 'bold' }, { bg = BaseColors.bg1.hex, fg = "" }),
                                    hl = { fg = "#ffffff", bg = BaseColors.bg1.hex, style = 'bold' }
                                },
                                WindowTabs,
                                line.sep('', hlWin, { bg = BaseColors.bg.hex, fg = "" }),
                            }
                        end),
                        line.spacer(),
                        line.truncate_point(),
                        {
                            GitBranch(),
                            hl = Theme.fill,
                        },
                    }
                end,
                option = {
                    lualine_theme = "bubble",
                    tab_name = {
                        name_fallback = function(tabid)
                            return tabid
                        end,
                    },
                    buttons = {
                        {
                            name = "Rename",
                            action = rename_tab,
                        }
                    }
                }
            })
        end,
        post_setup = function()
            vim.api.nvim_set_keymap("n", "<leader>ta", ":$tabnew<CR>", { noremap = true })
            vim.api.nvim_set_keymap("n", "<leader>tc", ":tabclose<CR>", { noremap = true })
            vim.api.nvim_set_keymap("n", "<leader>to", ":tabonly<CR>", { noremap = true })
            vim.api.nvim_set_keymap("n", "<leader>tn", ":tabn<CR>", { noremap = true })
            vim.api.nvim_set_keymap("n", "<leader>tp", ":tabp<CR>", { noremap = true })
            -- move current tab to previous position
            vim.api.nvim_set_keymap("n", "<leader>tmp", ":-tabmove<CR>", { noremap = true })
            -- move current tab to next position
            vim.api.nvim_set_keymap("n", "<leader>tmn", ":+tabmove<CR>", { noremap = true })
            -- You can then bind this to a key or command
            vim.api.nvim_create_user_command("TabRename", rename_tab, {})
            vim.keymap.set("n", "<leader>tR", ":TabRename<CR>", { noremap = true })
        end,
    }
end

return config
