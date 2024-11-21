local M = {}

function M.get_statusline()
    local heirline_utils = require("heirline.utils")
    local heirline_conditions = require("heirline.conditions")
    local colors = require("configs.base.colors").base_colors()
    local icons = require("configs.base.ui.icons")
    local funcs = require("core.funcs")
    local common = require("modules.build_me.heirline.common")
    local Space = { provider = " ", hl = { bg = colors.bg.hex, fg = colors.fg.hex } }
    local Align = { provider = "%=", hl = { bg = colors.bg.hex, fg = colors.fg.hex } }

    local ViMode = {
        init = function(self)
            self.mode = vim.fn.mode(1)
            if not self.once then
                vim.api.nvim_create_autocmd("ModeChanged", {
                    pattern = "*:*o",
                    command = "redrawstatus",
                })
                self.once = true
            end
        end,
        static = {
            mode_names = {
                n = "N",
                no = "N?",
                nov = "N?",
                noV = "N?",
                ["no\23"] = "N?",
                niI = "Ni",
                niR = "Nr",
                niV = "Nv",
                nt = "Nt",
                v = "V",
                vs = "Vs",
                V = "V_",
                Vs = "Vs",
                ["\23"] = "^V",
                ["\23s"] = "^V",
                s = "S",
                S = "S_",
                ["\20"] = "^S",
                i = "I",
                ic = "Ic",
                ix = "Ix",
                R = "R",
                Rc = "Rc",
                Rx = "Rx",
                Rv = "Rv",
                Rvc = "Rv",
                Rvx = "Rv",
                c = "C",
                cv = "Ex",
                r = "...",
                rm = "M",
                ["r?"] = "?",
                ["!"] = "!",
                t = "T",
            },
            mode_colors = {
                n = colors.rose.lighten(30).hex,
                i = colors.leaf.lighten(30).hex,
                v = colors.water.lighten(30).hex,
                V = colors.water.lighten(30).hex,
                ["\23"] = colors.wood.darken(80).hex,
                c = colors.blossom.darken(40).hex,
                s = colors.sky.darken(40).hex,
                S = colors.sky.darken(40).hex,
                ["\20"] = colors.sky.darken(40).hex,
                R = colors.wood.lighten(30).hex,
                r = colors.wood.lighten(30).hex,
                ["!"] = colors.blossom.lighten(30).hex,
                t = colors.leaf.lighten(30).hex,
            },
        },
        provider = function(self)
            local mode_name = self.mode and self.mode_names[self.mode] or ""
            return " %2(" .. mode_name .. "%)    "
        end,
        hl = function(self)
            _G.TECHDEUS_MODE = self.mode:sub(1, 1)
            return { fg = self.mode_colors[_G.TECHDEUS_MODE], bold = true }
        end,
        update = {
            "ModeChanged",
            "MenuPopup",
            "CmdlineEnter",
            "CmdlineLeave",
            pattern = "*:*",
            callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end),
        },
    }

    -- local MacroRec = {
    --     condition = function() return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 1 end,
    --     provider = " ",
    --     hl = { fg = colors.leaf.hex, bold = true },
    --     heirline_utils.surround({ "[", "]" }, nil, {
    --         provider = function() return vim.fn.reg_recording() end,
    --         hl = { fg = colors.leaf.hex, bold = true },
    --     }),
    --     update = {
    --         "RecordingEnter",
    --         "RecordingLeave",
    --     },
    -- }

    local FormatterActive = {
        static = {
            active = false,
        },
        condition = heirline_conditions.lsp_attached,
        update = { "LspAttach", "LspDetach" },
        provider = function(self)
            local formatters_saved = {}
            local p_formatters = nil
            local formatters_ok, formatters = pcall(require, "conform")
            if formatters_ok and formatters then
                local sources = formatters.list_formatters()
                for _, source in ipairs(sources) do
                    if source.available then
                        table.insert(formatters_saved, source.name)
                        self.active = true
                    end
                end
            end

            if next(formatters_saved) ~= nil then
                if #formatters_saved == 0 then
                    p_formatters = "No Formatters "
                    return
                end
                formatters_saved = funcs.remove_duplicate(formatters_saved)
                p_formatters = table.concat(formatters_saved, ", ")
            else
                p_formatters = ""
            end
            return p_formatters
        end,
        hl = { fg = colors.wood.lighten(40).hex, bold = true },
        on_click = {
            callback = function()
                vim.defer_fn(function() vim.cmd("ConformInfo") end, 100)
            end,
            name = "heirline_FORMATTER",
        },
        {
            provider = function() return " " .. icons.lsp.Namespace .. " " end,
            hl = function(self)
                return { fg = self.active and colors.wood.darken(40).hex or colors.fg.hex, bold = true }
            end,
        },
    }

    local LspActive = {
        static = {
            active = false,
        },
        condition = heirline_conditions.lsp_attached,
        update = { "LspAttach", "LspDetach" },
        provider = function(self)
            local lsp = {}
            local p_lsp = nil
            for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
                if server.name ~= "efm" then
                    table.insert(lsp, server.name)
                    self.active = true
                end
            end

            if next(lsp) ~= nil then
                if #lsp == 0 then
                    p_lsp = " No LSPs"
                    return
                end
                p_lsp = table.concat(lsp, ", ")
            else
                p_lsp = ""
            end
            return " " .. p_lsp
        end,
        hl = { fg = colors.leaf.lighten(40).hex, bold = true },
        on_click = {
            callback = function()
                vim.defer_fn(function() vim.cmd("LspInfo") end, 100)
            end,
            name = "heirline_LSP",
        },
        {
            provider = function() return " " .. icons.common.lsp .. " " end,
            hl = function(self)
                return { fg = self.active and colors.leaf.darken(40).hex or colors.fg.hex, bold = true }
            end,
        },
    }

    local LintActive = {
        static = {
            active = false,
        },
        condition = heirline_conditions.lsp_attached,
        update = { "LspAttach", "LspDetach" },
        provider = function(self)
            local linters_saved = {}
            local p_linters = nil

            local lint_ok, linters = pcall(require, "lint")
            local all_linters = linters.linters
            if lint_ok and #all_linters > 0 then
                local ft = string.lower(vim.bo.filetype)
                local linters_ft = linters.linters_by_ft[ft]
                local lint_sourced = linters_ft ~= nil and linters_ft or {}

                for _, src in ipairs(lint_sourced) do
                    table.insert(linters_saved, src)
                    self.active = true
                end
            end

            if next(linters_saved) ~= nil then
                if #linters_saved == 0 then
                    p_linters = " No Linters"
                    return
                end
                linters_saved = funcs.remove_duplicate(linters_saved)
                p_linters = table.concat(linters_saved, ", ")
            else
                p_linters = ""
            end
            return p_linters .. " "
        end,
        hl = { fg = colors.blossom.lighten(40).hex, bold = true },
        on_click = {
            callback = function()
                vim.defer_fn(function() vim.cmd("LspInfo") end, 100)
            end,
            name = "heirline_Lint",
        },
        {
            provider = function() return " " .. icons.lsp.File end,
            hl = function(self)
                return { fg = self.active and colors.blossom.darken(40).hex or colors.fg.hex, bold = true }
            end,
        },
    }

    local DeusStatistics = {
        {
            init = function(self)
                self.wc = vim.fn.wordcount()
                self.mode = vim.fn.mode()
                self.lines = vim.api.nvim_buf_line_count(0)
            end,
            provider = function(self)
                local wc = self.wc
                local isVisualMode = self.mode:find("[vV]")

                local chars = (isVisualMode and wc.visual_chars ~= nil) and wc.visual_chars .. "/" .. wc.chars
                    or wc.chars
                local words = (isVisualMode and wc.visual_words ~= nil) and wc.visual_words .. "/" .. wc.words
                    or wc.words
                local lines = (isVisualMode and wc.visual_lines ~= nil) and wc.visual_lines .. "/" .. self.lines
                    or self.lines
                return string.format(" %s chars %s words %s lines ", chars, words, lines)
            end,
            hl = function()
                return {
                    fg = colors.sky.lighten(20).hex,
                    bold = true,
                }
            end,
            update = {
                "ModeChanged",
                "CursorMoved",
                "CursorMovedI",
                callback = function(self)
                    self.wc = vim.fn.wordcount()
                    self.mode = vim.fn.mode()
                    self.lines = vim.api.nvim_buf_line_count(0)
                    vim.cmd("redrawstatus")
                end,
            },
        },
    }

    local DeusTools = heirline_utils.surround({ "", "" }, "", {
        init = function(self) self.show = _G.DEUS_SETTINGS["statusline"]["show"] end,
        {
            condition = function(self) return self.show == "lsp" end,
            {
                heirline_utils.insert(LspActive, FormatterActive, LintActive),
            },
        },
        {
            condition = function(self) return self.show == "stats" end,
            {
                heirline_utils.insert(DeusStatistics),
            },
        },
        hl = function(self)
            return { bg = self.show == "lsp" and colors.bg.darken(20).hex or colors.bg.lighten(20).hex, bold = true }
        end,
    })

    local DeusTotalsRuler = {
        condition = function(self)
            return not heirline_conditions.buffer_matches({
                filetype = self.filetypes,
            })
        end,
        {
            provider = " %P|%3L ",
            hl = { fg = colors.fg.hex, bold = true },
            on_click = {
                callback = function() vim.cmd("normal! gg") end,
                name = "sl_totals_ruler_click",
            },
        },
    }

    local DeusRuler = {
        condition = function(self)
            return not heirline_conditions.buffer_matches({
                filetype = self.filetypes,
            })
        end,
        {
            -- %l = current row the cursor sits in.
            -- %c = current column the cursor sits in.
            provider = "%3l|%2c ",
            hl = { fg = colors.fg.hex, bold = true },
            on_click = {
                callback = function() vim.cmd("normal! G") end,
                name = "sl_ruler_click",
            },
        },
    }

    local ScrollBar = {
        static = {
            sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
            -- Another variant, because the more choice the better.
            -- sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
        },
        provider = function(self)
            local current_line = vim.api.nvim_win_get_cursor(0)[1]
            local total_lines = vim.api.nvim_buf_line_count(0)
            local line_ratio = (current_line - 1) / total_lines
            local index = math.floor(line_ratio * #self.sbar) + 1
            return string.rep(self.sbar[index], 2)
        end,
        hl = function()
            return {
                fg = ViMode.static.mode_colors[_G.TECHDEUS_MODE],
                bold = true,
            }
        end,
    }

    local ReverseScrollBar = {
        static = {
            sbar = { "█", "▇", "▆", "▅", "▄", "▃", "▂", "▁" },
        },
        provider = function(self)
            local current_line = vim.api.nvim_win_get_cursor(0)[1]
            local total_lines = vim.api.nvim_buf_line_count(0)
            local line_ratio = (current_line - 1) / total_lines
            local index = math.floor(line_ratio * #self.sbar) + 1
            return string.rep(self.sbar[index], 2)
        end,
        hl = function()
            return {
                fg = ViMode.static.mode_colors[_G.TECHDEUS_MODE],
                bold = true,
            }
        end,
    }

    local DeusFileName = {
        -- let's first set up some attributes needed by this component and its children
        init = function(self) self.filename = vim.api.nvim_buf_get_name(0) end,
        provider = function(self)
            -- first, trim the pattern relative to the current directory. For other
            -- options, see :h filename-modifers
            local filename = vim.fn.fnamemodify(self.filename, ":.")
            if filename == "" then return "[No Name]" end
            -- now, if the filename would occupy more than 1/4th of the available
            -- space, we trim the file path to its initials
            -- See Flexible Components section below for dynamic truncation
            if not heirline_conditions.width_percent_below(#filename, 0.25) then
                filename = vim.fn.pathshorten(filename)
            end
            return filename
        end,
        hl = { fg = heirline_utils.get_highlight("Directory").fg },
    }

    local DeusFileType = {
        provider = function() return string.upper(vim.bo.filetype) end,
        hl = function()
            return {
                fg = ViMode.static.mode_colors[_G.TECHDEUS_MODE],
                bold = true,
            }
        end,
    }

    local LspIcon = {
        provider = function() return icons.common.lsp end,
        hl = function() return { fg = colors.leaf.darken(10).hex } end,
        on_click = {
            callback = function()
                local global = require("core.globals")
                local notify = require("modules.build_me.base.notify")
                local current_value = _G.DEUS_SETTINGS["statusline"]["show"]
                if current_value == "stats" then
                    local updated_value = "lsp"
                    _G.DEUS_SETTINGS["statusline"]["show"] = updated_value
                    local f_settings = vim.deepcopy(_G.DEUS_SETTINGS)
                    funcs.write_file(global.deus_path .. "/lua/configs/settings.json", f_settings)
                    notify.info("StatusLine Show: " .. updated_value, { title = "DEUS IDE" })
                end
            end,
            name = "Heirline_statlinelspinfo",
        },
    }
    local DeusFileIcon = {
        init = function(self)
            local filename = self.filename
            local extension = vim.fn.fnamemodify(filename, ":e")

            self.icon, self.icon_color = require("mini.icons").get("file", extension)
        end,
        provider = function(self) return self.icon and (self.icon .. " ") end,
        hl = function() return { fg = colors.leaf.darken(10).hex } end,
        on_click = {
            callback = function()
                local global = require("core.globals")
                local notify = require("modules.build_me.base.notify")
                local current_value = _G.DEUS_SETTINGS["statusline"]["show"]

                if current_value == "lsp" then
                    local updated_value = "stats"
                    _G.DEUS_SETTINGS["statusline"]["show"] = updated_value
                    local f_settings = vim.deepcopy(_G.DEUS_SETTINGS)
                    funcs.write_file(global.deus_path .. "/lua/configs/settings.json", f_settings)
                    notify.info("StatusLine Show: " .. updated_value, { title = "DEUS IDE" })
                end
            end,
            name = "Heirline_statlinefileinfo",
        },
    }

    local DeusFileEncoding = {
        provider = function()
            local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
            return enc:upper()
        end,
        hl = function() return { fg = ViMode.static.mode_colors[_G.TECHDEUS_MODE] } end,
    }

    local DeusFilePermissions = {
        condition = function(self)
            return not heirline_conditions.buffer_matches({
                filetype = self.filetypes,
            })
        end,
        provider = function()
            local path = vim.api.nvim_buf_get_name(0)
            return vim.fn.getfperm(path)
        end,
        hl = { fg = colors.wood.lighten(40).hex, bold = true },
    }

    local DeusBattery = {
        provider = function() return require("battery").get_status_line() end,
        hl = function() return { fg = ViMode.static.mode_colors[_G.TECHDEUS_MODE] } end,
    }

    local DeusFileLastModified = {
        condition = function(self)
            return not heirline_conditions.buffer_matches({
                filetype = self.filetypes,
            })
        end,
        -- did you know? Vim is full of functions!
        provider = function()
            local Met = require("configs.base.utils.metrics")
            local ftime = vim.fn.getftime(vim.api.nvim_buf_get_name(0))
            local last_updated = ftime > 0 and os.date("%m-%d-%y", ftime)
            if not last_updated then return "File never saved" end
            local now = vim.fn.localtime()
            local diff = os.difftime(now, ftime)
            local d = Met.time_display(diff)
            local result = Met.prettify_result(d)

            return result
        end,
        hl = { fg = colors.wood.lighten(40).hex, bold = true },
    }

    local DeusFileFormat = {
        provider = function()
            local fmt = vim.bo.fileformat
            return fmt:upper()
        end,
        hl = { fg = colors.wood.lighten(40).hex, bold = true },
    }

    local DeusFileSize = {
        provider = function()
            -- stackoverflow, compute human readable file size
            local suffix = { "b", "k", "M", "G", "T", "P", "E" }
            local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
            fsize = (fsize < 0 and 0) or fsize
            if fsize < 1024 then return fsize .. suffix[1] end
            local i = math.floor((math.log(fsize) / math.log(1024)))
            return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i + 1])
        end,
        hl = { fg = colors.wood.lighten(40).hex, bold = true },
    }

    local HelpFileName = {
        condition = function() return vim.bo.filetype == "help" end,
        provider = function()
            local filename = vim.api.nvim_buf_get_name(0)
            return vim.fn.fnamemodify(filename, ":t") .. " "
        end,
        hl = { fg = colors.water.lighten(40).hex },
    }

    local TerminalName = {
        provider = function()
            local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
            return " " .. tname .. " "
        end,
        hl = { fg = colors.water.lighten(40).hex, bold = true },
    }

    local InactiveStatusline = {
        condition = heirline_conditions.is_not_active,
        common.file.FileType,
        Space,
        DeusFileName,
        Align,
    }

    local SpecialStatusline = {
        condition = function()
            return heirline_conditions.buffer_matches({
                buftype = { "nofile", "prompt", "help", "quickfix" },
                filetype = { "^git.*", "fugitive" },
            })
        end,
        common.file.FileType,
        Space,
        HelpFileName,
        Align,
    }

    local TerminalStatusline = {
        condition = function() return heirline_conditions.buffer_matches({ buftype = { "terminal" } }) end,
        hl = { bg = colors.rose.hex },
        -- Quickly add a condition to the ViMode to only show it when buffer is active!
        { condition = heirline_conditions.is_active, ViMode, Space },
        common.file.FileType,
        Space,
        TerminalName,
        Align,
    }

    local DefaultStatusline = {
        condition = function(self)
            return not heirline_conditions.buffer_matches({
                filetype = self.force_inactive_filetypes,
            })
        end,
        hl = function()
            if heirline_conditions.is_active() then
                return {
                    bg = colors.bg.hex,
                    fg = colors.leaf.darken(80).hex,
                }
            else
                return {
                    bg = colors.bg.hex,
                    fg = colors.leaf.darken(80).hex,
                }
            end
        end,
        static = {
            filetypes = {
                "^git.*",
                "fugitive",
                "alpha",
                "^neo--tree$",
                "^neotest--summary$",
                "^neo--tree--popup$",
                "^NvimTree$",
                "^toggleterm$",
            },
            force_inactive_filetypes = {
                "^aerial$",
                "^alpha$",
                "^chatgpt$",
                "^frecency$",
                "^lazy$",
                "^lazyterm$",
                "^netrw$",
                "^TelescopePrompt$",
            },
            mode_color = function(self)
                local mode_color = heirline_conditions.is_active() and vim.fn.mode() or "n"
                return self.mode_colors[mode_color]
            end,
        },
        {
            ViMode,
            DeusRuler,
            ReverseScrollBar,
            Space,
            DeusFilePermissions,
            Space,
            DeusFileSize,
            Space,
            DeusFileFormat,
            Space,
            DeusFileEncoding,
            Space,
            LspIcon,
            Align,
            DeusTools,
            Align,
            DeusFileIcon,
            Space,
            DeusFileType,
            Space,
            DeusFileLastModified,
            Space,
            ScrollBar,
            DeusTotalsRuler,
            DeusBattery,
            Space,
        },
    }

    local StatusLines = {
        hl = function()
            if heirline_conditions.is_active() then
                return "StatusLine"
            else
                return "StatusLineNC"
            end
        end,
        fallthrough = false,
        SpecialStatusline,
        TerminalStatusline,
        InactiveStatusline,
        DefaultStatusline,
    }

    return StatusLines
end

return M

-- -- Code Companion
-- local CodeCompanion = {
--   static = {
--     processing = false,
--   },
--   update = {
--     "User",
--     pattern = "CodeCompanionRequest*",
--     callback = function(self, args)
--       if args.match == "CodeCompanionRequestStarted" then
--         self.processing = true
--       elseif args.match == "CodeCompanionRequestFinished" then
--         self.processing = false
--       end
--       vim.cmd("redrawstatus")
--     end,
--   },
--   {
--     condition = function(self) return self.processing end,
--     provider = " ",
--     hl = { fg = colors.wood.lighten(40).hex },
--   },
-- }
-- local CodeCompanionAgent = {
--   static = {
--     processing = false,
--   },
--   update = {
--     "User",
--     pattern = "CodeCompanionAgent*",
--     callback = function(self, args)
--       if args.match == "CodeCompanionAgentStarted" then
--         self.processing = true
--       elseif args.match == "CodeCompanionAgentFinished" then
--         self.processing = false
--       end
--       vim.cmd("redrawstatus")
--     end,
--   },
--   {
--     condition = function(self) return self.processing end,
--     provider = "󱙺 ",
--     hl = { fg = colors.leaf.lighten(40).hex },
--   },
-- }

-- local DeusSearch = {
--   init = function(self)
--     local ok, search = pcall(vim.fn.searchcount)
--     if ok and search.total then self.search = search end
--   end,
--   {
--     provider = "",
--     hl = function() return { fg = colors.wood.darken(80).hex } end,
--   },
--   {
--     provider = function(self)
--       local search = self.search
--       return string.format(" %d/%d ", search.current, math.min(search.total, search.maxcount))
--     end,
--     hl = function()
--       return {
--         bg = colors.wood.darken(80).hex,
--         fg = colors.wood.lighten(40).hex,
--         bold = true,
--       }
--     end,
--   },
--   {
--     provider = "",
--     hl = function() return { bg = colors.wood.darken(80).hex, fg = colors.wood.darken(80).hex } end,
--   },
-- }

--Return the status of the current session
-- local Session = {
--   condition = function(self)
--     return not heirline_conditions.buffer_matches({
--       filetype = self.filetypes,
--     })
--   end,
--   {
--     provider = function()
--       if vim.g.persisting then return "   " end
--       return icons.common.project
--     end,
--     hl = { fg = colors.water.darken(80).hex },
--     update = {
--       "User",
--       pattern = { "PersistedToggle", "PersistedDeletePost" },
--       callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end),
--     },
--     on_click = {
--       callback = function() vim.cmd("SessionToggle") end,
--       name = "sl_session_click",
--     },
--   },
-- }
-- local MiniDeps = {
--   update = {
--     "User",
--     pattern = "MiniDepsCheck",
--     callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end),
--   },
--   provider = function() return icons.lazy.plugin end,
--   on_click = {
--     callback = function() require("mini.deps").update() end,
--     name = "sl_plugins_click",
--   },
--   hl = { fg = colors.leaf.lighten(40).hex },
-- }
-- local DeusSpell = {
--     condition = require("lvim-linguistics.status").spell_has,
--     provider = function()
--         local status = require("lvim-linguistics.status").spell_get()
--         return " SPELL: " .. status
--     end,
--     hl = { fg = colors.blossom.lighten(40).hex, bold = true },
-- tSignsPrevHunk}
