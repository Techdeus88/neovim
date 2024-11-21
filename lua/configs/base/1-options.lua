local global = require("core.globals")
require("configs.base.ui.fold")

local M = {}

M.global = function()
  vim.opt.ai = true
  vim.opt.breakindent = true
  vim.opt.shortmess = "ltToOCFI"
  vim.opt.termguicolors = true
  vim.opt.mouse = "nv"
  vim.opt.mousemodel = "extend"
  vim.opt.errorbells = true
  vim.opt.visualbell = true
  vim.opt.hidden = true
  vim.opt.fileformats = "unix,mac,dos"
  vim.opt.magic = true
  vim.opt.virtualedit = "block"
  vim.opt.encoding = "utf-8"
  vim.opt.viewoptions = "folds,cursor,curdir,slash,unix"
  vim.opt.sessionoptions = "curdir,help,tabpages,winsize"
  vim.opt.clipboard = "unnamedplus"
  vim.opt.wildignorecase = true
  vim.opt.wildignore =
  ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"
  vim.opt.backup = false
  vim.opt.writebackup = false
  vim.opt.swapfile = false
  -- vim.opt.wildmenu = true
  vim.opt.wildmenu = false
  -- vim.opt.wildmode = 'longest:full,full,'
  vim.opt.wildmode = ''
  vim.opt.directory = global.cache_path .. "/swag/"
  vim.opt.undodir = global.cache_path .. "/undo/"
  vim.opt.backupdir = global.cache_path .. "/backup/"
  vim.opt.viewdir = global.cache_path .. "/view/"
  vim.opt.history = 2000
  vim.opt.shada = "!,'300,<50,@100,s10,h"
  vim.opt.backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim"
  vim.opt.smarttab = true
  vim.opt.shiftround = true
  vim.opt.updatetime = 100
  vim.opt.redrawtime = 1500
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.smartindent = true
  vim.opt.infercase = true
  vim.opt.incsearch = true
  vim.opt.wrapscan = true
  vim.opt.complete = ".,w,b,k"
  vim.opt.inccommand = "nosplit"
  vim.opt.grepformat = "%f:%l:%c:%m"
  vim.opt.grepprg = "rg --hidden --vimgrep --smart-case --"
  vim.opt.breakat = [[\ \	;:,!?]]
  vim.opt.startofline = false
  vim.opt.whichwrap = "h,l,<,>,[,],~"
  vim.opt.splitbelow = true
  vim.opt.splitright = true
  vim.opt.switchbuf = "useopen"
  vim.opt.backspace = "indent,eol,start"
  vim.opt.diffopt = "filler,iwhite,internal,algorithm:patience"
  vim.opt.completeopt = "menu,menuone,noselect"
  vim.opt.jumpoptions = "stack"
  vim.opt.showmode = false
  vim.opt.scrolloff = 2
  vim.opt.sidescrolloff = 8
  vim.opt.foldlevelstart = 99
  vim.opt.ruler = false
  vim.opt.list = true
  vim.opt.showtabline = 2
  vim.opt.winwidth = 30
  vim.opt.winminwidth = 5
  vim.opt.pumheight = 15
  vim.opt.helpheight = 12
  vim.opt.previewheight = 12
  vim.opt.showcmd = false
  vim.opt.cmdheight = 0
  vim.opt.cmdwinheight = 5
  vim.opt.equalalways = false
  vim.opt.laststatus = 3
  vim.opt.display = "lastline"
  vim.opt.showbreak = "↳  "
  vim.opt.listchars = "tab:  ,nbsp: ,trail: ,space: ,extends:→,precedes:←"
  vim.opt.fillchars = "eob: ,fold:─"
  vim.opt.pumblend = 0
  vim.opt.winblend = 0
  vim.opt.undofile = true
  vim.opt.synmaxcol = 2500
  vim.opt.timeoutlen = 300
  vim.opt.formatoptions = "1jcroql"
  vim.opt.textwidth = 120
  vim.opt.expandtab = true
  vim.opt.autoindent = true
  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4
  vim.opt.softtabstop = -1
  vim.opt.breakindentopt = "shift:2,min:20"
  vim.opt.wrap = false
  vim.opt.linebreak = true
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.foldenable = true
  vim.opt.foldlevel = 99
  vim.opt.si = true
  vim.opt.signcolumn = "yes"
  vim.opt.conceallevel = 0
  vim.opt.foldmethod = "indent"
  vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  vim.opt.foldtext = "v:lua.fold_text()"
  vim.opt.cursorline = true
  vim.o.foldcolumn = '1'



  -- netrw file explorer settings
  vim.g.netrw_winsize = 20
  vim.g.netrw_banner = 0
  vim.g.netrw_liststyle = 1

  -- Fix markdown indentation settings
  vim.g.markdown_recommended_style = 0

  vim.opt.path:append({ '**' })
  vim.opt.shortmess:append({ W = true, I = true, c = true })

  -- hides `~` at the end of the buffer
