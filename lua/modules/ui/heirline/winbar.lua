local W = {}
local C = require("modules.ui.heirline.common")

local function get_current_line_width()
    -- Function to get the current line width
    local current_line = vim.api.nvim_get_current_line()
    return current_line ~= nil and vim.fn.strwidth(current_line) or 0
end

local function calculate_column_percentage()
    local current_column = vim.api.nvim_win_get_cursor(0)[2]
    local total_columns = get_current_line_width()
    if total_columns <= 0 then
        return '0%'
    end
    local percentage = (current_column / total_columns) * 100
    return percentage >= 98 and 'End' or percentage <= 2 and 'Beg' or string.format('%d%%', percentage)
end

local Navic = function()
    return {
        condition = function() return require("nvim-navic").is_available() end,
        static = {
            -- create a type highlight map
            type_hl = {
                File = "Directory",
                Module = "@include",
                Namespace = "@namespace",
                Package = "@include",
                Class = "@structure",
                Method = "@method",
                Property = "@property",
                Field = "@field",
                Constructor = "@constructor",
                Enum = "@field",
                Interface = "@type",
                Function = "@function",
                Variable = "@variable",
                Constant = "@constant",
                String = "@string",
                Number = "@number",
                Boolean = "@boolean",
                Array = "@field",
                Object = "@type",
                Key = "@keyword",
                Null = "@comment",
                EnumMember = "@field",
                Struct = "@structure",
                Event = "@keyword",
                Operator = "@operator",
                TypeParameter = "@type",
            },
            -- bit operation dark magic, see below...
            enc = function(line, col, winnr)
                return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
            end,
            -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
            dec = function(c)
                local line = bit.rshift(c, 16)
                local col = bit.band(bit.rshift(c, 6), 1023)
                local winnr = bit.band(c, 63)
                return line, col, winnr
            end
        },
        init = function(self)
            local data = require("nvim-navic").get_data() or {}
            local children = {}
            -- create a child for each level
            for i, d in ipairs(data) do
                -- encode line and column numbers into a single integer
                local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
                local child = {
                    {
                        provider = d.icon,
                        hl = self.type_hl[d.type],
                    },
                    {
                        -- escape `%`s (elixir) and buggy default separators
                        provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ''),
                        -- highlight icon only or location name as well
                        -- hl = self.type_hl[d.type],

                        on_click = {
                            -- pass the encoded position through minwid
                            minwid = pos,
                            callback = function(_, minwid)
                                -- decode
                                local line, col, winnr = self.dec(minwid)
                                vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
                            end,
                            name = "heirline_navic",
                        },
                    },
                }
                -- add a separator only if needed
                if #data > 1 and i < #data then
                    table.insert(child, {
                        provider = " > ",
                        hl = { fg = 'bright_fg' },
                    })
                end
                table.insert(children, child)
            end
            -- instantiate the new child, overwriting the previous one
            self.child = self:new(children, 1)
        end,
        -- evaluate the children containing navic components
        provider = function(self)
            return self.child:eval()
        end,
        hl = { fg = "gray" },
        update = 'CursorMoved'
    }
end

