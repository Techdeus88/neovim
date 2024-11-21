local config = {}
--===============================--
--------Mini Setup Modules-----------
--===============================--
config.mini_ai = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.ai",
    name = "mini.ai",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      local gen_spec = require('mini.ai').gen_spec
      return {
        mappings = {
          -- Main textobject prefixes
          around = 'a',
          inside = 'i',

          -- Next/last variants
          around_next = 'an',
          inside_next = 'in',
          around_last = 'al',
          inside_last = 'il',

          -- Move cursor to corresponding edge of `a` textobject
          goto_left = 'g[',
          goto_right = 'g]',
        },

        -- How to search for object
        -- 'cover', 'cover_or_next', 'cover_or_prev','cover_or_nearest', 'next', 'previous', 'nearest'.
        search_method = 'cover_or_next',
        n_lines = 500,
        silent = false,
        custom_textobjects = {
          o = gen_spec.treesitter({
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }, {}),
          f = gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {}),
          c = gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {}),
          t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' },
        },
      }
    end,
    post_setup = function() end
  }
end

config.mini_animate = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.animate",
    name = "mini.animate",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      return { scroll = { enable = false } }
    end,
    post_setup = function() end
  }
end

config.mini_align = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.align",
    name = "mini.align",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      return {}
    end,
    post_setup = function() end
  }
end

config.mini_bracketed = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.bracketed",
    name = "mini.bracketed",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      return {
        comment = { suffix = "" },
        diagnostic = { suffix = "" },
				file = { suffix = "" },
        jump = { suffix = "" },
        location = { suffix = "" },
        oldfile = { suffix = "" },
				quickfix = { suffix = "" },
				treesitter = { suffix = "n" },
				window = { suffix = "" },
				yank = { suffix = "" },
      }
    end,
    post_setup = function() end
  }
end

config.mini_bufremove = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.bufremove",
    name = "mini.bufremove",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function() end,
    post_setup = function() end
  }
end

config.mini_colors = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.colors",
    name = "mini.colors",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function() return {} end,
    post_setup = function() end
  }
end

config.mini_diff = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.diff",
    name = "mini.diff",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function() end,
    post_setup = function() end
  }
end

config.mini_doc = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.doc",
    name = "mini.doc",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function() end,
    post_setup = function() end
  }
end

config.mini_extra = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.extra",
    name = "mini.extra",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      -- MiniExtra.gen_highlighter.words
      return {}
    end,
    post_setup = function() end
  }
end

config.mini_fuzzy = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.fuzzy",
    name = "mini.fuzzy",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      if vim.fn.has("nvim-0.11") == 1 then
        vim.opt.completeopt:append("fuzzy") -- Use fuzzy matching for built-in completion
      end
    end,
    post_setup = function() end
  }
end

config.mini_hlpatterns = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    name = "mini.hipatterns",
    require = "mini.hipatterns",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      local hl_words = require("mini.hipatterns")
      return {
          highlighters = {
            fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
            error = { pattern = "%f[%w]()ERROR()%f[%W]", group = "MiniHipatternsError" },
            hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
            warn = { pattern = "%f[%w]()WARN()%f[%W]", group = "MiniHipatternsWarn" },
            todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
            note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
            ref = { pattern = "%f[%w]()REF()%f[%W]", group = "MiniHipatternsRef" },
            refs = { pattern = "%f[%w]()REFS()%f[%W]", group = "MiniHipatternsRef" },
            due = { pattern = "%f[%w]()@@()%f[%W]!", group = "MiniHipatternsDue" },
            hex_color = hl_words.gen_highlighter.hex_color(),
        },
      }
    end,
    post_setup = function() end
  }
end

config.mini_jump = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.jump",
    name = "mini.jump",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      return {
        mappings = {
          repeat_jump = ",",
        },

        delay = {
          highlight = 0,
        },
      }
    end,
    post_setup = function() end
  }
end

config.mini_jump_2d = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.jump2d",
    name = "mini.jump2d",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      local MiniJump2d = require("mini.jump2d")
      return {
        spotter = MiniJump2d.gen_pattern_spotter("[^%s%p]+"),
        view = { dim = true, n_steps_ahead = 2 },
      }
    end,
    post_setup = function() end
  }
end

config.mini_misc = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.misc",
    name = "mini.misc",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      local MiniMisc = require("mini.misc")
      MiniMisc.setup_auto_root()
      MiniMisc.setup_termbg_sync()
      return { make_global = { "put", "put_text", "stat_summary", "bench_time" } }
    end,
    post_setup = function() end
  }
end

config.mini_move = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.move",
    name = "mini.move",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      return {
        mappings = {
          -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
          left = "<M-S-h>",
          right = "<M-S-l>",
          down = "<M-S-j>",
          up = "<M-S-k>",

          -- Move current line in Normal mode
          line_left = "<M-S-h>",
          line_right = "<M-S-l>",
          line_down = "<M-S-j>",
          line_up = "<M-S-k>",
        },
        options = { reindent_linewise = false },
      }
    end,
    post_setup = function() end
  }
end

config.mini_operators = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.operators",
    name = "mini.operators",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function() end,
    post_setup = function() end
  }
end

config.mini_split_join = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.splitjoin",
    name = "mini.splitjoin",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function() end,
    post_setup = function() end
  }
end

config.mini_surround = function()
  return
  {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.surround",
    name = "mini.surround",
    load = 'now',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      return {
        custom_surroundings = nil,
        mappings = {
          add = 'gsa',
          delete = 'gsd',
          find = 'gsf',
          find_left = 'gsF',
          highlight = 'gsh',
          replace = 'gsr',
          update_n_lines = 'gsn',
          suffix_last = 'l', -- Suffix to search with "prev" method
          suffix_next = 'n', -- Suffix to search with "next" method
        },
        search_method = 'cover_or_nearest',
        highlight_duration = 500,
        n_lines = 20,
        respect_selection_type = false,
        silent = false,
        -- How to search for surrounding
        -- 'cover', 'cover_or_next', 'cover_or_prev','cover_or_nearest', 'next', 'previous', 'nearest'.
      }
    end,
    post_setup = function() end
  }