end
global.loaded.options = true

-- vim.cmd([[set fillchars+=eob:\ ]])

-- vim.cmd([[
--    setlocal spell spelllang=en "Set spellcheck language to en
--    setlocal spell! "Disable spell checks by default
--    filetype plugin indent on
--    if has('win32')
--       let g:python3_host_prog = $HOME . '/scoop/apps/python/current/python.exe'
--    endif
--   let &t_Cs = "\e[4:3m" "Undercurl
--   let &t_Ce = "\e[4:0m"
--   set whichwrap+=<,>,[,],h,l
--   set iskeyword+=-
-- ]])

return M

-- local g = vim.g
-- local opt = vim.opt
-- local o = vim.o
-- local wo = vim.wo

-- -- Leader key
-- opt.termguicolors = true

-- -- Globals
-- g.big_file = { size = 1024 * 5000, lines = 50000 }
-- g.bigfile_size = 1024 * 1024 * 1.5

-- -- Toggleable settings (with <space + l + u>)
-- local toggleable_settings = {
--   autoformat_enabled = false,
--   autopairs_enabled = false,
--   autosave_enabled = false,
--   cmp_enabled = true,
--   codeactions_enabled = false,
--   codelens_enabled = false,
--   diagnostics_mode = 3,
--   icons_enabled = true,
--   inlay_hints_enabled = false,
--   lsp_round_borders_enabled = true,
--   lsp_signature_enabled = true,
--   notifications_enabled = true,
--   semantic_tokens_enabled = true,
--   url_effect_enabled = true,
-- }

-- for key, value in pairs(toggleable_settings) do
--   g[key] = value
-- end

-- -- Other globals
-- g.diffprg = "bcompare"
-- g.Homedir = os.getenv("HOME")
-- g.Sessiondir = vim.fn.stdpath("data") .. "/sessions"
-- g.lazyvim_picker = "auto"
-- g.elite_mode = true
-- g.window_q_mapping = true
-- g.structure_status = false
-- g.root_spec = { "lsp", { ".git", "lua" }, "cwd", "src", ".config/nvim", "techdeus" }
-- g.lazygit_config = true
-- g.lazyvim_statuscolumn = { folds_open = false, folds_githl = false }
-- g.deprecation_warnings = false
-- g.window_pins = {}
-- g.calendar_google_calendar = 1
-- g.calendar_google_task = 1
-- g.calendar_debug = 1
-- g.calendar_cache_directory = "~/.cache/calendar.vim"
-- g.CtrlSpaceDefaultMappingKey = "<C-space> "

-- -- Create necessary directories
-- local dirs = { "backups", "undos", "swaps", "sessions" }
-- for _, dir in ipairs(dirs) do
--   vim.fn.mkdir(vim.fn.stdpath("data") .. "/" .. dir, "p", "0o700")
-- end

-- -- General settings
-- opt.backup = false
-- opt.mouse = vim.fn.isdirectory("/data") == 1 and "v" or "a"
-- opt.mousescroll = "ver:25,hor:6"
-- opt.switchbuf = "usetab"
-- opt.writebackup = false
-- opt.undofile = true
-- opt.shada = "'100,<50,s10,:1000,/100,@100,h"

