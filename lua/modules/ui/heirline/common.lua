-- Optimized and modularized components
local col = require('configs.colors')
local col_utils = require("base.utils.colors")
local icons = require("base.utils").get_icons()

local C = {}
local highlight_cache = {}

-- Get mode colors
function C.get_mode_colors()
    local col = require("configs.colors")
    return {
        normal = col:get_highlight("MiniStatuslineModeNormal"),
        insert = col:get_highlight("MiniStatuslineModeInsert"),
        visual = col:get_highlight("MiniStatuslineModeVisual"),
        replace = col:get_highlight("MiniStatuslineModeReplace"),
        command = col:get_highlight("MiniStatuslineModeCommand"),
        other = col:get_highlight("MiniStatuslineModeOther")
    }
end

-- Get base colors from configs.colors
function C.get_base_colors()
    local col = require("configs.colors")
    return {
        normal = col:get_highlight("Normal"),
        constant = col:get_highlight("Constant"),
        title = col:get_highlight("Title"),
        statement = col:get_highlight("Statement"),
        special = col:get_highlight("Special"),
        group = col:get_highlight("Group")
    }
end

-- Clear highlight cache
function C.clear_highlight_cache()
    highlight_cache = {}
end

-- Set up autocmd to clear cache on colorscheme change
vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = C.clear_highlight_cache
})

function C.get_cached_highlight(hl_group)
    if not highlight_cache[hl_group] then
        local ok, hl = pcall(function()
            return require("configs.colors"):get_highlight(hl_group)
        end)
        highlight_cache[hl_group] = ok and hl or { fg = "#ffffff", bg = "NONE" }
    end
    return highlight_cache[hl_group]
end

-- Cache for mode information
local mode_cache = {
    current = 'n',
    color = col.colors.red,
    name = 'N',
    long_name = 'normal'
}

