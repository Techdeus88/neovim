local M = {}

function M.get_winbar()
    local colors = require("configs.base.colors").base_colors()
    local heirline_conditions = require("heirline.conditions")
    local heirline_utils = require("heirline.utils")

    local bit = require("bit")
    local icons = require("configs.base.ui.icons")
    local Spacer = {
        provider = " ",
    }
    local typed_hl = require("configs.base.ui.highlight")
    local CloseButton = {
        static = {
            modified = vim.bo[0].modified,
        },
        -- a small performance improvement:
        -- re register the component callback only on layout/buffer changes.
        update = { "WinNew", "WinClosed", "BufEnter" },
        { provider = " " },
        {
            provider = function(self)
                self.modified = vim.bo[0].modified
                local icon = self.modified and icons.ui.Modified or icons.ui.Close
                return " " .. icon .. " "
            end,
            hl = function(self)
                return {
                    fg = self.modified and colors.rose.hex or colors.leaf.lighten(20).hex,
                    bold = true,
                }
            end,
            on_click = {
                minwid = function() return vim.api.nvim_get_current_win() end,
                callback = function(_, minwid) vim.api.nvim_win_close(minwid, true) end,
                name = "heirline_winbar_close_button",
            },
        },
        hl = function(self)
            return {
                fg = self.modified and colors.rose.hex or colors.leaf.lighten(20).hex,
                bold = true,
            }
        end,
    }

    local DeusFileName = {
        static = {
            modified = vim.bo[0].modified,
        },
        provider = function(self)
            local fn = vim.api.nvim_buf_get_name(0)
            local filename = vim.fn.fnamemodify(fn, ":t")
            local is_modified = vim.bo[0].modified
            self.modified = is_modified
            if filename == "" then filename = "[No name]" end
            return filename
        end,
        hl = function(self)
            return {
                fg = self.modified and colors.rose.hex or colors.leaf.lighten(20).hex,
                bold = true,
            }
        end,
    }

    local Filepath = {
        static = {
            modifiers = {
                dirname = ":s?/Users/AgentSullivan/.config/Techdeus/lua/s?/Users/AgentSullivan/Code?Code?",
            },
        },
        init = function(self)
            self.current_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
            self.filepath = vim.fn.fnamemodify(self.current_dir, self.modifiers.dirname or nil)
            self.short_path = vim.fn.fnamemodify(vim.fn.expand("%:h"), self.modifiers.dirname or nil)
            if self.filepath == "" then self.filepath = "[No Name]" end
        end,
        hl = { fg = colors.fg.lighten(20).hex, bold = true },
        {
            provider = function(self)
                local filepath = vim.fn.pathshorten(self.short_path)
                return " " .. filepath
            end,
        },
        {
            condition = function(self) return self.filepath ~= "." end,
            on_click = {
                callback = function(self)
                    require("telescope.builtin").find_files({
                        cwd = self.current_dir,
                    })
                end,
                name = "wb_path_click",
            },
        },
    }

    local Space = { provider = " ", hl = { bg = colors.bg.hex, fg = colors.fg.hex } }
    local Align = { provider = "%=", hl = { bg = colors.bg.hex, fg = colors.fg.hex } }

    -- Use it anywhere!
    local WinBarFileName = heirline_utils.surround({ "", "" }, "", {
        hl = function()
            if not heirline_conditions.is_active() then return { fg = "gray", force = true } end
        end,
        DeusFileName,
        CloseButton,
    })

    local FileIcon = {
        init = function(self)
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
            self.icon, self.icon_color = require("mini.icons").get("file", filename)
        end,
        provider = function(self) return self.icon and (" " .. self.icon .. " ") end,
        hl = function(self) return { fg = self.icon_color } end,
    }

    local FileType = {
        condition = function() return vim.bo.filetype ~= "" end,
        FileIcon,
        hl = "HeirlineWinbar",
    }

    -- local FileName = {
    --   static = {
    --     modifiers = {
    --       dirname = ":s?/Users/AgentSullivan/:s?.config/Techdeus/lua?Neovim?:s?/Users/AgentSullivan/Code?Code?",
    --     },
    --   },
    --   init = function(self)
    --     local filename
    --     if not filename then
    --       filename =
    --           vim.fn.fnamemodify(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":."), self.modifiers.dirname or nil)
    --     end
    --     if filename == "" then
    --       self.path = ""
    --       self.name = "[No Name]"
    --       return
    --     end
    --     -- now, if the filename would occupy more than 90% of the available
    --     -- space, we trim the file path to its initials
    --     if not heirline_conditions.width_percent_below(#filename, 0.90) then filename = vim.fn.pathshorten(filename) end

    --     self.path = filename:match("^(.*)/")
    --     self.name = filename:match("([^/]+)$")
    --   end,
    --   {
    --     provider = function(self)
    --       if self.path then return self.path .. "/" end
    --     end,
    --     hl = "HeirlineWinbar",
    --   },
    --   {
    --     provider = function(self) return self.name end,
    --     hl = "HeirlineWinbarEmphasis",
    --   },
    --   on_click = {
    --     callback = function(self) require("aerial").toggle() end,
    --     name = "wb_filename_click",
    --   },
    -- }
    local WorkDir = {
        provider = function()
            local icon = "  " .. (vim.fn.haslocaldir(0) == 1 and "l " or " g ")
            local cwd = vim.fn.getcwd(0)
            cwd = vim.fn.fnamemodify(cwd, ":~")
            if not heirline_conditions.width_percent_below(#cwd, 0.25) then cwd = vim.fn.pathshorten(cwd) end
            local trail = cwd:sub(-1) == "/" and "" or "/"
            return icon .. cwd:upper() .. trail
        end,

        hl = { fg = colors.leaf.lighten(20).hex },
    }
    local FileFlags = {
        static = {
            modified = vim.bo[0].modified,
        },
        {
            provider = function(self)
                local is_modified = vim.bo[0].modified
                self.modified = is_modified
                return " "
            end,
            hl = function(self)
                return {
                    fg = self.modified and colors.rose.hex or colors.leaf.lighten(20).hex,
                    bold = true,
                }
            end,
        },
        {
            condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
            provider = " ",

            hl = function(self)
                return {
                    fg = self.modified and colors.rose.hex or colors.leaf.lighten(20).hex,
                    bold = true,
                }
            end,
        },
    }

    local Git = {
        condition = heirline_conditions.is_git_repo,

        init = function(self)
            self.status_dict = vim.b.gitsigns_status_dict
            self.has_changes = self.status_dict.added ~= 0
                or self.status_dict.removed ~= 0
                or self.status_dict.changed ~= 0
        end,

        hl = { fg = "orange" },
        -- You could handle delimiters, icons and counts similar to Diagnostics
        {
            condition = function(self) return self.has_changes end,
            provider = "(",
        },
        {
            provider = function(self)
                local count = self.status_dict.added or 0
                return count > 0 and ("+" .. count)
            end,
            hl = { fg = "git_add" },
        },
        {
            provider = function(self)
                local count = self.status_dict.removed or 0
                return count > 0 and ("-" .. count)
            end,
            hl = { fg = "git_del" },
        },
        {
            provider = function(self)
                local count = self.status_dict.changed or 0
                return count > 0 and ("~" .. count)
            end,
            hl = { fg = "git_change" },
        },
        {
            condition = function(self) return self.has_changes end,
            provider = ")",
        },
        { -- git branch name
            provider = function(self) return " " .. self.status_dict.head end,
            hl = { bold = true },
        },
    }

    -- local Symbols = {
    -- init = function(self) self.symbols = require("aerial").get_location(true) or {} end,
    -- update = "CursorMoved",
    -- {
    --   condition = function(self)
    --     if vim.tbl_isempty(self.symbols) then return false end
    --     return true
    --   end,
    --   {
    --     flexible = 3,
    --     {
    --       provider = function(self)
    --         local symbols = {}
    --         table.insert(symbols, { provider = Separator })
    --
    --         for i, d in ipairs(self.symbols) do
    --           local symbol = {
    --             -- Name
    --             { provider = string.gsub(d.name, "%%", "%%%%"):gsub("%s *-> %s*", "") },
    --             -- On-Click action
    --             on_click = {
    --               minwid = self.encode_pos(d.lnum, d.col, self.winnr),
    --               callback = function(_, minwid)
    --                 local lnum, col, winnr = self.decode_pos(minwid)
    --                 vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { lnum, col })
    --               end,
    --               name = "wb_symbol_click",
    --             },
    --           }
    --           -- Icon
    --           local hlgroup = string.format("Aerial%sIcon", d.kind)
    --           table.insert(symbol, 1, {
    --             provider = string.format("%s", d.icon),
    --             hl = (vim.fn.hlexists(hlgroup) == 1) and hlgroup or nil,
    --           })
    --           if #self.symbols >= 1 and i < #self.symbols then table.insert(symbol, { provider = Separator }) end
    --           table.insert(symbols, symbol)
    --         end
    --         self[1] = self:new(symbols, 1)
    --       end,
    --     },
    --   },
    --   hl = { bg = "", fg = colors.leaf.hex, bold = true },
    -- },
    -- }

    local Diagnostics = {
        static = {
            error_icon = icons.diagnostics.error,
            warn_icon = icons.diagnostics.warn,
            hint_icon = icons.diagnostics.hint,
            info_icon = icons.diagnostics.info,
        },
        update = { "DiagnosticChanged", "BufEnter" },
        init = function(self)
            self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
            self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,
        {
            provider = function(self) return (" " .. self.hint_icon .. " " .. self.hints .. " ") end,
            hl = function(self)
                return { fg = self.hints > 0 and colors.leaf.lighten(40).hex or colors.leaf.darken(80).hex, bold = true }
            end,
        },
        {
            provider = function(self) return (" " .. self.error_icon .. " " .. self.errors .. " ") end,
            hl = function(self)
                return {
                    fg = self.errors > 0 and colors.rose.lighten(40).hex or colors.rose.darken(80).hex,
                    bold = true,
                }
            end,
        },
        {
            provider = function(self) return (" " .. self.warn_icon .. " " .. self.warnings .. " ") end,
            hl = function(self)
                return {
                    fg = self.warnings > 0 and colors.wood.lighten(40).hex or colors.wood.darken(80).hex,
                    bold = true,
                }
            end,
        },
        {
            provider = function(self) return (" " .. self.info_icon .. " " .. self.info .. " ") end,
            hl = function(self)
                return {
                    fg = self.info > 0 and colors.water.lighten(40).hex or colors.water.darken(80).hex,
                    bold = true,
                }
            end,
        },

        on_click = {
            callback = function()
                require("trouble").toggle({ mode = "document_diagnostics" })
                -- or
                -- vim.diagnostic.setqflist()
            end,
            name = "heirline_diagnostics",
        },
    }

    local Navic = {
        condition = function() return require("nvim-navic").is_available() end,
        static = {
            enc = function(line, col, winnr) return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr) end,
            dec = function(c)
                local line = bit.rshift(c, 16)
                local col = bit.band(bit.rshift(c, 6), 1023)
                local winnr = bit.band(c, 63)
                return line, col, winnr
            end,
        },
        init = function(self)
            local data = require("nvim-navic").get_data() or {}
            local children = {}
            for i, d in ipairs(data) do
                local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
                local child = {
                    {
                        provider = d.icon .. " ",
                        hl = typed_hl[d.type],
                    },
                    {
                        provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", "") .. " ",
                        on_click = {
                            minwid = pos,
                            callback = function(_, minwid)
                                local line, col, winnr = self.dec(minwid)
                                vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
                            end,
                            name = "heirline_navic",
                        },
                    },
                }
                if #data > 1 and i < #data then
                    table.insert(child, {
                        provider = " " .. icons.common.separator .. " ",
                    })
                end
                table.insert(children, child)
            end
            self.child = self:new(children, 1)
        end,
        provider = function(self) return self.child:eval() end,
        hl = { fg = colors.rose.hex, bold = true },
        update = "CursorMoved",
    }

    local TerminalName = {
        provider = function()
            local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
            return icons.Terminal .. tname
        end,
        hl = { fg = colors.rose.hex, bold = true },
    }
    local InactiveWinBar = {
        condition = function() return not heirline_conditions.is_active() end,
        Diagnostics,
        { provider = "%=" },
        FileFlags,
        WinBarFileName,
        hl = { bold = true },
    }
    local SeparatorIcon = {
        provider = function() return icons.ui.Separator end,
        hl = { bold = true, fg = colors.rose.hex },
    }
    local DefaultWinbar = {
        condition = function() return heirline_conditions.is_active() end,
        static = {
            encode_pos = function(line, col, winnr) return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr) end,
            decode_pos = function(c) return bit.rshift(c, 16), bit.band(bit.rshift(c, 6), 1023), bit.band(c, 63) end,
        },
        WorkDir,
        Filepath,
        Spacer,
        SeparatorIcon,
        Spacer,
        Navic,
        { provider = "%=" },
        Diagnostics,
        FileFlags,
        WinBarFileName,
        hl = { bold = true },
    }

    local TerminalWinbar = {
        condition = function() return heirline_conditions.buffer_matches({ buftype = { "terminal" } }) end,
        FileType,
        Spacer,
        TerminalName,
    }

    local WinBars = {
        fallthrough = false,
        DefaultWinbar,
        InactiveWinBar,
        TerminalWinbar,
    }

    return WinBars
end

return M