-- vim.cmd("filetype plugin indent on")

-- -- Use rg for grep
-- vim.o.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
-- vim.opt.grepformat = vim.opt.grepformat ^ { "%f:%l:%c:%m" }

-- -- UI settings
-- local ui_settings = {
--   breakindent = true,
--   colorcolumn = "+1",
--   cursorline = true,
--   laststatus = 3,
--   linebreak = true,
--   list = true,
--   number = true,
--   pumblend = 0,
--   pumheight = 0,
--   ruler = false,
--   shortmess = "aoOWFcS",
--   showmode = false,
--   showtabline = 2,
--   signcolumn = "yes",
--   splitbelow = true,
--   splitright = true,
--   termguicolors = true,
--   winblend = 0,
--   wrap = false,
--   spell = false,
-- }

-- for key, value in pairs(ui_settings) do
--   opt[key] = value
-- end

-- -- Fill characters and list chars
-- opt.fillchars = {
--   eob = " ",
--   horiz = "═",
--   horizdown = "╦",
--   horizup = "╩",
--   vert = "║",
--   verthoriz = "╬",
--   vertleft = "╣",
--   vertright = "╠",
--   fold = "•",
--   foldsep = " ",
--   diff = "╱",
-- }

-- opt.listchars = {
--   tab = "  ",
--   extends = "⟫",
--   precedes = "⟪",
--   conceal = "-",
--   nbsp = "␣",
--   trail = "·",
-- }

-- -- Fold settings
-- local fold_settings = {
--   foldcolumn = "0",
--   foldmethod = "expr",
--   foldexpr = "v:lua.vim.treesitter.foldexpr()",
--   foldtext = "",
--   foldnestmax = 4,
--   foldlevel = 99,
--   foldlevelstart = 99,
--   foldenable = true,
-- }

-- for key, value in pairs(fold_settings) do
--   opt[key] = value
-- end

-- -- Additional settings
-- opt.conceallevel = 0
-- opt.clipboard = "unnamedplus"
-- opt.completeopt = { "menu", "menuone", "noselect" }
-- opt.expandtab = true
-- opt.shiftwidth = 2
-- opt.tabstop = 2
-- opt.ignorecase = true
-- opt.smartcase = true
-- opt.updatetime = 300
-- opt.timeoutlen = 300
-- opt.virtualedit = "block"
-- opt.scrolloff = 0
-- opt.sidescrolloff = 0
-- opt.spelllang = { "en" }
-- opt.spelloptions:append("camel")
-- opt.spelloptions:append("noplainbuffer")
-- -- Diff options
-- opt.diffopt:append({ "algorithm:histogram", "linematch:60", "indent-heuristic", "algorithm:patience" })
-- -- Session options
-- opt.sessionoptions:remove({ "blank", "buffers", "terminal" })
-- opt.sessionoptions:append({ 'curdir', 'folds', 'globals', 'help', 'tabpages', 'terminal', 'winsize' })

-- -- Window options
-- o.winwidth = 10
-- o.winminwidth = 10
-- o.equalalways = false
-- wo.numberwidth = 8

-- -- File type additions
-- vim.filetype.add({
--   filename = {
--     Brewfile = "ruby",
--     justfile = "just",
--     Justfile = "just",
--     [".buckconfig"] = "toml",
--     [".flowconfig"] = "ini",
--     [".jsbeautifyrc"] = "json",
--     [".jscsrc"] = "json",
--     [".watchmanconfig"] = "json",
--     ["helmfile.yaml"] = "yaml",
--     ["todo.txt"] = "todotxt",
--     ["yarn.lock"] = "yaml",
--   },
--   pattern = {
--     ["%.config/git/users/.*"] = "gitconfig",
--     ["%.kube/config"] = "yaml",
--     [".*%.js%.map"] = "json",
--     [".*%.postman_collection"] = "json",
--     ["Jenkinsfile.*"] = "groovy",
--   },
-- })