C.DeusMode = function(place_icon)
    return {
        init     = function(self)
            local colors = col.colors
            self.colors = colors
            self.place_icon = place_icon ~= nil and place_icon or 'left'
            if not self.once then
                -- Set up autocommand only once
                vim.api.nvim_create_autocmd("ModeChanged", {
                    pattern = "*:*",
                    callback = function()
                        local new_mode = vim.fn.mode(1)
                        mode_cache.current = new_mode
                        mode_cache.color = self.mode_colors[new_mode:sub(1, 1)] or col.colors.red
                        mode_cache.name = self.mode_names[new_mode] or 'N'
                        mode_cache.long_name = self.long_mode_names[new_mode] or 'normal'
                        vim.cmd('redrawstatus')
                    end,
                })
                self.once = true
            end

            -- Initial mode setup
            self.mode = vim.fn.mode(1)
            mode_cache.current = self.mode
            mode_cache.color = self.mode_colors[self.mode:sub(1, 1)] or col.colors.red
            mode_cache.name = self.mode_names[self.mode] or 'N'
        end,
        static   = {
            mode_names      = {
                n = "N",
                no = "N?",
                nov = "N?",
                noV = "N?",
                ["no\22"] = "N?",
                niI = "Ni",
                niR = "Nr",
                niV = "Nv",
                nt = "Nt",
                v = "V",
                vs = "Vs",
                V = "V_",
                Vs = "Vs",
                ["\22"] = "^V",
                ["\22s"] = "^V",
                s = "S",
                S = "S_",
                ["\19"] = "^S",
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
            long_mode_names = {
                n = 'normal',
                no = 'normal',
                nov = 'normal',
                noV = 'normal',
                ['no\22'] = 'normal',
                niI = 'normal',
                niR = 'normal',
                niV = 'normal',
                nt = 'normal',
                v = 'visual',
                vs = 'visual',
                V = 'visual',
                Vs = 'visual',
                ['\22'] = 'visual',
                ['\22s'] = 'visual',
                s = 'visual',
                S = 'visual',
                ['\19'] = 'visual',
                i = 'insert',
                ic = 'insert',
                ix = 'insert',
                R = 'replace',
                Rc = 'replace',
                Rx = 'replace',
                Rv = 'replace',
                Rvc = 'replace',
                Rvx = 'replace',
                c = 'command',
                cv = 'command',
                r = 'normal',
                rm = 'normal',
                ['r?'] = 'normal',
                ['!'] = 'normal',
                t = 'terminal',
            },
            mode_colors     = {
                n = col:get_highlight("MiniStatuslineModeNormal").fg,
                i = col:get_highlight("MiniStatuslineModeInsert").fg,
                v = col:get_highlight("MiniStatuslineModeVisual").fg,
                V = col:get_highlight("MiniStatuslineModeVisual").fg,
                ['\22'] = col:get_highlight("MiniStatuslineModeVisual").fg,
                c = col:get_highlight("MiniStatuslineModeCommand").fg,
                s = col:get_highlight("MiniStatuslineModeOther").fg,
                S = col:get_highlight("MiniStatuslineModeOther").fg,
                r = col:get_highlight("MiniStatuslineModeReplace").fg,
                ['!'] = col:get_highlight("MiniStatuslineModeNormal").fg,
                t = col:get_highlight("MiniStatuslineModeNormal").fg,
            },
        },
        provider = function(self)
            local mode_str_left = string.format(" %s %s ", icons.common.vim, (self.mode_names[mode_cache.current] or 'N'))
            local mode_str_right = string.format(" %s %s ", (self.mode_names[mode_cache.current] or 'N'),
                icons.common.vim)
            return place_icon == 'left' and mode_str_left or mode_str_right
        end,
        hl       = function(self)
            return {
                fg = self.mode_colors[mode_cache.current],
                bg = self.mode_colors
                    [mode_cache.current],
                bold = true
            }
        end,
        update   = {
            "ModeChanged",
            "MenuPopup",
            "CmdlineEnter",
            "CmdlineLeave",
        },
    }
end

-- Simplified mode getters
function C.get_current_mode()
    return mode_cache.current
end

function C.split_permission_string(perm_string)
    local PERMS_GROUPS = 3
    local GROUP_SIZE = 3

    -- Validate input
    if not perm_string or type(perm_string) ~= "string" or #perm_string ~= 9 then
        vim.notify("Invalid permission string format", vim.log.levels.WARN)
        return { "---", "---", "---" }
    end

    local split_perms = {}
    for i = 1, PERMS_GROUPS do
        local start_pos = (i - 1) * GROUP_SIZE + 1
        local end_pos = i * GROUP_SIZE
        local group = string.sub(perm_string, start_pos, end_pos)
        table.insert(split_perms, group)
    end

    return split_perms
end

function C.DeusFileOrigPermissions()
    return {
        condition = function()
            return vim.tbl_contains(Global.fts, vim.bo[0].filetype)
        end,
        init = function(self)
            -- Get file permissions
            local path = vim.api.nvim_buf_get_name(0)

            -- Handle non-file buffers
            if path == "" then
                self.perms = "---------"
                return
            end

            -- Get permissions and handle errors
            local perms = vim.fn.getfperm(path)
            if not perms or perms == "" then
                self.perms = "---------"
                vim.notify(string.format("No permissions found for file: %s", path), vim.log.levels.WARN)
                return
            end

            self.perms = perms
        end,
        {
            provider = function(self)
                local parts = C.split_permission_string(self.perms)
                return parts[1]
            end,
            hl = { fg = "#ff5555" }, -- Red for user permissions
        },
        {
            provider = " │ ",
            hl = { fg = "#ffffff" },
        },
        {
            provider = function(self)
                local parts = C.split_permission_string(self.perms)
                return parts[2]
            end,
            hl = { fg = "#50fa7b" }, -- Green for group permissions
        },
        {
            provider = " │ ",
            hl = { fg = "#ffffff" },
        },
        {
            provider = function(self)
                local parts = C.split_permission_string(self.perms)
                return parts[3]
            end,
            hl = { fg = "#bd93f9" }, -- Purple for others permissions
        },
        update = { "BufEnter", "BufWritePost" },
    }
end

function C.get_current_color()
    return mode_cache.color
end

function C.get_inverted_color()
    local color = C.get_current_color()
    return col_utils.invert_color(color)
end

function C.Space(spaces)
    spaces = spaces or 1
    return {
        provider = function()
            return string.rep(' ', spaces)
        end,
    }
end

-- Update navic component to match statusline style
C.Navic = {
    condition = function()
        return require('nvim-navic').is_available()
    end,
    static = {
        type_hl = {
            -- Keep your existing type highlights
        },
        enc = function(line, col, winnr)
            return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
        end,
        dec = function(c)
            local line = bit.rshift(c, 16)
            local col = bit.band(bit.rshift(c, 6), 1023)
            local winnr = bit.band(c, 63)
            return line, col, winnr
        end,
    },
    init = function(self)
        local data = require('nvim-navic').get_data() or {}
        local children = {}
        for i, d in ipairs(data) do
            local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
            local child = {
                {
                    provider = d.icon,
                    hl = self.type_hl[d.type] or { fg = col.colors.fg },
                },
                {
                    provider = d.name:gsub('%%', '%%%%'):gsub('%s*->%s*', ''),
                    on_click = {
                        minwid = pos,
                        callback = function(_, minwid)
                            local line, col, winnr = self.dec(minwid)
                            vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
                        end,
                        name = 'heirline_navic',
                    },
                },
            }
            if #data > 1 and i < #data then
                table.insert(child, {
                    provider = ' ' .. icons.common.separator .. ' ',
                    hl = function()
                        -- Use mode-aware highlighting
                        local mode = C.get_current_mode()
                        return { fg = vim.api.nvim_get_hl(0, { name = 'winbar_' .. mode .. '_3' }).fg }
                    end,
                })
            end
            table.insert(children, child)
        end
        self.child = self:new(children, 1)
    end,
    provider = function(self)
        return self.child:eval()
    end,
    hl = function()
        -- Use mode-aware highlighting
        local mode = C.get_current_mode()
        return 'winbar_' .. mode .. '_3' -- Match statusline's third section
    end,
    update = { 'CursorMoved', 'BufEnter' },
}

-- File format component
C.DeusFileFormat = {
    provider = function()
        return string.format(" %s ", vim.bo.fileformat:upper())
    end,
    hl = { fg = col.colors.green, bold = true },
}

-- Search results component
C.SearchResults = {
    condition = function(self)
        local lines = vim.api.nvim_buf_line_count(0)
        if lines > 50000 then
            return false -- Skip for large files
        end

        local query = vim.fn.getreg('/')
        if query == '' or query:find('@') then
            return false -- Skip if no query or invalid query
        end

        local search_count = vim.fn.searchcount({ recompute = 1, maxcount = -1 })
        if not (vim.v.hlsearch == 1 and search_count.total > 0) then
            return false -- Skip if no active search
        end

        -- Clean up the query for display
        query = query:gsub([[^\V]], ''):gsub([[\<]], ''):gsub([[\>]], '')

        self.query = query
        self.count = search_count
        return true
    end,
    {
        provider = function(self)
            return string.format(" %s %d/%d ", self.query, self.count.current, self.count.total)
        end,
        hl = nil, -- Add your highlight group here if needed
    },
    C.Space(1),   -- Separator after the section, if active
}

-- Update terminal_name to match statusline styling
C.Terminal_name = {
    provider = function()
        local tname, _ = vim.api.nvim_buf_get_name(0):gsub('.*:', '')
        return icons.common.terminal .. tname
    end,
    hl = function()
        -- Use mode-aware highlighting like statusline
        local mode = C.get_current_mode()
        return 'winbar_' .. mode .. '_1'
    end,
}
-- Update file_types component to use statusline-like highlighting
C.File_types = {
    provider = function()
        local file_type = vim.bo.filetype
        if file_type ~= '' then
            return '  ' .. string.upper(file_type)
        end
    end,
    hl = function()
        -- Use the current mode to match statusline
        local mode = C.get_current_mode()
        return 'winbar_' .. mode .. '_1' -- This will match heirline_{mode}_1
    end,
}
-- Ensure file_icon_name handles failures properly
C.File_icon_name = {
    init = function(self)
        -- Use pcall for potentially failing operations
        local ok_expand, filename = pcall(vim.fn.expand, '%:t')
        local extension = nil

        if ok_expand then
            local ok_ext, ext = pcall(vim.fn.expand, '%:e')
            if ok_ext then
                extension = ext
            end
        else
            filename = '[No Name]'
        end
        -- Safely get icon
        local ok_icon, icon, icon_color = pcall(function()
            return require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
        end)

        if ok_icon then
            self.icon = icon
            self.icon_color = icon_color
            self.file_name = filename
        else
            self.icon = icons.common.file
            self.icon_color = 'White'
        end
    end,
    provider = function(self)
        -- Safely get filename
        local ok, filename = pcall(function()
            return self.file_name.unique(vim.api.nvim_get_current_win())
        end)

        return ' ' .. self.icon .. ' ' .. (ok and filename or '[Error]') .. ' '
    end,
    hl = function(self)
        local mode = C.get_current_mode()
        -- Safe highlight access
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = 'winbar_' .. mode .. '_2' })
        local bg = ok and hl.bg or nil
        return {
            fg = self.icon_color,
            bg = bg,
            bold = true,
        }
    end,
}

