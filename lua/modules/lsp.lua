return { -- LSP modules ~7~
  {      -- Nvim treesitter: special parsers to manage code by ft and lang
    "nvim-treesitter/nvim-treesitter",
    cmd = { 'BufReadPre', 'BufNewFile' },
    hooks = {
      post_checkout = function()
        vim.cmd "TSUpdate"
      end,
    },
    require = "nvim-treesitter.configs",
    config = function()
      local ok, nvim_treesitter = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.notify("NVIM treesitter is not found", vim.log.levels.ERROR, {})
        return
      end
      -- Add this to your config function
      vim.api.nvim_create_user_command("TSInstallWithTimeout", function()
        local timeout = 10000 -- 10 seconds
        local start_time = vim.loop.now()

        vim.cmd "TSInstall all"

        -- Check installation status
        vim.defer_fn(function()
          if vim.loop.now() - start_time > timeout then
            vim.notify("Treesitter parser installation timed out", vim.log.levels.WARN)
          end
        end, timeout)
      end, {})

      nvim_treesitter.setup {
        ensure_installed = "all",
        auto_install = false,
        ignore_install = { "hoon", "systemverilog" },
        sync_install = false, -- Set to false to prevent blocking
        playground = {
          enable = true,
          disable = {},
          updatetime = 25,
          persist_queries = false,
          keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<CR>",
            show_help = "?",
          },
        },
        highlight = { enable = true, additional_vim_regex_highlighting = { "org" } },
        indent = {
          enable = true,
          disable = {
            "dart",
          },
        },
        autopairs = {
          enable = true,
        },
        rainbow = {
          enable = true,
        },
        context_commentstring = {
          enable = true,
          config = {
            javascriptreact = {
              style_element = "{/*%s*/}",
            },
          },
        },
        matchup = {
          enable = true,
          disable_virtual_text = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<cr>",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      }
    end,
  },
  { -- nvim LSP Config: LSP Configuration
    "neovim/nvim-lspconfig",
    lazy = false,
    require = "lspconfig",
    depends = { "b0o/schemastore.nvim" },
    config = function()
      local lspconfig_ok, _ = pcall(require, "lspconfig")
      if not lspconfig_ok then
        vim.notify("LSPConfig not found", vim.log.levels.ERROR)
        return
      end
    end,
  },
  { -- Mason: LSP Package Manager
    "williamboman/mason.nvim",
    lazy = false,
    hooks = {
      post_checkout = function()
        vim.cmd "MasonUpdate"
      end,
    },
    require = "mason",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    config = function(_, opts)
      local mason_ok, mason = pcall(require, "mason")
      if not mason_ok then
        vim.notify("Mason not found", vim.log.levels.ERROR)
        return
      end
      mason.setup(opts)
      require("languages").init()
      require("languages.utils.setup_diagnostics").init_diagnostics()
      require "languages.lsp_commands"
    end,
  },
  { -- Trouble: A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    keys = {
      {
        "<leader>xx",
        "<cmd>TroubleToggle<cr>",
        desc = "Toggle Trouble",
        noremap = true,
        silent = true,
      },
      {
        "<leader>xd",
        "<cmd>TroubleToggle document_diagnostics<cr>",
        desc = "Document Diagnostics (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>TroubleToggle loclist<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xq",
        "<cmd>TroubleToggle quickfix<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
    config = function()
      local ok, trouble = pcall(require, "trouble")
      if not ok then
        return
      end

      local icons = require "base.ui.icons"
      trouble.setup {
        signs = {
          error = icons.diagnostics.error,
          warning = icons.diagnostics.warn,
          hint = icons.diagnostics.hint,
          information = icons.diagnostics.info,
          other = icons.diagnostics.other,
        },
      }
    end,
  },
  -- {
  --   'linrongbin16/lsp-progress.nvim',
  --   config = function()
  --     require('lsp-progress').setup()
  --     return require("lsp-progress").progress({
  --       format = function(messages)
  --           local active_clients = vim.lsp.get_active_clients()
  --           local client_count = #active_clients
  --           if #messages > 0 then
  --               return " LSP:"
  --                   .. client_count
  --                   .. " "
  --                   .. table.concat(messages, " ")
  --           end
  --           if #active_clients <= 0 then
  --               return " LSP:" .. client_count
  --           else
  --               local client_names = {}
  --               for i, client in ipairs(active_clients) do
  --                   if client and client.name ~= "" then
  --                       table.insert(client_names, "[" .. client.name .. "]")
  --                       print(
  --                           "client[" .. i .. "]:" .. vim.inspect(client.name)
  --                       )
  --                   end
  --               end
  --               return " LSP:"
  --                   .. client_count
  --                   .. " "
  --                   .. table.concat(client_names, " ")
  --           end
  --       end,
  --   })
  --   end

  -- },
  { -- Navic: a nav bar for lsp heads
    "SmiteshP/nvim-navic",
    lazy = false,
    depends = {  "neovim/nvim-lspconfig" },
    require = "nvim-navic",
    config = function()
      local nvim_navic_status_ok, nvim_navic = pcall(require, "nvim-navic")
      if not nvim_navic_status_ok then
        return
      end
      local icons = require "base.ui.icons"
      nvim_navic.setup {
        icons = icons.lsp,
        highlight = true,
        separator = " " .. icons.common.separator,
      }
    end,
  },
  { -- LSP: Conform formatting
    "stevearc/conform.nvim",
    event = "User BaseDefered",
    keys = {
      {
        "<leader>bf",
        function()
          local current_buf = vim.api.nvim_get_current_buf()
          local file_path = vim.api.nvim_buf_get_name(current_buf)
          local filename = file_path:match "^.+/(.+)$"
          require("conform").format()
          vim.notify(string.format("Buffer %s Formatted", filename), vim.log.levels.INFO)
        end,
        desc = "Format Buffer",
      },
    },
    config = function()
      local funcs = require "core.funcs"
      local conform = funcs.safe_require "conform"
      conform.setup {
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
          callback = funcs.debounce(100, conform.format()),
        },
      }
      local formatters = conform.formatters_by_ft
      formatters = formatters or {
        ["_"] = { "trim_whitespace" },
        ["*"] = { "codespell" },
      }
      _G.formatters = formatters
    end,
  },
  { -- LSP: NVIM-lint linting
    "mfussenegger/nvim-lint",
    event = "User BaseDefered",
    init = function()
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function(args)
          local current_buf = args.buf
          local file_path = vim.api.nvim_buf_get_name(current_buf)
          local filename = file_path:match "^.+/(.+)$"
          require("lint").try_lint()
          vim.notify(string.format("Buffer %s linted", filename), vim.log.levels.INFO, {})
        end,
      })
    end,
    keys = {
      {
        "<leader>bl",
        function()
          local current_buf = vim.api.nvim_get_current_buf()
          local file_path = vim.api.nvim_buf_get_name(current_buf)
          local filename = file_path:match "^.+/(.+)$"
          require("lint").try_lint()
          vim.notify(string.format("Buffer %s linted", filename), vim.log.levels.INFO, {})
        end,
        desc = "Lint Buffer",
      },
    },
    config = function()
      local funcs = require "core.funcs"
      local lint = funcs.safe_require "lint"
      local linters = lint.linters_by_ft
      linters = linters or {
        ["_"] = { "sh" },
        ["*"] = { "typos" },
      }
      _G.linters = linters
    end,
  },
}
