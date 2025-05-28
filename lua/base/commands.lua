--Start-of-file--
local M = {}

-- Constants and Groups
local AUTOCMD = vim.api.nvim_create_autocmd
local USER_CMD = vim.api.nvim_create_user_command
local GROUPS = {
  RESTORE_CURSOR = vim.api.nvim_create_augroup("RestoreCursor", { clear = true }),
  IDE = vim.api.nvim_create_augroup("Techdeus IDE", { clear = true }),
  MINIFILES = vim.api.nvim_create_augroup("techdeus-mini-files", { clear = true }),
}

-- Utility Functions
local function is_git_repo(path)
  return vim.fn.executable "git" == 1
    and require("base.utils").run_cmd({ "git", "-C", vim.fn.fnamemodify(path, ":p:h"), "rev-parse" }, false)
end

local function should_trigger_file_events(args)
  local empty_buffer = vim.fn.resolve(vim.fn.expand "%") == ""
  local greeter = vim.api.nvim_get_option_value("filetype", { buf = args.buf }) == "snacks_dashboard"
  return not (empty_buffer or greeter)
end

-- Event Handlers
local function handle_file_events(args)
  if not should_trigger_file_events(args) then
    return
  end

  local utils = require "base.utils"
  Events:emit_event("User BaseFile", {}, true)

  if is_git_repo(vim.fn.resolve(vim.fn.expand "%")) then
    Events:emit_event("User BaseGitFile", {}, true)
  end
end

local function handle_vim_enter()
  if #vim.fn.argv() >= 1 then
    -- Immediate trigger for files passed as arguments
    Events:emit_event("User BaseDefered", {}, true)
    Events:emit_event("BufEnter", {}, true)
  else
    -- Delayed trigger for normal startup
    vim.defer_fn(function()
      vim.schedule(function()
        Events:emit_event("User BaseDefered", {})
      end)
    end, 70)
  end
end

local function handle_snacks_events(args)
  local event = args.match
  local schedule = vim.schedule

  if event == "SnacksDashboardOpened" then
    schedule(function()
      vim.opt.cmdheight = 1
      vim.opt.laststatus = 0
      vim.opt.showtabline = 0
    end)
  elseif event == "SnacksDashboardClosed" then
    schedule(function()
      vim.opt.cmdheight = 0
      vim.opt.laststatus = 3
      vim.opt.showtabline = 2
    end)
  end
end

-- File Type Handlers
local function setup_filetype_handlers()
  local filetype_configs = {
    {
      pattern = { "grug-far", "help", "man", "qf", "query", "techdeus*", "detour", "Detour", "Snacks*" },
      callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
      end,
    },
    {
      pattern = { "markdown" },
      callback = function()
        vim.opt_local.foldtext = "v:lua.md_fold_text()"
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.conceallevel = 2
        vim.opt_local.wrap = false
      end,
    },
    {
      pattern = { "text", "markdown", "org" },
      callback = function()
        vim.opt_local.listchars = "tab:  ,nbsp: ,trail: ,space: ,extends:→,precedes:←"
      end,
    },
    {
      pattern = { "c", "cpp", "dart", "haskell", "objc", "objcpp", "ruby", "markdown", "org" },
      callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
      end,
    },
    {
      pattern = {
        "NeogitStatus",
        "Outline",
        "calendar",
        "dapui_breakpoints",
        "dapui_scopes",
        "dapui_stacks",
        "dapui_watches",
        "git",
        "netrw",
        "org",
        "toggleterm",
      },
      callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorcolumn = false
        vim.opt_local.colorcolumn = "0"
      end,
    },
  }

  for _, config in ipairs(filetype_configs) do
    AUTOCMD("FileType", {
      pattern = config.pattern,
      callback = config.callback,
      group = GROUPS.IDE,
    })
  end
end