C.ScreenKey = {
    provider = function()
        return require('screenkey').get_keys()
    end,
    update = {
        'User',
        pattern = 'Screenkey*',
        callback = vim.schedule_wrap(function()
            vim.cmd('redrawstatus')
        end),
    },
    hl = function()
        return { fg = '#ffffda', bg = '#a04fb0', italic = true }
    end,
}

C.TechdeusFileEncoding = {
    provider = function()
        local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
        return ' ' .. enc:upper() .. ' '
    end,
    hl = { fg = col.colors.yellow },
}

C.Align = { provider = "%=" }

C.Force_inactive_filetypes = {
    '^aerial$',
    '^alpha$',
    '^chatgpt$',
    '^frecency$',
    '^lazy$',
    '^lazyterm$',
    '^netrw$',
    'mini.statusline',
    '^TelescopePrompt$',
    '^snacks_dashboard$',

}
C.file_types = {
    "alpha",
    "ctrlspace",
    "ctrlspace_help",
    "undotree",
    "diff",
    "Outline",
    "NvimTree",
    "LvimHelper",
    "dashboard",
    "vista",
    "spectre_panel",
    "DiffviewFiles",
    "flutterToolsOutline",
    "log",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "calendar",
    "neo-tree",
    "neo-tree-popup",
    "noice",
    "toggleterm",
    "git",
    "netrw",
    "dbee",
}