W.RowScrollBar = {
    static = {
        sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' },
    },
    provider = function(self)
        -- Handle edge cases safely
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        local total_lines = vim.api.nvim_buf_line_count(0)

        -- Protect against division by zero or other errors
        if total_lines <= 0 then
            return string.rep(self.sbar[1], 2)
        end

        local line_ratio = math.min(1, math.max(0, (current_line - 1) / total_lines))
        local index = math.min(#self.sbar, math.max(1, math.floor(line_ratio * #self.sbar) + 1))

        -- Always return a string, never nil
        return string.rep(self.sbar[index] or self.sbar[1], 2)
    end,
    hl = function()
        local mode_color = C.get_inverted_color()
        return { fg = mode_color, bold = true }
    end,
}

W.ColumnScrollBar = {
    static = {
        sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' },
    },
    provider = function(self)
        -- Use pcall to safely handle potential errors
        local ok, pos = pcall(vim.api.nvim_win_get_cursor, 0)
        if not ok or type(pos) ~= 'table' or #pos < 2 then
            return '  ' -- Safe default
        end

        local current_column = pos[2]
        local line_length = 0

        -- Safely get the current line
        ok, line_length = pcall(function()
            local line = vim.api.nvim_get_current_line()
            return line and #line or 0
        end)

        if not ok or line_length <= 0 then
            return '  ' -- Safe default
        end

        -- Calculate ratio safely with bounds checking
        local line_ratio = math.min(1, math.max(0, current_column / line_length))
        local index = math.min(#self.sbar, math.max(1, math.floor(line_ratio * #self.sbar) + 1))

        -- Always return a valid string
        return string.format('%s%s', self.sbar[index], self.sbar[index])
    end,
    hl = function()
        local mode_color = C.get_current_color()
        return { fg = mode_color, bold = true }
    end,
}

W.DeusColumnRuler = {
    condition = function(self)
        local heirline_conditions = require('heirline.conditions')
        return heirline_conditions.buffer_matches({
            filetype = Global.fts,
        })
    end,
    provider = function()
        -- %l = current row the cursor sits in.
        -- %c = current column the cursor sits in.
        -- local current_columns = vim.apio.nvim_win_get_cursor(0)[2]
        -- local total_columns = get_current_line_width()
        local percentage = calculate_column_percentage()
        return "%7(%2c/%2{strwidth(getline('.'))}:" .. percentage
    end,
    hl = function()
        local mode_color = C.get_current_color()
        return { fg = mode_color, bold = true }
    end,
    on_click = {
        callback = function()
            vim.cmd('normal! gg')
        end,
        name = 'sl_totals_ruler_click',
    },
}

W.DeusRowRuler = {
    -- %l = current line number
    -- %L = number of lines in the buffer
    -- %c = column number
    -- %P = percentage through file of displayed window
    condition = function()
        local heirline_conditions = require('heirline.conditions')
        return heirline_conditions.buffer_matches({
            filetype = Global.fts,
        })
    end,
    provider = '%7(%l/%3L%):%P',
    hl = function()
        local mode_color = C.get_inverted_color()
        return { fg = mode_color, bold = true }
    end,
    on_click = {
        callback = function()
            vim.cmd('normal! gg')
        end,
        name = 'sl_totals_ruler_click',
    },
}

W.DeusRuler = {
    condition = function(self)
        local heirline_conditions = require('heirline.conditions')
        return not heirline_conditions.buffer_matches({
            filetype = self.filetypes,
        })
    end,
    provider = function()
        return "%7(%l/%3L% :%7(%2c/%2{strwidth(getline('.'))} %P " .. calculate_column_percentage()
    end,
    hl = function()
        local mode_color = C.get_current_color()
        return { fg = mode_color, bold = true }
    end,
    on_click = {
        callback = function()
            vim.cmd('normal! gg')
        end,
        name = 'sl_totals_ruler_click',
    },
}

W.get_winbar = function()
    local lib = require("heirline-components.all")
    return {
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        fallthrough = false,
        lib.component.winbar_when_inactive(),
        -- Regular winbar
        {
            condition = function() return lib.condition.is_active() end,
            {
                W.RowScrollBar,
                C.Space(),
                W.DeusRowRuler,
                lib.component.fill(),
                Navic(),
                lib.component.cmd_info(),
                lib.component.treesitter({
                    surround = {
                        separator = "right", -- where to add the separator.
                        color = "NONE", -- you can set a custom background color, for example "#444444"
                    },
                    str = { str = "Treesitter ON"}
                }),
                lib.component.breadcrumbs(),
                lib.component.fill(),
                W.DeusColumnRuler,
                C.Space(),
                W.ColumnScrollBar,
            },
            hl = "EdgyWinBar"
        },
    }
end

return W
