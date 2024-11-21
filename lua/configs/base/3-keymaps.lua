local keymaps = {}
local keymaps_ft = {}
local keymaps_lsp = {}

local is_available = require("configs.base.utils.metrics").is_available
local opts = function(desc) return { noremap = true, silent = true, desc = desc ~= nil and desc or " " } end
local function map(mode, lhs, rhs, opts)
    local opts_local = opts ~= nil and opts or {}
    opts_local.silent = opts ~= nil and opts.silent ~= false or false
    vim.keymap.set(mode, lhs, rhs, opts_local)
end

keymaps["normal"] = {
    { "<Space>", "", "Map Space as leader" },
    { "<Esc>", "<Esc>:noh<CR>", "Esc" }, -- Remove highlight after search
    { "j", "gj", "j" }, -- Re-map j
    { "k", "gk", "k" }, -- Re-map k
    { "<C-d>", "<C-d>zz", "C-d" }, -- Re-map C-d
    { "<C-u>", "<C-u>zz", "C-u" }, -- Re-map C-u
    { "<C-f>", "<C-f>zz", "C-f" }, -- Re-map C-f
    { "<C-b>", "<C-b>zz", "C-b" }, -- Re-map C-b
    { "<C-c>N", ":enew<CR>", "Create empty buffer" }, -- Create empty buffer
    { "<C-c>s", ":Save<CR>", "Save" }, -- Save
    { "<C-c>a", ":wa<CR>", "Save all" }, -- Save all
    { "<C-c>e", ":Quit<CR>", "Close DeusIDE" }, -- Close all, exit nvim
    { "<C-c>x", "<C-w>c", "Close current window" }, -- Close current window
    { "<C-c>o", "<C-w>o", "Close other windows" }, -- Close other windows
    { "<C-c>d", ":bdelete<CR>", "Delete buffer" }, -- BDelete
    { "<C-c>", ":wincmd<CR>", "Win resize =" }, -- Win resize
    { "<C-h>", "<C-w>h", "Move to window left" }, -- Move to window left
    { "<C-l>", "<C-w>l", "Move to window right" }, -- Move to window right
    { "<C-j>", "<C-w>j", "Move to window down" }, -- Move to window down
    { "<C-k>", "<C-w>k", "Move to window up" }, -- Move to window up
    { "<S-h>", "<C-w>h", "Move to window left" }, -- Move to window left
    { "<S-l>", "<C-w>l", "Move to window right" }, -- Move to window right
    { "<S-j>", "<C-w>j", "Move to window down" }, -- Move to window down
    { "<S-k>", "<C-w>k", "Move to window up" }, -- Move to window up
    { "|", "<cmd>vsplit<cr>", "Vertical Split" }, -- Vertical Split
    { "\\", "<cmd>split<cr>", "Horizontal Split" }, -- Horizontal Split

    { "<C-Left>", ":vertical resize -2<CR>", "Resize width -" }, -- Resize width -
    { "<C-Right>", ":vertical resize +2<CR>", "Resize width +" }, -- Resize width +
    { "<C-Up>", ":resize -2<CR>", "Resize height -" }, -- Resize height -
    { "<C-Down>", ":resize +2<CR>", "Resize height +" }, -- Resize height +

    { "tn", ":tabn<CR>", "Tab next" }, -- Tab next
    { "tp", ":tabp<CR>", "Tab prev" }, -- Tab prev
    { "tt", ":tabnew<CR>", "Tab new" }, -- Tab prev
    { "tr", ":TabRename", "Tab rename" },

    { "<A-j>", ":m '>+1<cr>gv=gv", "Move Down" },
    { "<A-k>", ":m '<-2<cr>gv=gv", "Move Up" },

    { '<Leader>bc', ':let @*=expand("%")<CR>', 'File: Copy path' },
    { "bn", ":bufn<CR>", "Buf: next" }, -- Buffer: next
    { "bp", ":bufp<CR>", "Buf: prev" }, -- Buffer: prev
    { "<leader>bn", ":enew<CR>", "Buf: new" }, -- Buffer new

    { "<C-c>ff", ":CloseFloatWindows<CR>", "Close float windows" }, -- Close float windows
    { "<C-c>c", ":Inspect<CR>", "Inspect" }, -- Inspect
    { "zR", "<cmd>lua require('ufo').openAllFolds()<CR>", "Open folds" },
    { "zM", "<cmd>lua require('ufo').closeAllFolds()<CR>", "Close Folds" },
    { "<Space><Space>h", "<cmd>lua require('mini.starter').open()<CR>", "Open Mini starter" },
    {
        "<leader>/",
        "gcc",
        "Toggle comment line",
    },
    {
        "<leader>/",
        "gc",
        "Toggle comment",
    },
    { "<C-s>", "<cmd>w!<cr>", "Force write" },
    { "|", "<cmd>vsplit<cr>", "Vertical Split" },
    { "\\", "<cmd>split<cr>", "Horizontal Split" },
    {
        "gh",
        "^",
        "Go to the first character of the line (aliases gh to ^)",
    },
    {
        "0",
        "^",
        "Go to the first character of the line (aliases 0 to ^)",
    },
    {
        "gl",
        "$",
        "Go to the last character of the line (aliases gl to ^)",
    },
    { "<A-j>", "<cmd>m .+1<cr>", "Move Down" },
    { "<A-k>", "<cmd>m .-2<cr>", "Move Up" },
    { "<A-p>", "_dP'", "Move line with paste" },
    {
        "gg",
        function()
            vim.g.minianimate_disable = true
            if vim.v.count > 0 then
                vim.cmd("normal! " .. vim.v.count .. "gg")
            else
                vim.cmd("normal! gg0")
            end
            vim.g.minianimate_disable = false
        end,
        "gg and go to the first position",
    },
    {
        "G",
        function()
            vim.g.minianimate_disable = true
            vim.cmd("normal! G$")
            vim.g.minianimate_disable = false
        end,
        "G and go to the last position",
    },
    {
        "<C-a>", -- to move to the previous position press ctrl + oo
        function()
            vim.g.minianimate_disable = true
            vim.cmd("normal! gg0vG$")
            vim.g.minianimate_disable = false
        end,
        "Visually select all",
    },
    -- shifted movement keys ----------------------------------------------------
    { "<S-Down>", function() vim.api.nvim_feedkeys("8j", "n", true) end, "Fast move down" },
    { "<S-J>", function() vim.api.nvim_feedkeys("7j", "n", true) end, "Fast move down" },
    { "<S-Up>", function() vim.api.nvim_feedkeys("7k", "n", true) end, "Fast move up" },
    { "<S-K>", function() vim.api.nvim_feedkeys("7k", "n", true) end, "Fast move up" },
    {
        "<S-PageDown>",
        function()
            local current_line = vim.fn.line(".")
            local total_lines = vim.fn.line("$")
            local target_line = current_line + 1 + math.floor(total_lines * 0.20)
            if target_line > total_lines then target_line = total_lines end
            vim.api.nvim_win_set_cursor(0, { target_line, 0 })
            vim.cmd("normal! zz")
        end,
        "Page down exactly a 20% of the total size of the buffer",
    },
    {
        "<S-PageUp>",
        function()
            local current_line = vim.fn.line(".")
            local target_line = current_line - 1 - math.floor(vim.fn.line("$") * 0.20)
            if target_line < 1 then target_line = 1 end
            vim.api.nvim_win_set_cursor(0, { target_line, 0 })
            vim.cmd("normal! zz")
        end,
        "Page up exactly 20% of the total size of the buffer",
    },
    {
        "<leader><C-w>",
        function()
            local picked_window_id = require("picker").pick_window({
                include_current_win = true,
            }) or vim.api.nvim_get_current_win()
            vim.api.nvim_set_current_win(picked_window_id)
        end,
        "Pick a window",
    },
    {
        "<leader><C-W>",
        require("configs.base.utils.windows").swap_windows,
        "Swap windows",
    },
    { "<leader><C-w>i", "<cmd>Active_Win_Config_Info<cr>", "Get the active window info" },
    { "<leader>fk", "<cmd>MiniExtra.pickers.keymaps<cr>", "Find keymaps" },
    { "<leader>fs", "<cmd>MiniExtra.pickers.spellsuggest<cr>", "Find spelling" },
    { "<leader><C-f>", "<cmd>MiniExtra.pickers.history({ scope = ':'})<cr>", "Filter command history" },
    { "<leader><C-s>", "<cmd>MiniExtra.pickers.buf_lines({ scope = 'current' })<cr>", "Find lines" },
    { "<leader>EE", function() require("configs.base.utils.editor").EditEntireFile() end, "Editor: Copy Entire File" },
}