C.buftypes = {
    "nofile",
    "prompt",
    "help",
    "terminal",
}
C.S_filetypes = {
    '^git.*',
    'fugitive',
    'alpha',
    '^neo--tree$',
    '^neotest--summary$',
    '^neo--tree--popup$',
    '^NvimTree$',
    '^toggleterm$',
}

C.FullPath = {
    provider = function()
        local filename = vim.fn.expand('%:p')
        return filename
    end,
}

C.DeusStats = {
    init = function(self)
        self.wc = vim.fn.wordcount()
        self.mode = vim.fn.mode()
        self.lines = vim.api.nvim_buf_line_count(0)
    end,
    provider = function(self)
        local wc = self.wc
        local isVisualMode = self.mode:find('[vV]')

        local chars = (isVisualMode and wc.visual_chars ~= nil) and wc.visual_chars .. '/' .. wc.chars or wc.chars
        local words = (isVisualMode and wc.visual_words ~= nil) and wc.visual_words .. '/' .. wc.words or wc.words
        local lines = (isVisualMode and wc.visual_lines ~= nil) and wc.visual_lines .. '/' .. self.lines or self.lines
        return string.format(' %s %s %s %s %s %s ', chars, icons.cmp.Chars, words, icons.cmp.Words, lines, icons.cmp.Lines)
    end,
    hl = function()
        return {
            fg = col.colors.white,
            italic = true,
        }
    end,
    update = {
        'ModeChanged',
        'CursorMoved',
        'CursorMovedI',
        callback = function(self)
            self.wc = vim.fn.wordcount()
            self.mode = vim.fn.mode()
            self.lines = vim.api.nvim_buf_line_count(0)
            vim.cmd('redrawstatus')
        end,
    },
}

return C
