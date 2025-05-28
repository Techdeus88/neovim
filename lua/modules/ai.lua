--Start-of-file--
return { -- AI Modules ~5~
  { -- Avante: cursor type AI assistant to help with coding
    "yetone/avante.nvim",
    event = "User BaseDefered",
    require = "avante",
    monitor = "main",
    hooks = {
      post_install = function()
        vim.cmd "make"
      end,
    },
    keys = {
      { "<leader>a1", "<cmd>AvanteAsk<CR>", desc = "Avante Ask" },
      { "<leader>ac", "<cmd>AvanteChat<CR>", desc = "Avante Chat" },
      { "<leader>aq", "<cmd>AvanteEdit<CR>", desc = "Avante Edit" },
      { "<leader>ad", "<cmd>AvanteDiff<CR>", desc = "Avante Diff" },
      { "<leader>as", "<cmd>AvanteSubmit<CR>", desc = "Avante Submit" },
      { "<leader>ar", "<cmd>AvanteRefresh<CR>", desc = "Avante Refresh" },
      { "<leader>ab", "<cmd>AvanteApply<CR>", desc = "Avante Apply" },
      { "<leader>aj", "<cmd>AvanteJumpNext<CR>", desc = "Avante Jump Next" },
      { "<leader>ak", "<cmd>AvanteJumpPrev<CR>", desc = "Avante Jump Prev" },
      { "[[", "<cmd>AvanteJumpPrev<CR>", desc = "Avante Jump Prev" },
      { "]]", "<cmd>AvanteJumpNext<CR>", desc = "Avante Jump Next" },
      { "<leader>au", "<cmd>AvanteRefresh<CR>", desc = "Avante Refresh" },
      { "<leader>ae", "<cmd>AvanteEdit<CR>", desc = "Avante Edit" },
      { "<leader>at", "<cmd>AvanteToggle<CR>", desc = "Avante Toggle" },
      { "d0", "<cmd>AvanteDiffNone<CR>", desc = "Avante Diff None" },
      { "db", "<cmd>AvanteDiffBoth<CR>", desc = "Avante Diff Both" },
      { "<leader>ad", "<cmd>AvanteDiff<CR>", desc = "Avante Diff" },
      { "<leader>as", "<cmd>AvanteSubmit<CR>", desc = "Avante Submit" },
      { "<leader>ar", "<cmd>AvanteRefresh<CR>", desc = "Avante Refresh" },
      { "<leader>ab", "<cmd>AvanteApply<CR>", desc = "Avante Apply" },
      { "<leader>az", "<cmd>AvanteToggleDebug<CR>", desc = "Avante Toggle" },
      { "<leader>ay", "<cmd>AvanteToggleHint<CR>", desc = "Avante Toggle Hint" },
      { "dt", "<cmd>AvanteDiffTheirs<CR>", desc = "Avante Diff Theirs" },
    },
    init = function()
      require("avante_lib").load()
    end,
    opts = {
      provider = "claude", -- Recommend using Claude
      auto_suggestions_provider = "claude",
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-5-sonnet-20240620",
        temperature = 0,
        max_tokens = 4096,
      },
      dual_boost = {
        enabled = true,
      },
      behavior = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        enable_claude_text_editor_tool_mode = true,
      },
      selector = {
        provider = "fzf_lua",
        provider_opts = {},
      },
      providers = {
        avante_commands = {
          name = "avante_commands",
          module = "blink.compat.source",
          score_offset = 90, -- show at a higher priority than lsp
          opts = {},
        },
        avante_files = {
          name = "avante_files",
          module = "blink.compat.source",
          score_offset = 100, -- show at a higher priority than lsp
          opts = {},
        },
        avante_mentions = {
          name = "avante_mentions",
          module = "blink.compat.source",
          score_offset = 1000, -- show at a higher priority than lsp
          opts = {},
        },
      },
      mappings = {
        ask = "<leader>ai",
        edit = "<leader>aq",
        refresh = "<leader>au",
        --- @class AvanteConflictMappings
        diff = {
          ours = "do",
          theirs = "dt",
          none = "d0",
          both = "db",
          next = "]x",
          prev = "[x",
        },
        jump = {
          next = "]]",
          prev = "[[",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-CR>",
        },
        toggle = {
          debug = "<leader>az",
          hint = "<leader>ay",
        },
      },
      hints = {
        enabled = true,
      },
      windows = {
        ---@type "right" | "left" | "top" | "bottom"
        position = "right", -- the position of the sidebar
        wrap = true, -- similar to vim.o.wrap
        width = 40, -- default % based on available widtAvanteAsk' prompt in a floating window
        start_insert = true, -- Start insert mode when opening the ask window
        border = "rounded",
        ---@type "ours" | "theirs"
        focus_on_apply = "ours", -- which diff to focus after applying
      },
      highlights = {
        diff = {
          current = "DiffText",
          incoming = "DiffAdd",
        },
      },
      --- @class AvanteConflictUserConfig
      diff = {
        autojump = true,
        ---@type string | fun(): any
        list_opener = "copen",
        override_timeoutlen = 500,
      },
    },
    config = function(_, opts)
      local ok, avante = pcall(require, "avante")
      if not ok then
        return
      end
      avante.setup(opts)
    end,
  },
  { -- Code Companion:
    "olimorris/codecompanion.nvim",
    require = "codecompanion",
    event = "User BaseDefered",
    opts = {
      log_level = "DEBUG",
      strategies = {
        chat = {
          adapter = "anthropic",
          keymaps = {
            send = {
              modes = { n = "<C-s>", i = "<C-s>" },
            },
            close = {
              modes = { n = "<C-c>", i = "<C-c>" },
            },
            -- Add further custom keymaps here
          },
        },
        inline = {
          adapter = "anthropic",
          keymaps = {
            accept_change = {
              modes = { n = "ga" },
              description = "Accept the suggested change",
            },
            reject_change = {
              modes = { n = "gr" },
              description = "Reject the suggested change",
            },
          },
        },
      },
    },
    config = function(_, opts)
      local ok, code_companion = pcall(require, "codecompanion")
      if not ok then
        return
      end
      code_companion.setup(opts)
    end,
  },
  { -- Supermaven:
    "supermaven-inc/supermaven-nvim",
    require = "supermaven-nvim",
    event = "User BaseDefered",
    lazy = true,
    config = function()
      local ok, super_maven = pcall(require, "supermaven-nvim")
      if not ok then
        return
      end
      super_maven.setup {
        disable_keymaps = true,
        log_level = "error",
      }
      local completion_preview = require "supermaven-nvim.completion_preview"
      vim.keymap.set("i", "<c-a>", completion_preview.on_accept_suggestion, { noremap = true, silent = true })
      vim.keymap.set("i", "<c-j>", completion_preview.on_accept_suggestion_word, { noremap = true, silent = true })
    end,
  },
  { -- Backseat.nvim:
    "james1236/backseat.nvim",
    require = "backseat",
    cmd = { "Backseat", "BackseatAsk", "BackseatClear", "BackseatClearLine" },
    config = true,
  },
  { -- WTF: nvim use all mediums to search esoteric errors
    "piersolenski/wtf.nvim",
    event = "User BaseDefered",
    keys = {
      {
        "<leader>wA",
        mode = { "n", "x" },
        function()
          require("wtf").ai()
        end,
        desc = "Debug diagnostic with AI",
      },
      {
        mode = { "n" },
        "<leader>wS",
        function()
          require("wtf").search()
        end,
        desc = "Search diagnostic with Google",
      },
      {
        mode = { "n" },
        "<leader>wH",
        function()
          require("wtf").history()
        end,
        desc = "Populate the quickfix list with previous chat history",
      },
      {
        mode = { "n" },
        "<leader>wG",
        function()
          require("wtf").grep_history()
        end,
        desc = "Grep previous chat history with Telescope",
      },
    },
    config = function()
      local ok, wtf = pcall(require, "wtf")
      if not ok then
        return
      end
      wtf.setup()
    end,
  },
}