keymaps["visual"] = {
    { "j", "gj" }, -- Re-map j
    { "k", "gk" }, -- Re-map k
    { "*", "<Esc>/\\%V" }, -- Visual search /
    { "#", "<Esc>?\\%V" }, -- Visual search ?
    { "<A-j>", ":m '>+1<cr>gv=gv", "Move Down" },
    { "<A-k>", ":m '<-2<cr>gv=gv", "Move Up" },
    { "<", "<gv", "Better indenting" },
    { ">", ">gv", "Better indenting" },
    { "<leader>ee", function() require("configs.base.utils.editor").EditVisual() end, "Editor: Copy and Edit visual text" },
    {
        "gg",
        function()
            vim.g.minianimate_disable = true
            if vim.v.count > 0 then
                vim.cmd("normal! " .. vim.v.count .. "gg")
            else
                vim.cmd("normal! gg0")
            end
            vim.g.minianimate_disable = false
        end,
        "gg and go to the first position (visual)",
    },
    {
        "G",
        function()
            vim.g.minianimate_disable = true
            vim.cmd("normal! G$")
            vim.g.minianimate_disable = false
        end,
        "G and go to the last position (visual)",
    },
}

keymaps["insert"] = {
    { "jj", "<Esc>", "Use jj as escape" },
    { "<A-j>", "<esc><cmd>m .+1<cr>gi", "Move Down" },
    { "<A-k>", "<esc><cmd>m .-2<cr>gi", "Move Up" },
}

