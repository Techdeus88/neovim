--Start-of-file--
local funcs = require('core.funcs')
local utils = funcs.safe_require("base.utils")

-- Helper Functions
local function map(mode, l, r, opts)
  opts = opts or {}
  vim.keymap.set(mode, l, r, opts)
end

-- Toggle Functions
local function toggle_fold()
  if vim.bo.buftype == 'quickfix' then
    return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
  end
  local line = vim.fn.line('.')
  local foldlevel = vim.fn.foldlevel(line)
  if foldlevel == 0 then
    vim.notify('No fold found', vim.log.levels.INFO)
  else
    vim.cmd('normal! za')
    vim.cmd('normal! zz')
  end
end

local function toggle_location_list()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

local function toggle_quickfix_list()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

local function show_plugin_load_state()
  local module_state = require("base.metrics").get_load_state()
  for category, count in pairs(module_state) do
    local msg = string.format("%s %d", string.upper(category), count)
    vim.notify(msg, vim.log.levels.INFO,
      { id = "load_state-" .. category, title = "Plugin Load State", timeout = 10000 })
  end
end

local function open_latest_file_explorer()
  local mini_files = require('mini.files')
  mini_files.open(mini_files.get_latest_path())
end

local function open_directory_file_explorer()
  local mini_files = require('mini.files')
  mini_files.open(vim.api.nvim_buf_get_name(0), false)
  if mini_files.close() then
    return
  end
  mini_files.open()
end

local function toggle_window_statusline()
  require("base.utils").toggle_boo_statusline("window")
end

local function toggle_file_info_statusline()
  require("base.utils").toggle_boo_statusline("file_info")
end

local function toggle_statusline()
  require("base.utils").toggle_boo_statusline("toggle")
end

local function debug_settings()
  vim.notify(vim.inspect(Debug.get_settings()))
end

local function toggle_precognition()
  require("precognition").toggle()
end

local function diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

-- Basic Navigation
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map("n", "g", "g", { desc = "Go to first non-blank character of line", noremap = true, silent = true })
map("n", "gg", "gg", { desc = "Go to top of buffer", silent = true })
map("n", "G", "G", { desc = "Go to bottom of buffer", silent = true })

-- Visual Mode
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Search
map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Clear hlsearch and ESC' })

-- Tab Management
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Window Management
map('n', '\\', '<cmd>split<cr>', { desc = 'Horizontal split' })
map('n', '|', '<cmd>vsplit<cr>', { desc = 'Vertical Split' })
map('n', '<leader>wc', '<cmd>close<cr>', { desc = 'Close' })
map('n', '<leader>wT', '<cmd>wincmd T<cr>', { desc = 'Move window to new tab' })
map('n', '<leader>wr', '<cmd>wincmd r<cr>', { desc = 'rotate down/right' })
map('n', '<leader>wR', '<cmd>wincmd R<cr>', { desc = 'rotate up/left' })

-- Window Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Window Resizing
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
map('n', '<leader>w=', '<cmd>wincmd =<cr>', { desc = 'Equalize size' })
map('n', '<leader>wk', '<cmd>resize +5<cr>', { desc = 'Up' })
map('n', '<leader>wj', '<cmd>resize -5<cr>', { desc = 'Down' })
map('n', '<leader>wh', '<cmd>vertical resize +3<cr>', { desc = 'Left' })
map('n', '<leader>wl', '<cmd>vertical resize -3<cr>', { desc = 'Right' })

-- Plugin Management
map('n', "<leader>md", "<cmd>MiniDepsUpdate<cr>", { desc = "MiniDeps Update" })
map("n", "<leader>mL", show_plugin_load_state, { desc = "Show current plugin load state" })
map('n', "<leader>mm", "<cmd>Mason<cr>", { desc = "Mason" })
map('n', '<leader>mP', ':ShowPluginInfo<CR>', { noremap = true, silent = true })

-- Global State
map("n", "<leader>mGJ", "<cmd>DisplayglobalJson<cr>", { desc = "Show current global state json" })
map("n", "<leader>mGI", "<cmd>DisplayglobalIndent<cr>", { desc = "Show current global state indent" })
map("n", "<leader>mGT", "<cmd>DisplayglobalTab<cr>", { desc = "Show current global state tab" })
map("n", "<leader>mGG", "<cmd>Displayglobal<cr>", { desc = "Show current global state" })

-- File Operations
map("n", "<leader>f", ":Files!<cr>", { desc = "Find files" })
map("n", "<leader>g", ":RG!<cr>", { desc = "Find inside files" })
map('n', '<leader>bn', '<cmd>enew<cr>', { desc = 'New file' })
map('n', '<leader>bs', '<cmd>w<cr>', { desc = 'Save file' })
map('n', '<leader>gp', 'gf', { desc = 'Open path under cursor' })

-- Buffer Management
map("n", "<D-a>", "ggVG", { desc = "Select entire buffer" })
map('n', '<leader>bd', '<cmd>bd<cr>', { desc = 'Delete buffer' })
map('n', '<tab>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '<S-tab>', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })
map('n', '<leader>bD', '<cmd>%bd|e#|bd#<cr>', { desc = 'Close all but the current buffer' })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Folding and Lists
map('n', '<CR>', toggle_fold, { desc = 'Toggle fold' })
map("n", "<leader>xl", toggle_location_list, { desc = "Location List" })
map("n", "<leader>xq", toggle_quickfix_list, { desc = "Quickfix List" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- Text Operations
map("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true, desc = "Move line up" })
map("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true, desc = "Move line down" })
map("x", "<A-j>", ":move '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection up" })
map("x", "<A-k>", ":move '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection down" })
map("v", "<A-S-k>", "y`>p`<", { silent = true })
map("v", "<A-S-j>", "y`<kp`>", { silent = true })
map("n", "<A-S-k>", "Vy`>p`<", { silent = true })
map("n", "<A-S-j>", "Vy`<p`>", { silent = true })

-- File Explorer
map("n", '-', open_latest_file_explorer, { desc = 'File explorer (Latest file)' })
map("n", '<leader>-', open_directory_file_explorer, { desc = 'File Explorer (Directory)' })

-- Statusline
map("n", "<leader>sW", toggle_window_statusline, { desc = "Boo statusline window" })
map("n", "<leader>sF", toggle_file_info_statusline, { desc = "Boo statusline file info" })
map("n", "<leader>sY", toggle_statusline, { desc = "Boo statusline toggle" })

-- Debug and Development
map("n", "<leader>DS", debug_settings, { desc = "Debug Settings" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

-- Precognition
map("n", "<leader>tP", toggle_precognition, { desc = "Toggle Precognition" })

-- Native Snippets (for nvim < 0.11)
if vim.fn.has("nvim-0.11") == 0 then
  local function jump_snippet(direction)
    return vim.snippet.active({ direction = direction }) and "<cmd>lua vim.snippet.jump(-1)<cr>" or "<S-Tab>"
  end

  map("s", "<Tab>", jump_snippet(1), { expr = true, desc = "Jump Next" })
  map({ "i", "s" }, "<S-Tab>", jump_snippet(-1), { expr = true, desc = "Jump Previous" })
end

--End-of-file--
