local Config = {}

function Config.setup_navic_state()
    local icons = require("configs.base.ui.icons")
    local navic = require("nvim-navic")

    navic.setup({
        icons = icons.lsp,
        highlight = true,
        separator = " " .. icons.common.separator,
        lsp = {
            auto_attach = false,
            preference = nil,
        },
    })
end

function Config.setup_heirline_state()
    -- Clear any existing configuration
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" })
    local heirline = require("heirline")
    local status_line = require("modules.build_me.heirline.status_line").get_statusline()
    local status_column = require("modules.build_me.heirline.status_column").get_statuscolumn()
    local win_bar = require("modules.build_me.heirline.win_bar").get_winbar()
    local buf_types = require("modules.build_me.heirline.buftypes")
    local file_types = require("modules.build_me.heirline.filetypes")
    local base_colors = require("configs.base.colors").base_colors()
    local file_types_winbar = {}
    for i, v in ipairs(file_types) do
        file_types_winbar[i] = v
    end
    table.insert(file_types_winbar, "qf")
    table.insert(file_types_winbar, "replacer")
    -- Setup new configuration
    heirline.setup({
        statusline = status_line,
        statuscolumn = status_column,
        winbar = win_bar,
        opts = {
            colors = function() return base_colors end,
            disable_winbar_cb = function(args)
                local buf = args.buf
                local buftype = vim.tbl_contains(buf_types, vim.bo[buf].buftype)
                local filetype = vim.tbl_contains(file_types, vim.bo[buf].filetype)
                return buftype or filetype
            end,
        },
    })
end

return Config