keymaps["terminal"] = {
    { "JJ", "<C-\\><C-n>", opts("Use jj as escape") },
}

-- Add undo breakpoints
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")
-- Visual overwrite paste
map({ "v", "x" }, "p", '"_dP')

-- Do not copy on x
map({ "v", "x" }, "x", '"_x')

-- Increment/decrement
map({ "n", "v", "x" }, "-", "<C-x>")
map({ "n", "v", "x" }, "=", "<C-a>")

-- Move to line beginning and end
map({ "n", "v", "x" }, "gh", "^", { desc = "Beginning of line" })
map({ "n", "v", "x" }, "gl", "$", { desc = "End of line" })
-- Move text up and down
map({ "v", "x" }, "J", ":move '>+1<CR>gv-gv")
map({ "v", "x" }, "K", ":move '<-2<CR>gv-gv")

-- Clear search, diff update and redraw
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Consistent n/N search navigation
map("n", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Center Cursors
map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("c", "<M-h>", "<Left>", { silent = false, desc = "Left" })
map("c", "<M-l>", "<Right>", { silent = false, desc = "Right" })

-- Don't `noremap` in insert mode to have these keybindings behave exactly
-- like arrows (crucial inside TelescopePrompt)
map("i", "<M-h>", "<Left>", { noremap = false, desc = "Left" })
map("i", "<M-j>", "<Down>", { noremap = false, desc = "Down" })
map("i", "<M-k>", "<Up>", { noremap = false, desc = "Up" })
map("i", "<M-l>", "<Right>", { noremap = false, desc = "Right" })

map("t", "<M-h>", "<Left>", { desc = "Left" })
map("t", "<M-j>", "<Down>", { desc = "Down" })
map("t", "<M-k>", "<Up>", { desc = "Up" })
map("t", "<M-l>", "<Right>", { desc = "Right" })

keymaps_ft["set"] = function()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "netrw" },
        callback = function() vim.opt_local.statuscolumn = "" end,
        group = "DeusIDE",
    })
end

