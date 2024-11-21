local config = {}

config.auto_tag = function()
  return {
    add = {
      source = "windwp/nvim-ts-autotag", depends = {}, post_install = nil, post_checkout = nil
    },
    require = "nvim-ts-autotag",
    load = 'now',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function() end,
    post_setup = function()
    end,
  }
end

config.auto_pairs = function()
  return {
    add = {
      source = 'windwp/nvim-autopairs',
      depends = {},
      post_install = nil,
      post_checkout = nil
    },
    require = 'nvim-autopairs',
    setup_type = "invoke-setup",
    setup_param = "setup",
    load = 'now',
    s_load = 'later',
    setup_opts = function()
      local autopairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local ts_conds = require("nvim-autopairs.ts-conds")

      autopairs.setup({
        disable_filetype = { "TelescopePrompt", "spectre_panel", "vim" },
        close_triple_quotes = true,
        check_ts = true,
        ts_config = {
          lua = { 'string', 'source' },
          javascript = { 'string', 'template_string' },
          typescript = { 'string', 'template_string' },
          python = { 'string', 'f_string' },
          java = false,
        },
        fast_wrap = {
          map = '<M-s>',
          chars = { '{', '[', '(', '"', "'" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
          offset = 0,
          end_key = '$',
          keys = 'qwertyuiopzxcvbnmasdfghjkl',
          check_comma = true,
          highlight = 'PmenuSel',
          highlight_grey = 'LineNr',
        },
      })
      autopairs.add_rules({
        Rule("{{", "  }", "vue"):set_end_pair_length(2):with_pair(ts_conds.is_ts_node("text")),
      })
    end,
    post_setup = function()
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
    end,
  }
end

config.vim_matchup = function()
  return {
    add = {
      source = "andymass/vim-matchup", -- Required
      depends = {},
      post_checkout = nil,
      post_install = nil,
    },
    require = nil,             -- Optional
    load = 'now',
    s_load = 'later',          -- *1=now,now | 2=now-later | 3=later-later
    setup_param = "setup",     -- *setup,init,set,<custom>
    setup_type = "invoke-setup", -- invoke-setup | *full-setup
    setup_opts = function() 
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
    post_setup = function() end,
  }
end

config.tabout = function()
  return {
    add = {
      source = "abecodes/tabout.nvim",
      depends = {},
      post_install = nil,
      post_checkout = nil,
    },
    require = "tabout",
    load = 'now',
    s_load = 'later',
    setup_type = "invoke-setup",
    setup_param = "setup",
    setup_opts = function()
      require('tabout').setup({
        tabkey = '<tab>',
        backwards_tabkey = '<s-tab>',
        act_as_tab = true,
        act_as_shift_tab = true,
        default_tab = '<C-t>',
        default_shift_tab = '<C-d>',
        enable_backwards = false,
        completion = true,
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = '`', close = '`' },
          { open = '(', close = ')' },
          { open = '[', close = ']' },
          { open = '{', close = '}' },
        },
        ignore_beginning = true,
        exclude = { 'markdown' }
      })
    end,
    post_setup = function()
    end,
  }
end

config.treesitter = function()
  return {
    add = {
      source = "nvim-treesitter/nvim-treesitter",
      depends = {},
      post_install = nil,
      post_checkout = function() vim.cmd('TSUpdate') end,
    },
    require = "nvim-treesitter.configs",
    load = 'now',
    s_load = 'later',
    setup_type = "invoke-setup",
    setup_param = "setup",
    setup_opts = function()
      local ts_parsers = require("languages.base.languages.ts_parsers")
      local treesitter = require("nvim-treesitter.configs")

      treesitter.setup {
        ensure_installed = ts_parsers,
        silent = true,
        highlight = {
          enable = true,
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
         end,
        },
        indent = {
          enable = true,
        },
        folding = {
          enable = true,
        },
      }
    end,
    post_setup = function()
      vim.defer_fn(function()
        vim.cmd('TSUpdate')
      end, 1000)
    end,
  }
end

