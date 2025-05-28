local function build_blink(params)
  vim.notify("Building blink.cmp", vim.log.levels.INFO, { title = "Techdeus IDE" })
  local obj = vim
      .system({ "cargo", "build", "--release" }, {
        cwd = params.package.dir,
      })
      :wait()
  if obj.code == 0 then
    vim.notify("Building blink.cmp done", vim.log.levels.INFO)
  else
    vim.notify("Building blink.cmp failed", vim.log.levels.ERROR)
  end
end

return { -- Completion modules ~3~
  { -- Blink.cmp completion provider
    "saghen/blink.cmp",
    lazy = true,
    depends = {
      "saghen/blink.compat",
      'Kaiser-Yang/blink-cmp-avante',
    },
    hooks = {
      post_checkout = function(params)
        vim.schedule(function() build_blink(params) end)
      end,
    },
    opts = {
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = {
          function(cmp)
            return cmp.select_next()
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp)
            return cmp.select_prev()
          end,
          "snippet_backward",
          "fallback",
        },

        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },

        ["<C-f>"] = { "scroll_documentation_up", "fallback" },
        ["<C-b>"] = { "scroll_documentation_down", "fallback" },
      },
      fuzzy = {
        use_frecency = true,
        use_proximity = true,
        use_unsafe_no_lock = false,
        sorts = { "score", "sort_text" },
        prebuilt_binaries = {
          ignore_version_mismatch = true,
          force_version = "v1.0.0",
        },
      },
      sources = {
        default = { "avante", "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = {
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {
              -- options for blink-cmp-avante
            }
          },
          lsp = {
            min_keyword_length = function(ctx)
              return ctx.trigger.kind == "manual" and 0 or 2 -- trigger when invoking with shortcut
            end,
            score_offset = 0,
            fallbacks = { "buffer" },
          },
          path = {
            min_keyword_length = 0,
          },
          snippets = {
            min_keyword_length = 2,
          },
          buffer = {
            min_keyword_length = 5,
            max_items = 5,
          },
          -- dont show LuaLS require statements when lazydev has items
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
          },
        },
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          treesitter_highlighting = true,
          window = { border = "rounded" },
        },
        list = {
          selection = { preselect = false, auto_insert = true },
        },
        trigger = {
          show_on_insert_on_trigger_character = false,
          show_on_accept_on_trigger_character = false,
        },
        menu = {
          border = "rounded",
          draw = {
            columns = { { "label", "label_description", gap = 1 }, { "kind_icon" } },
          },
        },
      },
      -- experimental auto-brackets support
      -- completion = { accept = { auto_brackets = { enabled = true } } },

      -- experimental signature help support
      -- signature = { enabled = true }
    },
    opts_extend = {
      "sources.default",
      "sources.compat",
    },
    config = function(_, opts)
      local ok, blink = pcall(require, "blink.cmp")
      if not ok then return end

      -- setup compat sources and provider
      local enabled = opts.sources.default
      for _, source in ipairs(opts.sources.compat or {}) do
        opts.sources.providers[source] = vim.tbl_deep_extend(
          "force",
          { name = source, module = "blink.compat.source" },
          opts.sources.providers[source] or {}
        )
        if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
          table.insert(enabled, source)
        end
      end

      -- check if we need to override symbol kinds
      for _, provider in pairs(opts.sources.providers or {}) do
        ---@cast provider blink.cmp.SourceProviderConfig|{kind?:string}
        if provider.kind then
          require("blink.cmp.types").CompletionItemKind[provider.kind] = provider.kind
          ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
          local transform_items = provider.transform_items
          ---@param ctx blink.cmp.Context
          ---@param items blink.cmp.CompletionItem[]
          provider.transform_items = function(ctx, items)
            items = transform_items and transform_items(ctx, items) or items
            for _, item in ipairs(items) do
              item.kind = provider.kind or item.kind
            end
            return items
          end
        end
      end
      blink.setup(opts)
    end,
  },
  {
    'folke/lazydev.nvim',
    depends = { 'Bilal2453/luvit-meta' },
    ft = "lua",
    require = "lazydev",
    config = function()
      local ok, lazydev = pcall(require, "lazydev")
      if not ok then return true end
      lazydev.setup({
        -- Add any additional paths to the library
        library = {
          { path = "~/workspace/avante.nvim/lua",      words = { "avante" } },
          { path = "/usr/share/nvim/runtime/lua" },
          { path = "/usr/local/share/nvim/runtime/lua" },
          { path = "${3rd}/luv/library",               words = { "vim%.uv" } },
        },
      })
    end
  },
}