keymaps_lsp["normal"] = {
    {
        "K",
        "<cmd>lua vim.lsp.buf.hover()<cr>",
        "LSP: hover",
    },
    {
        "<leader>gd",
        "<cmd>lua vim.lsp.buf.definition()<cr>",
        "LSP: definition",
    },
    {
        "<leader>gD",
        "<cmd>lua vim.lsp.buf.declaration()<cr>",
        "LSP: declaration",
    },
    {
        "<leader>gi",
        "<cmd>lua vim.lsp.buf.implementation()<cr>",
        "LSP: implementation",
    },
    {
        "<leader>go",
        "<cmd>lua vim.lsp.buf.type_definition()<cr>",
        "LSP: type definition",
    },

    {
        "<leader>gr",
        "<cmd>lua vim.lsp.buf.references()<cr>",
        "LSP: buffer references",
    },
    {
        "<leader>gs",
        "<cmd>lua vim.lsp.buf.signature_help()<cr>",
        "LSP: buffer signature",
    },

    {
        "<leader>gR",
        "<cmd>lua vim.lsp.buf.rename()<cr>",
        "LSP: buffer rename",
    },
    {
        "<leader>ga",
        "<cmd>lua vim.lsp.buf.code_action()<cr>",
        "LSP: code actions",
    },
    {
        "<leader><F3>",
        "<cmd>lua vim.lsp.buf.format({async = true})<cr>",
        "LSP: autoformat",
    },
    { "<Leader>gI", "<cmd>LspInfo<cr>", "Show LSP info" },
}

keymaps_ft["dart"] = function()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "dart",
        },
        callback = function()
            vim.keymap.set(
                "n",
                "<C-c><C-c>f",
                function() vim.cmd("FlutterRun") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterRun" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>r",
                function() vim.cmd("FlutterReload") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterReload" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>R",
                function() vim.cmd("FlutterRestart") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterRestart" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>q",
                function() vim.cmd("FlutterQuit") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterQuit" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>d",
                function() vim.cmd("FlutterDevices") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterDevices" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>m",
                function() vim.cmd("FlutterEmulators") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterEmulators" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>o",
                function() vim.cmd("FlutterOutlineToggle") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterOutlineToggle" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>t",
                function() vim.cmd("FlutterDevTools") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterDevTools" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>T",
                function() vim.cmd("FlutterDevToolsActivate") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterDevToolsActivate" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>l",
                function() vim.cmd("FlutterLspRestart") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterLspRestart" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>a",
                function() vim.cmd("FlutterReanalyze") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterReanalyze" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>e",
                function() vim.cmd("FlutterRename") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterRename" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>s",
                function() vim.cmd("FlutterSuper") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterSuper" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>D",
                function() vim.cmd("FlutterDetach") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterDetach" }
            )
            vim.keymap.set(
                "n",
                "<C-c><C-c>u",
                function() vim.cmd("FlutterCopyProfilerUrl") end,
                { buffer = true, noremap = true, silent = true, desc = "FlutterCopyProfilerUrl" }
            )
        end,
        group = "LvimIDE",
    })
end

keymaps_lsp["visual"] = {
    {
        "<F3>",
        "<cmd>lua vim.lsp.buf.format({async = true})<cr>",
        "LSP: autoformat",
    },
}
--==================================--
---------Conditipnal Keymaps----------
--==================================--
-- if is_available("dial.nvim") then
--   local M = require("dial.map")
--
--   keymaps["normal"] = vim.list_extend(keymaps["normal"], {
--     { "<C-a>",  function() return M.manipulate("increment", "normal") end,  "Normal Increment" },
--     { "<C-x>",  function() return M.manipulate("decrement", "normal") end,  "Normal Decrement" },
--     { "g<C-a>", function() return M.manipulate("increment", "gnormal") end, "GNormal Increment" },
--     { "g<C-x>", function() return M.manipulate("decrement", "gnormal") end, "GNormal Decrement" },
--   })
--
--   keymaps["visual"] = vim.list_extend(keymaps["visual"], {
--     { "<C-a>",  function() return M.manipulate("increment", "visual") end,  "Visual Increment" },
--     { "<C-x>",  function() return M.manipulate("decrement", "visual") end,  "Visual Decrement" },
--     { "g<C-a>", function() return M.manipulate("increment", "gvisual") end, "GVisual Increment" },
--     { "g<C-x>", function() return M.manipulate("decrement", "gvisual") end, "GVisual Decrement" },
--   })
-- end

if is_available("nvim-notify") then
    keymaps["normal"] = vim.list_extend(
        keymaps["normal"],
        {
            {
                "<leader>un",
                function() require("notify").dismiss({ silent = true, pending = true }) end,
                "Dismiss All Notifications",
            },
        }
    )
end


