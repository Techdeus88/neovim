--Start-of-file--
return { -- Diff modules ~6~
    {    -- Fugitive: A Git wrapper so awesome, it should be illegal
        'tpope/vim-fugitive',
        lazy = true,
        config = true,
    },
    { -- Gitignore inside neovim
        "wintermute-cell/gitignore.nvim",
        lazy = true,
        config = true,
    },
    { -- Undotree: A tree view for Neovim undo tree
        'mbbill/undotree',
        event = { 'User BaseFile' },
        keys = {
            { "<F5>", "<Cmd>UndotreeToggle<CR>", desc = "Undotree" },
        },
        config = true,
    },
    { -- Git UI visualization platform
        'tanvirtin/vgit.nvim',
        depends = { 'nvim-lua/plenary.nvim' },
        event = 'VimEnter',
        config = function()
            local vgit_status_ok, vgit = pcall(require, "vgit")
            if not vgit_status_ok then
                return
            end
            vgit.setup({
                settings = {
                    live_blame = {
                        enabled = false,
                    },
                    live_gutter = {
                        enabled = false,
                    },
                },
            })
            vim.keymap.set("n", "<A-]>", function()
                vgit.hunk_down()
            end, { noremap = true, silent = true, desc = "Git hunk next" })
            vim.keymap.set("n", "<A-[>", function()
                vgit.hunk_up()
            end, { noremap = true, silent = true, desc = "Git hunk prev" })
            vim.keymap.set("n", "<Leader>gp", function()
                require("vgit").buffer_hunk_preview()
            end, { noremap = true, silent = true, desc = "Git hunk preview" })
            vim.keymap.set("n", "<Leader>gP", function()
                require("vgit").buffer_history_preview()
            end, { noremap = true, silent = true, desc = "Git history preview" })
            vim.keymap.set("n", "<Leader>gd", function()
                require("vgit").buffer_diff_preview()
            end, { noremap = true, silent = true, desc = "Git buffer diff preview" })
            vim.keymap.set("n", "<Leader>gD", function()
                require("vgit").project_diff_preview()
            end, { noremap = true, silent = true, desc = "Git project diff preview" })
        end,
    },
    { -- Gitsigns: for git related stuff
        "lewis6991/gitsigns.nvim",
        lazy = false,
        init = function()
            vim.keymap.set("n", "<Leader>g]", function()
                require("gitsigns").nav_hunk("next")
            end, { noremap = true, silent = true, desc = "Git next hunk" })
            vim.keymap.set("n", "<Leader>g[", function()
                require("gitsigns").nav_hunk("prev")
            end, { noremap = true, silent = true, desc = "Git prev hunk" })
            vim.keymap.set("n", "<Leader>gth", function()
                require("gitsigns").toggle_linehl()
            end, { noremap = true, silent = true, desc = "Git toggle hl" })
            vim.keymap.set("n", "<Leader>gtb", function()
                require("gitsigns").toggle_current_line_blame()
            end, { noremap = true, silent = true, desc = "Git toggle line blame" })
            vim.keymap.set("n", "<Leader>ghs", function()
                require("gitsigns").stage_hunk()
            end, { noremap = true, silent = true, desc = "Git hunk stage" })
            vim.keymap.set("v", "<Leader>ghs", function()
                require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, { noremap = true, silent = true, desc = "Git hunk stage" })
            vim.keymap.set("n", "<Leader>ghr", function()
                require("gitsigns").reset_hunk()
            end, { noremap = true, silent = true, desc = "Git hunk reset" })
            vim.keymap.set("v", "<Leader>ghr", function()
                require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, { noremap = true, silent = true, desc = "Git hunk reset" })
            vim.keymap.set("n", "<Leader>gbs", function()
                require("gitsigns").stage_buffer()
            end, { noremap = true, silent = true, desc = "Git buffer stage" })
            vim.keymap.set("n", "<Leader>gbr", function()
                require("gitsigns").reset_buffer()
            end, { noremap = true, silent = true, desc = "Git buffer reset" })
        end,
        config = function()
            local gitsigns_status_ok, gitsigns = pcall(require, "gitsigns")
            if not gitsigns_status_ok then
                return
            end
            local _, icons = pcall(require, "base.ui.icons")
            gitsigns.setup({
                current_line_blame_formatter = "➤ <author> ➤ <author_time:%Y-%m-%d> ➤ <summary>",
                current_line_blame_formatter_nc = "➤ Not Committed Yet",
                current_line_blame_opts = {
                    delay = 10,
                },
                numhl = false,
                signcolumn = true,
                signs_staged_enable = false,
                signs = {
                    untracked = { text = " " .. icons.common.vline },
                    changedelete = { text = " " .. icons.common.vline },
                    topdelete = { text = " " .. icons.common.vline },
                    delete = { text = " " .. icons.common.vline },
                    change = { text = " " .. icons.common.vline },
                    add = { text = " " .. icons.common.vline },
                },
                linehl = false,
            })
        end
    },
    { -- Diffview: A diff viewer for Neovim
        'sindrets/diffview.nvim',
        event = { 'User BaseFile' },
        config = function()
            local ok, diff_view = pcall(require, "diffview")
            if not ok then
                vim.notify("Diff view not loading", vim.log.levels.ERROR, {})
                return
            end

            local actions = require('diffview.actions')
            vim.opt_local.wrap = false
            vim.opt_local.list = false
            vim.opt_local.relativenumber = false
            vim.opt_local.cursorcolumn = false
            vim.opt_local.colorcolumn = '0'

            vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
                group = vim.api.nvim_create_augroup('techdeus_diffview', {}),
                pattern = 'diffview:///panels/*',
                callback = function()
                    vim.opt_local.cursorline = true
                    vim.opt_local.winhighlight = 'CursorLine:WildMenu'
                end,
            })

            diff_view.setup({
                cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
                enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
                keymaps = {
                    view = {
                        { 'n', 'q',              actions.close },
                        { 'n', '<Tab>',          actions.select_next_entry },
                        { 'n', '<S-Tab>',        actions.select_prev_entry },
                        { 'n', '<LocalLeader>a', actions.focus_files },
                        { 'n', '<LocalLeader>e', actions.toggle_files },
                    },
                    file_panel = { { 'n', 'q', actions.close }, { 'n', 'h', actions.prev_entry } },
                },
            })
        end,
    },
}
--End-of-file--
