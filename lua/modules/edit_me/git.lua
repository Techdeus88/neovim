local config = {}

config.vim_fugitive = function()
  ---@return DeusConfig
  return {
    add = {
      depends = {},
      source = "tpope/vim-fugitive",
      post_checkout = nil,
      post_install = nil,
    },
    require = nil,
    load = 'now',
    s_load = 'later',          -- now | later (default)
    setup_param = "setup",
    setup_type = "full-setup", -- invoke-setup | full-setup (default)
    setup_opts = function() end,
    post_setup = function() end,
  }
end
config.git_ignore = function()
  ---@return DeusConfig
  return {
    add = {
      depends = {},
      source = "wintermute-cell/gitignore.nvim",
      post_checkout = nil,
      post_install = nil,
    },
    require = nil,
    load = 'now',
    s_load = 'later',          -- now | later (default)
    setup_param = "setup",
    setup_type = "full-setup", -- invoke-setup | full-setup (default)
    setup_opts = function() end,
    post_setup = function() end,
  }
end
config.undotree = function()
  ---@return DeusConfig
  return {
    add = {
      depends = {},
      source = "mbbill/undotree",
      post_checkout = nil,
      post_install = nil,
    },
    require = nil,
    load = 'now',
    s_load = 'later',
    setup_param = "setup",
    setup_type = "full-setup", -- invoke-setup | full-setup (default)
    setup_opts = function() end,
    post_setup = function() end,
  }
end

config.diffview = function()
  ---@return DeusConfig
  return {
    add = { source = "sindrets/diffview.nvim", depends = {}, post_install = nil, post_checkout = nil },
    require = "diffview",
    load = 'now',
    s_load = 'later', -- now,later (default)
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      local icons = require("configs.base.ui.icons")
      local actions = require("diffview.actions")

      vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        group = vim.api.nvim_create_augroup("techdeus_diffview", {}),
        pattern = "diffview:///panels/*",
        callback = function()
          vim.opt_local.cursorline = true
          vim.opt_local.winhighlight = "CursorLine:WildMenu"
        end,
      })

      return {
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
        keymaps = {
          view = {
            { "n", "q",              actions.close },
            { "n", "<Tab>",          actions.select_next_entry },
            { "n", "<S-Tab>",        actions.select_prev_entry },
            { "n", "<LocalLeader>a", actions.focus_files },
            { "n", "<LocalLeader>e", actions.toggle_files },
          },
          file_panel = {
            { "n", "q",              actions.close },
            { "n", "h",              actions.prev_entry },
            { "n", "o",              actions.focus_entry },
            { "n", "gf",             actions.goto_file },
            { "n", "sg",             actions.goto_file_split },
            { "n", "st",             actions.goto_file_tab },
            { "n", "<C-r>",          actions.refresh_files },
            { "n", "<LocalLeader>e", actions.toggle_files },
          },
          file_history_panel = {
            { "n", "q", "<cmd>DiffviewClose<CR>" },
            { "n", "o", actions.focus_entry },
            { "n", "O", actions.options },
          },
        },
        hooks = {
          diff_buf_read = function(bufnr)
            vim.schedule(function()
              vim.api.nvim_buf_call(bufnr, function()
                vim.opt_local.wrap = false
                vim.opt_local.list = false
                vim.opt_local.relativenumber = false
                vim.opt_local.cursorcolumn = false
                vim.opt_local.colorcolumn = "0"
                require("indent_blankline.commands").disable()
              end)
            end)
          end,
        },
      }
    end,
    post_setup = function()
    end,
  }
end

config.neogit = function()
  ---@return DeusConfig
  return {
    add = { source = "NeogitOrg/neogit", depends = {}, post_install = nil, post_checkout = nil },
    require = "neogit",
    load = 'now',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      return {
        disable_signs = false,
        disable_context_highlighting = false,
        disable_commit_confirmation = false,
        integrations = { diffview = true },
      }
    end,
    post_setup = function() end,
  }
end

config.git_signs = function()
  ---@return DeusConfig
  return {
    add = { source = "lewis6991/gitsigns.nvim", depends = {}, post_install = nil, post_checkout = nil },
    require = "gitsigns",
    load = 'now',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      return {
        current_line_blame_formatter = "➤ <author> ➤ <author_time:%Y-%m-%d> ➤ <summary>",
        current_line_blame_formatter_nc = "➤ Not Committed Yet",
        current_line_blame_opts = { delay = 10 },
        numhl = false,
        signcolumn = true,
        signs_staged_enable = false,
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        signs_staged = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
        },
        linehl = false,
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns
          local function create_gitsigns_command(name, func)
            vim.api.nvim_create_user_command(name, "lua require('gitsigns')." .. func, {})
          end

          local gitsigns_commands = {
            { "GitSignsPreviewHunk",     "preview_hunk()" },
            { "GitSignsNextHunk",        "next_hunk()" },
            { "GitSignsPrevHunk",        "prev_hunk()" },
            { "GitSignsStageHunk",       "stage_hunk()" },
            { "GitSignsUndoStageHunk",   "undo_stage_hunk()" },
            { "GitSignsResetHunk",       "reset_hunk()" },
            { "GitSignsResetBuffer",     "reset_buffer()" },
            { "GitSignsBlameLine",       "blame_line()" },
            { "GitSignsBlameFull",       "blame_line(full=true)" },
            { "GitSignsToggleLinehl",    "toggle_linehl()" },
            { "GitSignsToggleLineBlame", "toggle_current_line_blame()" },
          }

          for _, cmd in ipairs(gitsigns_commands) do
            create_gitsigns_command(cmd[1], cmd[2])
          end

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end

          map("n", "]h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gs.nav_hunk("next")
            end
          end, "Next Hunk")
          map("n", "[h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gs.nav_hunk("prev")
            end
          end, "Prev Hunk")
          map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
          map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
          map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
          map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
          map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
          map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
          map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
          map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
          map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
          map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
          map("n", "<leader>ghd", gs.diffthis, "Diff This")
          map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        end
      }
    end,
    post_setup = function()
    end,
  }
end

config.octo = function()
  ---@return DeusConfig
  return {
    add = {
      depends = {},
      source = "pwntester/octo.nvim",
      post_checkout = nil,
      post_install = nil,
    },
    require = "octo",
    load = 'now',
    s_load = 'later',
    setup_param = "setup",     -- setup (default),set,init
    setup_type = "full-setup", -- invoke-setup,full-setup (default)
    setup_opts = function()
      return {
        suppress_missing_scope = {
          projects_v2 = true,
        }
      }
    end,
    post_setup = function() end,
  }
end

return config