if is_available("fittencode.nvim") then
    keymaps["normal"] = vim.list_extend(
        keymaps["normal"],
    {
        {
            "<leader>fd",
            "<cmd>Fitten document_code<cr>",
             "document code",

        },
        {
            "<leader>fe",
            "<cmd>Fitten explain_code<cr>",
            "explain code",

        },
        {
            "<leader>ff",
            "<cmd>Fitten find_bugs<cr>",
             "find bugs",

        },
        {
            "<leader>fg",
            "<cmd>Fitten generate_unit_test<cr>",
             "generate unit test",
        },
        {
            "<leader>fi",
            "<cmd>Fitten implement_features<cr>",
            "implement features",

        },
        {
            "<leader>fo",
            "<cmd>Fitten optimize_code<cr>",
            "optimize code",

        },
        {
            "<leader>fr",
            "<cmd>Fitten refactor_code<cr>",
             "refactor code",

        },
        {
            "<leader>fl",
            "<cmd>Fitten identify_programming_language<cr>",
            "identify programming language",

        },
        {
            "<leader>fa",
            "<cmd>Fitten analyze_data<cr>",
             "analyze data",

        },
        {
            "<leader>fc",
            "<cmd>Fitten toggle_chat<cr>",
             "toggle chat",
        }
    })
end

if is_available("noice.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<leader>sn", "", "+Noice" },
        {
            "<S-Enter>",
            function() require("noice").redirect(vim.fn.getcmdline()) end,
            "Redirect Cmdline",
        },
        {
            "<leader>snl",
            function() require("noice").cmd("last") end,
            "Noice Last Message",
        },
        {
            "<leader>snh",
            function() require("noice").cmd("history") end,
            "Noice History",
        },
        { "<leader>sna", function() require("noice").cmd("all") end, "Noice All" },
        { "<leader>snd", function() require("noice").cmd("dismiss") end, "Dismiss All" },
        {
            "<leader>snt",
            function() require("noice").cmd("pick") end,
            "Noice Picker (Mini.Pick)",
        },
        {
            "<c-f>",
            function()
                if not require("noice.lsp").scroll(4) then return "<c-f>" end
            end,
            "Scroll Forward",
        },
        {
            "<c-b>",
            function()
                if not require("noice.lsp").scroll(-4) then return "<c-b>" end
            end,
            "Scroll Backward",
        },
    })
end

if is_available("grug-far.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        {
            "<S-CMD>f",
            function()
                local grug = require("grug-far")
                local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
                grug.open({
                    transient = true,
                    prefills = {
                        filesFilter = ext and ext ~= "" and "*." .. ext or nil,
                    },
                })
            end,
            "Grug: search/replace within current project",
        },
        {
            "<M-f>",
            function()
                local grug = require("grug-far")
                grug.open({ prefills = { paths = vim.fn.expand("%") } })
            end,
            "Grug: search/replace within current open file",
        },

        {
            "<S-M-w>",
            function()
                local grug = require("grug-far")
                grug.open({
                    prefills = { search = vim.fn.expand("<cword>") },
                })
            end,
            "Grug: search/replace word under cursor",
        },
    })
end

if is_available("tabby.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<leader>tp", ":Tabby pick_window<CR>", "Select a window" },
        { "<leader>tr", ":Tabby rename_tab ", "Rename current tab" },
    })
end

if is_available("which-key.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<leader>?", function() require("which-key").show({ global = false }) end, "WhichKey" },
    })
end

if is_available("Navigator.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<A-h>", "<CMD>NavigatorLeft<CR>", "Navigator: left" },
        { "<A-l>", "<CMD>NavigatorRight<CR>", "Navigator: right" },
        { "<A-k>", "<CMD>NavigatorUp<CR>", "Navigator: up" },
        { "<A-j>", "<CMD>NavigatorDown<CR>", "Navigator: down" },
        { "<A-p>", "<CMD>NavigatorPrevious<CR>", "Navigator: previous" },
        { "<S-h>", "<CMD>NavigatorLeft<CR>", "Nav: Left" },
        { "<S-l>", "<CMD>NavigatorRight<CR>", "Nav: Right" },
        { "<S-k>", "<CMD>NavigatorUp<CR>", "Nav: Up" },
        { "<S-j>", "<CMD>NavigatorDown<CR>", "Nav: Down" },
        { "<S-p>", "<CMD>NavigatorPrevious<CR>", "Nav: Previous" },
    })
end