-- MiniFiles Integration
local function setup_minifiles()
  local function set_cwd()
    local path = (require("mini.files").get_fs_entry() or {}).path
    if not path then
      return vim.notify "Cursor is not on valid entry"
    end
    vim.fn.chdir(vim.fs.dirname(path))
  end

  local function yank_path()
    local path = (require("mini.files").get_fs_entry() or {}).path
    if not path then
      return vim.notify "Cursor is not on valid entry"
    end
    vim.fn.setreg(vim.v.register, path)
  end

  local function ui_open()
    vim.ui.open(require("mini.files").get_fs_entry().path)
  end

  -- MiniFiles Autocommands
  AUTOCMD("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
      local b = args.data.buf_id
      vim.keymap.set("n", "g~", set_cwd, { buffer = b, desc = "Set cwd" })
      vim.keymap.set("n", "gX", ui_open, { buffer = b, desc = "OS open" })
      vim.keymap.set("n", "gy", yank_path, { buffer = b, desc = "Yank path" })
    end,
  })

  AUTOCMD("User", {
    group = GROUPS.MINIFILES,
    pattern = "MiniFilesWindowOpen",
    callback = function(args)
      vim.api.nvim_win_set_config(args.data.win_id, { border = "rounded" })
    end,
  })

  -- Set up bookmarks
  AUTOCMD("User", {
    group = GROUPS.MINIFILES,
    pattern = "MiniFilesExplorerOpen",
    once = true,
    callback = function()
      local set_mark = function(id, path, desc)
        require("mini.files").set_bookmark(id, path, { desc = desc })
      end
      set_mark("c", vim.fn.stdpath "config", "Config")
      set_mark("w", vim.fn.getcwd, "Working directory")
      set_mark("~", "~", "Home directory")
    end,
  })
end

-- Initialize
function M.setup()
  -- ## EXTRA LOGIC -----------------------------------------------------------
  -- Core Events
  -- 1. Events to load plugins faster → 'BaseFile'/'BaseGitFile'/'BaseDefered':
  --  this is pretty much the same thing as the event 'BufEnter',
  --    but without increasing the startup time displayed in the greeter.
  AUTOCMD("VimEnter", {
    desc = "Nvim user event that triggers after startup",
    callback = handle_vim_enter,
  })

  AUTOCMD({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
    desc = "Nvim user events for file detection",
    callback = handle_file_events,
  })

  -- AUTOCMD("BufWinEnter", {
  --   group = GROUPS.IDE,
  --     pattern = '*', -- pattern = { '*.lua' },
  --   callback = function(event)
  --     local bufnr = event.buf
  --     local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  --     -- Early return if conditions aren't met
  --     if vim.fn.bufnr('$') <= 1 then return end
  --     if not vim.api.nvim_buf_is_valid(bufnr) then return end
  --     if not (ft and Global.valid_filetypes[ft]) then return end

  --     -- Handle window operations safely
  --     local status_ok = pcall(vim.cmd, 'vsplit')
  --     -- if status_ok then
  --       -- require('detour').DetourCurrentWindow()
  --     -- end
  --   end,
  -- })

  AUTOCMD("BufEnter", {
    callback = function()
      vim.opt.formatoptions:remove { "c", "r", "o" }
    end,
    desc = "Disable New Line Comment",
  })

  AUTOCMD("BufReadPre", {
    group = GROUPS.IDE,
    callback = function(args)
      -- Get last position mark
      local last_line = vim.fn.line [['"]]

      -- Get total lines in buffer
      local total_lines = vim.fn.line "$"

      -- Get current filetype
      local filetype = vim.bo[args.buf].filetype
      local excluded_filetypes = { "commit", "xxd", "gitrebase" }

      -- Check if filetype should be excluded
      local should_exclude = false
      for _, ft in ipairs(excluded_filetypes) do
        if filetype == ft then
          should_exclude = true
          break
        end
      end

      -- Restore cursor if conditions are met
      if last_line >= 1 and last_line <= total_lines and not should_exclude then
        vim.cmd [[normal! g`"]]
      end
    end,
  })

  -- Snacks Events
  AUTOCMD("User", {
    pattern = { "SnacksDashboard", "SnacksDashboardOpened", "SnacksDashboardClosed" },
    callback = handle_snacks_events,
  })

  AUTOCMD("TextYankPost", {
    group = GROUPS.IDE,
    callback = function()
      vim.highlight.on_yank()
    end,
    desc = "highlight on yank",
  })

  -- File Type Handlers
  setup_filetype_handlers()

  -- MiniFiles Integration
  setup_minifiles()

  -- User Commands
  USER_CMD("ReloadConfig", "source $MYVIMRC", {})
  USER_CMD("FormatDisable", function(args)
    if args.bang then
      vim.b.disable_autoformat = true
    else
      vim.g.disable_autoformat = true
    end
  end, { desc = "Disable autoformat-on-save", bang = true })
  USER_CMD("FormatEnable", function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
  end, { desc = "Re-enable autoformat-on-save" })
end

M.setup()

return M
--End-of-file--
