--Start-of-file--
local windows = require("configs.windows")

windows.split_vertically()
windows.split_horizontally()
windows.close_window_or_buffer()
windows.maximize_windows_all()
windows.maximize_windows_as_popup()
windows.resize_window()

local popup_window = {
  cmd = function()
    local api = vim.api

    local buf = api.nvim_create_buf(false, true)

    local opts = {
      style = "minimal",
      relative = "editor",
      height = api.nvim_get_option("lines") - 2,
      width = api.nvim_get_option("columns") - 3,
      title = "Popup",
      row = 2,
      col = 3,
      border = "rounded",
      zindex = 20,
    }

    -- Create the floating window with the current buffer
    api.nvim_open_win(buf, true, opts)

    -- Set the buffer's modifiable option to true
    api.nvim_buf_set_option(buf, "modifiable", true)
  end,
  actions = function(cmd)
    vim.api.nvim_create_user_command("PopupWindow", cmd, {})
  end,
}
popup_window.actions(popup_window.cmd)

local open_in_popup_window = {
  cmd = function()
    popup_window.cmd()
    require("snacks.picker").extensions.smart_open.smart_open({
      cwd_only = true,
      filename_first = false,
    })
  end,
  actions = function(cmd)
    vim.api.nvim_create_user_command("OpenInPopupWindow", cmd, {})
  end,
}
open_in_popup_window.actions(open_in_popup_window.cmd)