if is_available("multicursors.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        {
            "<C-/>",
            function()
                require("multicursors.utils").call_on_selections(function(selection)
                    vim.api.nvim_win_set_cursor(0, { selection.row + 1, selection.col + 1 })
                    local line_count = selection.end_row - selection.row + 1
                    vim.cmd("normal " .. line_count .. "gcc")
                end)
            end,
            "Comment selections",
        },
        { "<leader>m", "<cmd>MCStart<cr>", "Create a multicursor selection" },
    })
end

if is_available("flybuf.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<leader><Tab>", function() require("flybuf").toggle() end, "Open Fly buffer menu" },
    })
end

-- treesitter
if is_available("nvim-treesitter") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<leader>pT", "<cmd>TSUpdate<cr>", "Treesitter update" },
        { "<leader>pt", "<cmd>TSInstallInfo<cr>", "Treesitter open" },
    })
end

if is_available("mini.nvim") then
    local utils_files = require("configs.base.utils.files")

    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        {
            "<leader>sf",
            function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end,
            "Mini.Files: Open",
        },
        {
            "<leader>sF",
            function() require("mini.files").open(vim.uv.cwd(), true) end,
            "Mini.Files: Open cwd",
        },
        {
            "_",
            function()
                local path = vim.bo.filetype ~= "nofile" and vim.api.nvim_buf_get_name(0) or nil
                require("mini.files").open(path)
            end,
            "MiniFiles: Open",
        },
        { "-", function() utils_files.open_current() end, "Mini.Files: Open CWD" },
        { "+", function() utils_files.open_config() end, "Mini.Files: Config directory" },
    })
end

if is_available("undotree") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<leader>uT", function() vim.cmd("UndotreeToggle") end, "Toggle Undotree" },
    })
end

if is_available("NeoZoom.lua") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<S-Tab>", function() vim.cmd("NeoZoomToggle") end, "Toggle NeoZoom" },
    })
end

if is_available("NeoTerm.lua") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<M-Tab>", function() vim.cmd("NeoTermToggle") end, "Toggle NeoTerm" },
        { "<M-Tab>", function() vim.cmd("NeoTermEnterNormal") end, "Enter NeoTerm" },
        { "<leader>sP", function(args) require("stickybuf").pin(args.buf) end, "Pin buffer to window" },
        {
            "<leader>spT",
            function(args)
                local ft_type = vim.bo[args.buf].filetype
                -- require("stickybuf").pin(args.buf, { allow_filetype = ft_type })
            end,
            "Pin filetype to window",
        },
    })
end

if is_available("zen-mode.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        {
            "<leader><A-Tab>",
            function() require("zen-mode").toggle() end,
            "Toggle Zen Mode",
        },
    })
end

if is_available("no-neck-pain.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<leader>tw", "<cmd>NoNeckPain<cr>", "Toggle SLB Layout" },
        -- Increase and decrease width of NoNeckPain
        { "<leader>wu", "<cmd>NoNeckPainWidthUp<cr>", "Increase NoNeckPain Width" },
        { "<leader>wd", "<cmd>NoNeckPainWidthDown<cr>", "Decrease NoNeckPain Width" },
    })
end

if is_available("detour-nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<C-w>,", "<cmd>Detour<cr>", "Detour full screen " },
        { "<C-w>.", "<cmd>DetourCurrentWindow<cr>", "Detour current window" },
    })
end

if is_available("part-edit.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
        { "<S-e>", function() require("part-edit").part_edit() end, "Part Edit" },
        {  "<space>p", "<cmd>PartEdit<cr>", "Part Edit: edit selected code" },
    })
end

if is_available("part-edit.nvim") then
    keymaps["visual"] = vim.list_extend(keymaps["visual"], {
        { "<S-e>", function() require("part-edit").part_edit() end, "Part Edit" },
        {  "<space>p", "<cmd>PartEdit<cr>", "Part Edit: edit selected code" },
    })
end

if is_available("calendar.vim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
      {
        "<leader>cc",
        "<cmd>Calendar<cr>",
        "Launch Calendar App",
      },
    })
end

if is_available("sidebar.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {
      { "<leader>tS", function() require("sidebar-nvim").toggle() end, "Toggle sidebar"}
    })
end

