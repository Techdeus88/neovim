return { -- Editing ~9 modules~
    {
        "tris203/precognition.nvim",
        lazy = true,
        require = "precognition",
        opts = {
            startVisible = false,
            showBlankVirtLine = false,
            highlightColor = { link = "Comment" },
            hints = {
                Caret = { text = "^", prio = 2 },
                Dollar = { text = "$", prio = 1 },
                MatchingPair = { text = "%", prio = 5 },
                Zero = { text = "0", prio = 1 },
                w = { text = "w", prio = 10 },
                b = { text = "b", prio = 9 },
                e = { text = "e", prio = 8 },
                W = { text = "W", prio = 7 },
                B = { text = "B", prio = 6 },
                E = { text = "E", prio = 5 },
            },
            gutterHints = {
                G = { text = "G", prio = 10 },
                gg = { text = "gg", prio = 9 },
                PrevParagraph = { text = "{", prio = 8 },
                NextParagraph = { text = "}", prio = 8 },
            },
            disabled_fts = {
                "snacks*", "techdeu*",
            },
        },
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local status_ok, autopairs = pcall(require, "nvim-autopairs")
            if not status_ok then
                return
            end
            autopairs.setup {
                check_ts = true,
                ts_config = {
                    lua = { "string", "source" },
                    javascript = { "string", "template_string" },
                },
                disable_filetype = { "TelescopePrompt", "spectre_panel" },
                fast_wrap = {
                    map = "<M-f>",
                    chars = { "{", "[", "(", '"', "'" },
                    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
                    offset = 0,
                    end_key = "$",
                    keys = "qwertyuiopasdfghjklzxcvbnm",
                    check_comma = true,
                    highlight = "PmenuSel",
                    highlight_grey = "LineNr",
                },
            }
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        module = "nvim-ts-autotag",
        config = function()
            local ok, ts_autotag = pcall(require, "nvim-ts-autotag")
            if not ok then return end

            ts_autotag.setup({
                filetypes = { "html", "xml", "javascriptreact", "typescriptreact" },
            })
        end,
    },
    {
        'gbprod/stay-in-place.nvim',
        event = { 'User BaseDefered' },
        require = 'stay-in-place',
        opts = {},
    },
    {
        'max397574/better-escape.nvim',
        event = { 'User BaseDefered' },
        require = 'better_escape',
        opts = {},
    },
    {
        'johmsalas/text-case.nvim',
        lazy = true,
        require = 'textcase',
        opts = {
            prefix = 'tc',
        },
    },
    {
        'unblevable/quick-scope',
        lazy = true,
        config = true,
    },
    {
        'chrisgrieser/nvim-rip-substitute',
        cmd = { 'RipSubstitute' },
        keys = {
            {
                '<leader>rr',
                function()
                    require('rip-substitute').sub()
                end,
                mode = { 'n', 'x' },
                desc = 'Rip substitute',
            },
        },
        config = function()
            local nvim_rip_substitute_status_ok, nvim_rip_substitute = pcall(require, 'rip-substitute')
            if not nvim_rip_substitute_status_ok then
                return
            end
            nvim_rip_substitute.setup({
                popupWin = {
                    title = 'Replace',
                    border = 'single',
                    matchCountHlGroup = 'Keyword',
                    noMatchHlGroup = 'ErrorMsg',
                    hideSearchReplaceLabels = false,
                    position = 'bottom',
                },
                keymaps = {
                    confirm = '<CR>',
                    abort = 'q',
                    prevSubstitutionInHistory = '<Up>',
                    nextSubstitutionInHistory = '<Down>',
                    insertModeConfirm = '<C-CR>',
                },
                incrementalPreview = {
                    matchHlGroup = 'IncSearch',
                    rangeBackdrop = {
                        enabled = true,
                        blend = 40,
                    },
                },
            })
        end,
    },
    {
        'MagicDuck/grug-far.nvim',
        lazy = true,
        keys = {
            {
                '<A-s>',
                ':GrugFar<CR>',
                desc = 'GrugFar',
            },
        },
        config = function()
            local grug_far_status_ok, grug_far = pcall(require, 'grug-far')
            if not grug_far_status_ok then
                return
            end
            grug_far.setup({
                keymaps = {
                    replace = { n = '<localleader>er' },
                    qflist = { n = '<localleader>eq' },
                    syncLocations = { n = '<localleader>es' },
                    syncLine = { n = '<localleader>el' },
                    close = { n = '<localleader>ec' },
                    historyOpen = { n = '<localleader>et' },
                    historyAdd = { n = '<localleader>ea' },
                    refresh = { n = '<localleader>ef' },
                    gotoLocation = { n = '<enter>' },
                    pickHistoryEntry = { n = '<enter>' },
                },
            })
        end,
    },
}