return { -- Window modules ~7~
  {      -- No-Neck-Pain: buffer centering experience
    "shortcuts/no-neck-pain.nvim",
    require = "no-neck-pain",
    event = "User BaseDefered",
    keys = {
      {
        "<leader>nnp",
        function()
          require("no-neck-pain").toggle()
        end,
        desc = "No Neck pain",
      },
      {
        "<leader>tw",
        "<cmd>NoNeckPain<cr>",
        desc = "Toggle SLB Layout",
      },
      {
        "<leader>wi",
        "<cmd>NoNeckPainWidthUp<cr>",
        desc = "Increase NoNeckPain width",
      },
      {
        "<leader>wd",
        "<cmd>NoNeckPainWidthDown<cr>",
        desc = "Decrease NoNeckPain width",
      },
    },
    config = function()
      local no_neck_pain_ok, no_neck_pain = pcall(require, "no-neck-pain")
      if not no_neck_pain_ok then
        vim.notify("No-Neck-Pain not found", vim.log.levels.ERROR)
        return
      end
      local today = os.date("%m-%d-%Y")
      local lfilename = string.format("scratch-pad-note-%s.md", today)

      local calculate_width = function()
        local width = vim.api.nvim_win_get_width(0)
        local min_width = 57
        return math.min(width, min_width)
      end
      no_neck_pain.setup({
        width = calculate_width(),
        mappings = {
          enabled = false,
        },
        buffers = {
          wo = {
            fillchars = "eob: ",
          },
          left = {
            colors = {
              blend = -0.4,
            },
            scratchPad = {
              enabled = true,
              filename = lfilename,
              pathToFile = string.format(Global.home .. "/techdeus/work/notes/%s", lfilename),
            },
            bo = {
              filetype = { "md", "markdown" },
            },
          },
          right = {
            enabled = false,
          },
        },
      })
    end,
  },
  { -- Detour: open files in a floating window
    "carbon-steel/detour.nvim",
    event = "User BaseDefered",
    config = function()
      local detour_ok, detour = pcall(require, "detour")
      if not detour_ok then
        vim.notify("Detour not found", vim.log.levels.ERROR)
        return
      end
      detour.setup({
        winopts = {
          border = "rounded",
          relative = "editor",
          position = {
            row = 0.1,
            col = 0.1,
            width = 0.8,
            height = 0.8,
          },
        },
      })
    end,
    post = function()
      vim.keymap.set("n", "<leader><enter>", ":Detour<cr>")
      vim.keymap.set("n", "<leader>,", ":DetourCurrentWindow<cr>")
    end,
  },
  { -- Edgy: predefined window and window layouts
    "folke/edgy.nvim",
    event = "User BaseDefered",
    require = "edgy",
    keys = {
      {
        "<leader>e",
        function()
          require("edgy").toggle()
        end,
        desc = "Toggle Edgy",
      },
      {
        "<leader>e<enter>",
        function()
          require("edgy").toggle()
        end,
        desc = "Toggle Edgy",
      },
      {
        "<leader>e<space>",
        function()
          require("edgy").toggle()
        end,
        desc = "Toggle Edgy",
      },
    },
    opts = {
      options               = {
        left = {
          size = 35,
        },
      },
      animate               = {
        enabled = false,
      },
      exit_when_last        = false,
      close_when_all_hidden = false,
      wo                    = {
        winhighlight = "",
        winbar = false,
      },
      bottom                = {
        {
          ft = "nofile",
          size = { height = 3 },
        },
      },
      left                  = {
        {
          ft = "trouble",
          pinned = true,
          title = "Sidebar",
          filter = function(_buf, win)
            -- this is dumb but it works only on this stage kek
            vim.api.nvim_set_hl(0, "TroubleNormal", { bg = "none", ctermbg = "none" })
            vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = "none", ctermbg = "none" })
            return vim.w[win].trouble.mode == "symbols"
          end,
          open = "Trouble symbols position=left focus=false filter.buf=0",
          size = { height = 0.6 },
        },
        {
          ft = "trouble",
          pinned = true,
          title = "Troubles",
          filter = function(_buf, win)
            return vim.w[win].trouble.mode == "diagnostics"
          end,
          open = "Trouble diagnostics focus=false filter.severity=vim.diagnostic.severity.ERROR",
          size = { height = 0.4 },
        },
      },
      right                 = {
        {
          ft = "Aerial",
          pinned = true,
          title = "Aerial",
          filter = function() end,
          open = "Aerial",
          size = { height = 0.4 },
        },
        {
          ft = "trouble",
          pinned = true,
          title = "Quickfix",
          filter = function(_buf, win)
            return vim.w[win].trouble.mode == "quickfix"
          end,
          open = "Trouble quickfix focus=false",
          size = { height = 0.3 },
        },
        {
          ft = "trouble",
          pinned = true,
          title = "Location",
          filter = function(_buf, win)
            return vim.w[win].trouble.mode == "loclist"
          end,
          open = "Trouble loclist focus=false",
          size = { height = 0.3 },
        },
      }
    },
    config = function(_, opts)
      local edgy_ok, edgy = pcall(require, "edgy")
      if not edgy_ok then
        vim.notify("Edgy not found", vim.log.levels.ERROR)
        return
      end
      edgy.setup(opts)
    end,
    post = function()
      vim.opt.splitkeep = "screen"
      local edgy = require "edgy"
      vim.keymap.set("n", "<D-b>", function()
        edgy.toggle = "left"
      end, { desc = "Toggle Sidebar" })
    end
  },
  { -- Sticky: Stick Buffer to windows
    "stevearc/stickybuf.nvim",
    require = "stickybuf",
    event = "User BaseDefered",
    keys = {
      {
        "<Leader>wp",
        "<cmd>lua require('stickybuf').pin()<cr>",
        desc = "Pin window",
      },
      {
        "<Leader>wu",
        "<cmd>lua require('stickybuf').unpin()<cr>",
        desc = "Unpin window",
      },
      {
        "<Leader>wt",
        "<cmd>lua require('stickybuf').toggle()<cr>",
        desc = "Toggle pin",
      },
    },
    opts = {},
    config = function(_, opts)
      local stickybuf_ok, stickybuf = pcall(require, "stickybuf")
      if not stickybuf_ok then
        vim.notify("StickyBuf not found", vim.log.levels.ERROR)
        return
      end
      stickybuf.setup(opts)
    end,
  },
  { -- NeoTerm: Add a terminal with each buffer
    'nyngwang/NeoTerm.lua',
    event = "User BaseDefered",
    keys = {
      {
        "<M-Tab>",
        function()
          vim.cmd("NeoTermToggle")
        end,
        desc = "NEOTERM Toggle",
      },
      {
        "<M-Tab>",
        function()
          vim.cmd("NeoTermEnterNormal")
        end,
        desc = "NEOTERM Enter",
        mode = { "t" },
      },
    },
    config = function()
      local neoterm_ok, neoterm = pcall(require, "neo-term")
      if not neoterm_ok then
        vim.notify("NeoTerm not found", vim.log.levels.ERROR)
        return
      end
      neoterm.setup({ exclude_filetypes = { 'oil' } })
    end
  },
  { -- Neozoom: Add a unqiue view for each buffer
    'nyngwang/NeoZoom.lua',
    event = "User BaseDefered",
    keys = {
      {
        "<S-Tab>",
        function()
          vim.cmd("NeoZoomToggle")
        end,
        desc = "Toggle zoom",
        silent = true,
        nowait = true,
      },
    },
    config = function()
      local neozoom_ok, neozoom = pcall(require, "neo-zoom")
      if not neozoom_ok then
        vim.notify("NeoZoom not found", vim.log.levels.ERROR)
        return
      end
      neozoom.setup({
        popup = { enabled = true }, -- this is the default.
        -- NOTE: Add popup-effect (replace the window on-zoom with a `[No Name]`).
        -- EXPLAIN: This improves the performance, and you won't see two
        --          identical buffers got updated at the same time.
        -- popup = {
        --   enabled = true,
        --   exclude_filetypes = {},
        --   exclude_buftypes = {},
        -- },
        exclude_buftypes = { 'terminal' },
        -- exclude_filetypes = { 'lspinfo', 'mason', 'lazy', 'fzf', 'qf' },
        winopts = {
          offset = {
            -- NOTE: omit `top`/`left` to center the floating window vertically/horizontally.
            -- top = 0,
            -- left = 0.17,
            width = 150,
            height = 0.85,
          },
          -- NOTE: check :help nvim_open_win() for possible border values.
          border = 'thicc', -- this is a preset, try it :)
        },
        presets = {
          {
            -- NOTE: regex pattern can be used here!
            filetypes = { 'dapui_.*', 'dap-repl' },
            winopts = {
              offset = { top = 0.02, left = 0.26, width = 0.74, height = 0.25 },
            },
          },
          {
            filetypes = { 'markdown' },
            callbacks = {
              function() vim.wo.wrap = true end,
            },
          },
        },
      })
      vim.keymap.set('n', '<C-Tab>', function() vim.cmd('NeoZoomToggle') end, { silent = true, nowait = true })
    end
  },
  { -- Vim-Tmux navigation
    "christoomey/vim-tmux-navigator",
    event = "User BaseDefered",
    init = function()
      --stylua: ignore start
      vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Tmux Navigate Left" })
      vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Tmux Navigate Right" })
      vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Tmux Navigate Down" })
      vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Tmux Navigate Up" })
      vim.keymap.set("n", "<leader>wo", "<cmd>windows.maxmise_windows<cr>", { desc = "Maximize Windows" })
    end,
    require = "tmux-navigator",
    config = true,
  }
}
--End-of-file--