end

config.mini_test = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.test",
    name = "mini.test",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function()
      local MiniTest = require("mini.test")
      local reporter = MiniTest.gen_reporter.buffer({ window = { border = "rounded" } })
      return {
        execute = { reporter = reporter },
      }
    end,
    post_setup = function()
    end
  }
end

config.mini_trailspace = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.trailspace",
    name = "mini.trailspace",
    load = 'later',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function() end,
    post_setup = function() end
  }
end

config.mini_visits = function()
  return {
    add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
    require = "mini.visits",
    name = "mini.visits",
    load = 'now',
    s_load = 'later',
    setup_type = "full-setup",
    setup_param = "setup",
    setup_opts = function() end,
    post_setup = function() end
  }
end

return config

--===============================---------------
----Using these Mini Modules in other places----
--===============================---------------
-- local MiniIcons = require("mini.icons")
-- local MiniIndentScope = require('mini.indentscope')
-- local MiniFiles = require('mini.files')
-- local MiniStarter = require("mini.starter")

--===============================--
----Not using these Mini Modules----
--===============================--
-- local MiniBasics = require("mini.nbasics")
-- local MiniClue = require("mini.clue")
-- local MiniNotify = require("mini.notify")
-- local MiniPairs = require("mini.pairs")
-- local MiniSurround = require("mini.surround")
-- local MiniCursorWord = require("mini.cursorword")
-- local MiniCompletion = require("mini.completion")

-- config["Miniclue = function()
-- Miniclue.setup({
--   clues = {
--     { mode = 'n', keys = '<Leader>b', desc = '+Buffers' },
--     Miniclue.gen_clues.builtin_completion(),
--     Miniclue.gen_clues.g(),
--     { mode = 'n', keys = '<Leader>l', desc = '+LSP' },
--     Miniclue.gen_clues.marks(),
--     Miniclue.gen_clues.registers(),
--     { mode = 'n', keys = '<Leader>t', desc = '+Toggles' },
--     { mode = 'n', keys = '<Leader>u', desc = '+More Toggles' },
--     Miniclue.gen_clues.windows({ submode_resize = true }),
--     Miniclue.gen_clues.z(),
--   },
--   triggers = {
--     { mode = 'n', keys = '<Leader>' }, -- Leader triggers
--     { mode = 'x', keys = '<Leader>' },
--     { mode = 'n', keys = [[\]] },      -- mini.basics
--     { mode = 'n', keys = '[' },        -- mini.bracketed
--     { mode = 'n', keys = ']' },
--     { mode = 'x', keys = '[' },
--     { mode = 'x', keys = ']' },
--     { mode = 'i', keys = '<C-x>' }, -- Built-in completion
--     { mode = 'n', keys = 'g' },     -- `g` key
--     { mode = 'x', keys = 'g' },
--     { mode = 'n', keys = "'" },     -- Marks
--     { mode = 'n', keys = '`' },
--     { mode = 'x', keys = "'" },
--     { mode = 'x', keys = '`' },
--     { mode = 'n', keys = '"' }, -- Registers
--     { mode = 'x', keys = '"' },
--     { mode = 'i', keys = '<C-r>' },
--     { mode = 'c', keys = '<C-r>' },
--     { mode = 'n', keys = '<C-w>' }, -- Window commands
--     { mode = 'n', keys = 'z' },     -- `z` key
--     { mode = 'x', keys = 'z' },
--   },
--   window = {
--     config = { width = 'auto', border = 'rounded' },
--     delay = 500,
--     scroll_down = '<C-d>',
--     scroll_up = '<C-u>'
--   }
-- })
-- end

-- config.mini_basics = function()
--   return {
--     add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
--     require = "mini.basics",
--     name = "mini.basics",
--     load = 'later',
--     s_load = 'later',
--     setup_type = "full-setup",
--     setup_param = "setup",
--     setup_opts = function()
--       return {
--         -- options = {
--         --   basic = false,
--         -- },
--         -- mappings = {
--         --   windows = true,
--         --   move_with_alt = true,
--         -- },
--         -- autocommands = {
--         --   relnum_in_visual_mode = true,
--         -- },
--       }
--     end,
--     post_setup = function() end
--   }
-- end

-- config.mini_completion = function()
--   return {
--     add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
--     require = "mini.completion",
--     name = "mini.completion",
--     load = 'later',
--     s_load = 'later',
--     setup_type = "full-setup",
--     setup_param = "setup",
--     setup_opts = function()
--       return {
--         lsp_completion = {
--           source_func = "omnifunc",
--           auto_setup = false,
--           process_items = function(items, base)
--             items = vim.tbl_filter(function(x) return x.kind ~= 1 and x.kind ~= 15 end, items)
--             return require('mini.completion').default_process_items(items, base)
--           end,
--         },
--         window = {
--           info = { border = "rounded" },
--           signature = { border = "rounded" },
--         },
--       }
--     end,
--     post_setup = function() end
--   }
-- end

-- config.mini_cursorword = function()
--   return {
--     add = { source = nil, depends = {}, post_install = nil, post_checkout = nil },
--     require = "mini.cursorword",
--     name = "mini.cursorword",
--     load = 'later',
--     s_load = 'later',
--     setup_type = "full-setup",
--     setup_param = "setup",
--     setup_opts = function() return {} end,
--     post_setup = function() end
--   }
-- end