if is_available("obsidian.nvim") then
    keymaps["normal"] = vim.list_extend(keymaps["normal"], {

        { "<leader>no", "<cmd>ObsidianOpen<cr>", "Obsidian: open" },
        { "<leader>nn", "<cmd>ObsidianNew<cr>", "Obsidian: new note" },
        {
          "<leader>ns",
          "<cmd>ObsidianSearch<cr>",
          "Obsidian: search notes",
        },
        {
          "<leader>nt",
          "<cmd>ObsidianTags<cr>",
          "Obsidian: list notes by tags",
        },
        {
          "<leader>nq",
          "<cmd>ObsidianQuickSwitch<cr>",
          "Obsidian: quick workspace switch",
        },
        {
          "<leader>nw",
          "<cmd>ObsidianWorkspace work<cr>",
          "Obsidian: change to work workspace",
        },
        {
          "<leader>np",
          "<cd>ObsidianWorkspace personal<cr>",
          "Obsidian: change to home workspace",
        }
    })
end

if is_available("gitsigns.nvim") then
    keymaps_lsp["normal"] = vim.list_extend(keymaps_lsp["normal"], {
        { "<A-]>", "GitSignsNextHunk", "Git Signs: Next Hunk" },
        { "<A-[>", "GitSignsPrevHunk", "Git Signs: Prev Hunk" },
        { "<A-;>", "GitSignsPreviewHunk", "Git Signs: Preview Hunk" },
        { "<C-c>b", "GitSignsToggleLineBlame", "Git Signs: Toogle Line Blame" },
        { "<C-c>k", "GitSignsBlameLine", "Git Signs: Line Blame" },
        { "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk" },
        { "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk" },
    })

    keymaps_lsp["visual"] = vim.list_extend(keymaps_lsp["visual"], {
        { "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk" },
        { "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk" },
        { "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk" },
    })
end

if is_available("fittencode.nvim") then
       keymaps["visual"] = vim.list_extend(
        keymaps["visual"],
    {
        {
            "<leader>fd",
            "<cmd>require('fittencode') document_code<cr>",
             "document code",
        },
        {
            "<leader>fe",
            "<cmd>Fitten explain_code<cr>",
            "explain code",

        },
        {
            "<leader>ff",
            "<cmd>Fitten find_bugs<cr>",
             "find bugs",

        },
        {
            "<leader>fg",
            "<cmd>Fitten generate_unit_test<cr>",
             "generate unit test",

        },
        {
            "<leader>fi",
            "<cmd>Fitten implement_features<cr>",
            "implement features",

        },
        {
            "<leader>fo",
            "<cmd>Fitten optimize_code<cr>",
            "optimize code",

        },
        {
            "<leader>fr",
            "<cmd>Fitten refactor_code<cr>",
             "refactor code",

        },
        {
            "<leader>fl",
            "<cmd>Fitten identify_programming_language<cr>",
            "identify programming language",

        },
        {
            "<leader>fa",
            "<cmd>Fitten analyze_data<cr>",
             "analyze data",

        },
        {
            "<leader>fc",
            "<cmd>Fitten toggle_chat<cr>",
             "toggle chat",
        }
    })
end

if is_available("trouble.nvim") then
    keymaps_lsp["normal"] = vim.list_extend(keymaps_lsp["normal"], {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (Trouble)" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer Diagnostics (Trouble)" },
        { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", "Symbols (Trouble)" },
        { "<leader>xS", "<cmd>Trouble lsp toggle<cr>", "LSP references/definitions/... (Trouble)" },
        { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", "Location List (Trouble)" },
        { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", "Quickfix List (Trouble)" },
        {
            "[q",
            function()
                if require("trouble").is_open() then
                    require("trouble").prev({ skip_groups = true, jump = true })
                else
                    local ok, err = pcall(vim.cmd.cprev)
                    if not ok then vim.notify(err, vim.log.levels.ERROR) end
                end
            end,
            "Previous Trouble/Quickfix Item",
        },
        {
            "]q",
            function()
                if require("trouble").is_open() then
                    require("trouble").next({ skip_groups = true, jump = true })
                else
                    local ok, err = pcall(vim.cmd.cnext)
                    if not ok then vim.notify(err, vim.log.levels.ERROR) end
                end
            end,
            "Next Trouble/Quickfix Item",
        },
    })
end

return { keymaps = keymaps, keymaps_ft = keymaps_ft, keymaps_lsp = keymaps_lsp }