config.nvim_treepairs = function()
  ----TreePairs----
  return {
    add = {
      source = "yorickpeterse/nvim-tree-pairs",
      depends = {},
      post_install = nil,
      post_checkout = nil,
    },
    require = "tree-pairs",
    load = 'now',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      return {
        enable = true,
        disable = { "mini.files", "oil" }
      }
    end,
    post_setup = function()
    end,
  }
end

return config

-- config.treesitter = function()
--   return {
--     enabled = true,
--     add = {
--       source = "nvim-treesitter/nvim-treesitter",
--       depends = {
--         'nvim-treesitter/nvim-treesitter-refactor',
--         'nvim-treesitter/nvim-treesitter-textobjects',
--         'RRethy/nvim-treesitter-endwise',
--         'RRethy/nvim-treesitter-textsubjects',
--         "windwp/nvim-ts-autotag",
--         "andymass/vim-matchup",
--       },
--          -- Ensure treesitter is properly installed and updated
--          post_install = function() vim.cmd('TSUpdate') end,
--          post_checkout = function() vim.cmd('TSUpdate') end,
--     },
--     require = "nvim-treesitter.configs",
--     load = 'now',
--     s_load = 'later',
--     setup_type = "invoke-setup",
--     setup_param = "setup",
--     setup_opts = function()
--       -- Basic setup without dependencies first
--       local ok_treesitter_configs, treesitter = require('nvim-treesitter.configs')
--       if not ok_treesitter_configs then return end
--       -- Default configuration that doesn't depenpad on optional modules
--       local conf = {
--         ensure_installed = { "lua", "vim", "query" },  -- Essential parsers
--         sync_install = false,
--         auto_install = true,
--         highlight = {
--           enable = true,
--           additional_vim_regex_highlighting = false,
--         },
--         indent = { enable = true },
--         autopairs = { enable = true },
--         endwise = { enable = true },
--         autotag = { enable = true },
--         matchup = { enable = true },
--       }

--       -- Try to load optional configurations
--       local ok_textobjects, textobjects = pcall(require, 'configs.base.languages.text_objects')
--       if ok_textobjects then
--         conf.textobjects = textobjects
--       end

--       local ok_parsers, installed_parsers = pcall(require, 'configs.base.languages.ts_parsers')
--       if ok_parsers then
--         conf.ensure_installed = installed_parsers
--       end

--        -- Add incremental selection if treesitter core is available
--        local ok_core = pcall(require, 'nvim-treesitter')
--        if ok_core then
--          conf.incremental_selection = {
--            enable = true,
--            keymaps = {
--              init_selection = '<c-space>',
--              node_incremental = '<c-space>',
--              scope_incremental = false,
--              node_decremental = '<bs>',
--            },
--          }
--        end

--       -- Only add refactor configuration if the module is available
--       local ok_refactor = pcall(require, 'nvim-treesitter-refactor')
--       if ok_refactor then
--         conf.refactor = {
--           highlight_definitions = {
--             enable = true,
--             clear_on_cursor_move = true,
--           },
--           highlight_current_scope = { enable = true },
--           smart_rename = {
--             enable = true,
--             keymaps = {
--               smart_rename = '<leader>rr',
--             },
--           },
--           navigation = {
--             enable = true,
--             keymaps = {
--               goto_definition = '<leader>rd',
--               list_definitions = '<leader>rl',
--               list_definitions_toc = '<leader>rh',
--               goto_next_usage = '<leader>rj',
--               goto_previous_usage = '<leader>rk',
--             },
--           },
--         }
--       end
      
--       treesitter.setup(conf)
--     end,
--     post_setup = function()
--      -- Ensure parsers are installed
--       vim.defer_fn(function()
--         vim.cmd('TSUpdate')
--       end, 1000)

--       local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')
--       -- vim way: ; goes to the direction you were moving.
--       vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
--       vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)

--       -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
--       vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f)
--       vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F)
--       vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t)
--       vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T)

--       local ts_repeat_move_next = ts_repeat_move.repeat_last_move_next
--       local ts_repeat_move_prev = ts_repeat_move.repeat_last_move_previous
--       vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move_next)
--       vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move_prev)
--     end
--   }
-- end