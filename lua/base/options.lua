--Start-of-file--
require("base.ui.fold")
-- ========================================================================== --
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --
-- Setup custom folding
function _G.CustomFoldText()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  local line_text = vim.fn.substitute(line, '\t', ' ', 'g')
  return string.format('%s (%d lines)', line_text, line_count)
end

local O = {}
function O.global()
  -- vim.g
  vim.g.gitblame_enabled = 0
  vim.g.gitblame_highlight_group = "CursorLine"
  vim.g.netrw_banner = 0
  vim.g.netrw_hide = 1
  vim.g.netrw_browse_split = 0
  vim.g.netrw_altv = 1
  vim.g.netrw_liststyle = 1
  vim.g.netrw_winsize = 20
  vim.g.netrw_keepdir = 1
  vim.g.netrw_list_hide = "(^|ss)\zs.S+"
  vim.g.netrw_localcopydircmd = "cp -r"                           -- Globals that are toggleable with <space + l + u>
  vim.g.autoformat_enabled = Global.settings.autoformat           -- Enable auto formatting at start.
  vim.g.autopairs_enabled = Global.settings.autopairs             -- Enable autopairs at start.
  vim.g.cmp_enabled = Global.settings.cmp                         -- Enable completion at start.
  vim.g.codeactions_enabled = Global.settings.codeactions         -- Enable displaying 💡 where code actions can be used.
  vim.g.codelens_enabled = Global.settings.codelens               -- Enable automatic codelens refreshing for lsp that support it.
  vim.g.diagnostics_mode = Global.settings.diagnostics_mode       -- Set code linting (0=off, 1=only show in status line, 2=virtual text off, 3=all on).
  vim.g.fallback_icons_enabled = Global.settings.fallback_icons   -- Enable it if you need to use Neovim in a machine without nerd fonts.
  vim.g.inlay_hints_enabled = Global.settings.inlay_hints         -- Enable always show function parameter names.
  vim.g.lsp_round_borders_enabled = Global.settings.round_borders -- Enable round borders for lsp hover and signatureHelp.
  vim.g.lsp_signature_enabled = Global.settings.signature         -- Enable automatically showing lsp help as you write function parameters.
  vim.g.notifications_enabled = Global.settings.notifications     -- Enable notifications.
  vim.g.semantic_tokens_enabled = Global.settings.semantic_tokens -- Enable lsp semantic tokens at start.
  vim.g.url_effect_enabled = Global.settings.url_effect           -- Highlight URLs with an underline effect.

  pcall(function()
    vim.opt.splitkeep = "screen"
  end)
  -- vim.opt
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
  vim.opt.directory = _G.Global.cache_path .. "/swag/"
  vim.opt.undodir = _G.Global.cache_path .. "/undo/"
  vim.opt.backupdir = _G.Global.cache_path .. "/backup/"
  vim.opt.viewdir = _G.Global.cache_path .. "/view/"
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
  vim.opt.hlsearch = true
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
  -- vim.opt.diffopt = "internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram"
  vim.opt.completeopt = "menu,menuone,noselect"
  vim.opt.jumpoptions = "stack"
  vim.opt.showmode = false
  vim.opt.scrolloff = 2
  vim.opt.sidescrolloff = 5
  vim.opt.foldlevelstart = 99
  vim.opt.ruler = false
  vim.opt.list = true

  vim.opt.winwidth = 30
  vim.opt.winminwidth = 10
  vim.opt.pumheight = 15
  vim.opt.helpheight = 12
  vim.opt.previewheight = 12
  vim.opt.showcmd = false
  vim.opt.cmdheight = 0
  vim.opt.cmdwinheight = 5
  vim.opt.equalalways = false
  vim.opt.laststatus = 0
  vim.showtabline = 0
  vim.opt.display = "lastline"
  vim.opt.showbreak = "↳  "
  vim.opt.listchars = "tab:  ,nbsp: ,trail: ,space: ,extends:→,precedes:←"
  vim.opt.pumblend = 0
  vim.opt.winblend = 0
  vim.opt.undofile = true
  vim.opt.undolevels = 10000
  vim.opt.synmaxcol = 2500
  vim.opt.formatoptions = "1jcroql"
  vim.opt.textwidth = 120
  vim.opt.expandtab = true
  vim.opt.autoindent = true
  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4
  vim.opt.softtabstop = -1
  vim.opt.breakindentopt = "shift:2,min:20"
  vim.opt.wrap = true
  vim.opt.linebreak = true
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.foldenable = true
  vim.opt.signcolumn = "no"
  vim.opt.conceallevel = 2
  -- vim.opt.foldcolumn = '1'
  -- vim.opt.foldlevel = 99      -- Start with all folds open
  -- vim.opt.foldlevelstart = 99 -- Open all folds when a file is opened
  -- vim.opt.foldnestmax = 4     -- Maximum nesting of folds
  vim.opt.foldenable = true -- Enable folding by default
  vim.opt.foldmethod = "indent"
  vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  vim.opt.foldtext = "v:lua.fold_text()"
  vim.opt.foldmethod = "indent"
  vim.opt.cursorline = true
  vim.opt.fillchars = {
    diff = "╱",
    eob = " ",
    fold = "─",
  }
  vim.opt.diffopt = "internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram"
  vim.opt.diffopt = {
    "internal",
    "filler",
    "closeoff",
    "context:6",
    "algorithm:histogram",
    "linematch:60",
    "indent-heuristic",
  }
  vim.opt.diffopt:append({ "vertical,context:100,linematch:100" })
  -- ignore case when searching
  -- Cursor line highlight
  -- Enable cursor blinking in all modes
  -- The numbers represent milliseconds:
  -- blinkwait175: Time before blinking starts
  -- blinkoff150: Time cursor is invisible
  -- blinkon175: Time cursor is visible
  -- vim.opt.guicursor = "n-v-c-sm:block-blinkwait175-blinkoff150-blinkon175"
  vim.opt.exrc = true   -- allow local .nvim.lua .vimrc .exrc files
  vim.opt.secure = true -- disable shell and write commands in local .nvim.lua .vimrc .exrc files

  if not vim.g.vscode then
    vim.opt.timeoutlen = 300 -- Lower than default (1000) to quickly trigger which-key
  end
  -- set titlestring to $cwd if TERM_PROGRAM=ghostty
  if vim.fn.getenv('TERM_PROGRAM') == 'ghostty' then
    vim.opt.title = true
    vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}"
  end
end

O.global()

return O
--End-of-file--
