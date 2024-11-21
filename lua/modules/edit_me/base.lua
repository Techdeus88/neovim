local config = {}

config.telescope = function()
    return {
        add = {
            source = "nvim-telescope/telescope.nvim",
            depends = {
                "nvim-telescope/telescope-file-browser.nvim",
                "camgraff/telescope-tmux.nvim",
            },
            post_install = nil,
            post_checkout = nil,
        },
        require = "telescope",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            local m_icons = require("mini.icons")
            local Telescope = require("telescope")
            Telescope.setup({
                defaults = {
                    prompt_prefix = " " .. m_icons.get("lsp", "search"),
                    selection_caret = "  ",
                    entry_prefix = "  ",
                    initial_mode = "insert",
                    selection_strategy = "reset",
                    sorting_strategy = "ascending",
                    layout_strategy = "bottom_pane",
                    layout_config = {
                        height = function() return math.ceil((vim.api.nvim_get_option("lines") + 5) * 0.40) end,
                    },
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--hidden",
                    },
                    file_sorter = require("telescope.sorters").get_fuzzy_file,
                    file_ignore_patterns = {
                        "node_modules",
                        ".git",
                        "target",
                        "vendor",
                    },
                    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
                    path_display = { shorten = 5 },
                    winblend = 0,
                    border = {},
                    borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
                    color_devicons = true,
                    set_env = { ["COLORTERM"] = "truecolor" },
                    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
                    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
                    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
                    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
                },
                pickers = {
                    file_browser = {
                        hidden = true,
                    },
                    find_files = {
                        hidden = true,
                    },
                    live_grep = {
                        hidden = true,
                        only_sort_text = true,
                    },
                },
                extensions = {
                    file_browser = {},
                },
            })
            Telescope.load_extension("file_browser")
            Telescope.load_extension("tmux")
        end,
        post_setup = function() end,
    }
end

config.ctrlspace = function()
    return {
        add = {
            depends = {},
            source = "vim-ctrlspace/vim-ctrlspace", -- Required
            post_checkout = nil,
            post_install = nil,
        },
        require = nil, -- Optional
        load = "now",
        s_load = "later", -- *0=now,now | 2=now-later | 3=later-later
        setup_param = "setup", -- *setup,init,set,<custom>
        setup_type = "full-setup", -- invoke-setup | *full-setup
        setup_opts = function() end,
        post_setup = function() end,
    }
end

config.vim_sleuth = function()
    return {
        add = {
            depends = {},
            source = "tpope/vim-sleuth", -- Required
            post_checkout = nil,
            post_install = nil,
        },
        require = nil, -- Optional
        load = "now",
        s_load = "later", -- *1=now,now | 2=now-later | 3=later-later
        setup_param = "setup", -- *setup,init,set,<custom>
        setup_type = "full-setup", -- invoke-setup | *full-setup
        setup_opts = function() end,
        post_setup = function() end,
    }
end

config.vim_wakatime = function()
    return {
        enabled = false,
        add = {
            depends = {},
            source = "wakatime/vim-wakatime", -- Required
            post_checkout = nil,
            post_install = nil,
        },
        require = nil, -- Optional
        load = "later",
        s_load = "later", -- *1=now,now | 2=now-later | 3=later-later
        setup_param = "setup", -- *setup,init,set,<custom>
        setup_type = "full-setup", -- invoke-setup | *full-setup
        setup_opts = function() end,
        post_setup = function() end,
    }
end

config.bookmarks = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "2kabhishek/markit.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "marks",
        load = "now",
        s_load = "later", -- now | later (default)
        setup_param = "setup",
        setup_type = "invoke-setup", -- invoke-setup | full-setup (default)
        setup_opts = function()
            local icons = require("configs.base.ui.icons")
            require("marks").setup({
                default_mappings = true,
                builtin_marks = { ".", "<", ">", "^" },
                cyclic = true,
                force_write_shada = false,
                sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
                excluded_filetypes = {},
                excluded_buftypes = { "nofile" },
                -- supports up to 10 bookmark groups
                bookmark_1 = {
                    sign = icons.ui.Flag,
                    virt_text = "flag",
                    annotate = false,
                },
                bookmark_2 = {
                    sign = icons.ui.Eye,
                    virt_text = "watch",
                    annotate = false,
                },
                bookmark_3 = {
                    sign = icons.ui.Star,
                    virt_text = "star",
                    annotate = false,
                },
                bookmark_4 = {
                    sign = icons.ui.Bug,
                    virt_text = "bug",
                    annotate = false,
                },
                mappings = {
                    set = "M",
                    toggle_mark = "m",
                },
            })
        end,
        post_setup = function() end,
    }
end

config.mini_picker = function()
    return {
        add = {
            source = nil,
            depends = {},
            post_checkout = nil,
            post_install = nil,
        },
        require = "mini.pick",
        name = "mini.pick",
        setup_type = "invoke-setup",
        setup_param = "setup",
        load = "now",
        s_load = "later",
        setup_opts = function()
            local W = require("configs.base.utils.windows")
            local MiniPick = require("mini.pick") --[Mini]: Picker

            local opts = {
                source = { show = MiniPick.default_show },
                mappings = {
                    toggle_info = "<C-k>",
                    toggle_preview = "<C-p>",
                    move_down = "<Tab>",
                    move_up = "<S-Tab>",
                    choose_in_vsplit = "<C-CR>",
                    refine = "<C-J>",
                    choose_marked = "<C-Q>",
                },
                options = {
                    use_cache = true,
                },
                window = {
                    config = W.win_config_picker_center(),
                },
            }
            MiniPick.setup(opts)

            W.add_color_scheme_picker()
            require("configs.base.utils.projects").add_project_picker()
        end,
        post_setup = function() end,
    }
end

config.multi_cursors = function()
    ---@return DeusConfig
    return {
        enabled = false,
        add = {
            depends = { "anuvyklack/hydra.nvim" },
            source = "smoka7/multicursors.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "multicursors",
        load = "now",
        s_load = "later", -- now | later (default)
        setup_param = "setup",
        setup_type = "invoke-setup", -- invoke-setup | full-setup (default)
        setup_opts = function()
            require("multicursors").setup({
                hint_config = {
                    float_opts = {
                        border = "rounded",
                    },
                    position = "bottom-right",
                },
                generate_hints = {
                    normal = true,
                    insert = true,
                    extend = true,
                    config = {
                        column_count = 1,
                    },
                },
            })
        end,
        post_setup = function() end,
    }
end

config.ccc = function()
    return {
        add = {
            source = "uga-rosa/ccc.nvim",
            depends = {},
            post_install = nil,
            post_checkout = nil,
        },
        require = "ccc",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function()
            return {
                highlighter = {
                    auto_enable = true,
                    lsp = true,
                },
            }
        end,
        post_setup = function() end,
    }
end

config.rainbow = function()
    return {
        add = { source = "HiPhish/rainbow-delimiters.nvim" },
        require = "rainbow-delimiters",
        setup_type = "invoke-setup",
        setup_param = "setup",
        load = "now",
        s_load = "later",
        setup_opts = function()
            local rainbow_delimiters = require("rainbow-delimiters")
            vim.g.rainbow_delimiters = {
                strategy = {
                    [""] = rainbow_delimiters.strategy["global"],
                    commonlisp = rainbow_delimiters.strategy["local"],
                },
                query = { [""] = "rainbow-delimiters", lua = "rainbow-blocks" },
                highlight = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                },
                blacklist = {},
            }
        end,
        post_setup = function() end,
    }
end

config.ibl = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "lukas-reineke/indent-blankline.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "ibl",
        load = "now",
        s_load = "later",
        setup_param = "setup",
        setup_type = "invoke-setup", -- invoke-setup | full-setup (default)
        setup_opts = function()
            local hooks = require("ibl.hooks")
            local highlight = {
                "RainbowRed",
                "RainbowYellow",
                "RainbowBlue",
                "RainbowOrange",
                "RainbowGreen",
                "RainbowViolet",
                "RainbowCyan",
            }
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
                vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
                vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
                vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
                vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
                vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
                vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
            end)
            vim.g.rainbow_delimiters = { highlight = highlight }
            require("ibl").setup({
                scope = { highlight = highlight },
                exclude = {
                    filetypes = {
                        "dashboard",
                        "toggleterm",
                        "alpha",
                        "checkhealth",
                        "dashboard",
                        "git",
                        "gitcommit",
                        "help",
                        "lazy",
                        "lazyterm",
                        "lspinfo",
                        "man",
                        "mason",
                        "neo-tree",
                        "notify",
                        "Outline",
                        "TelescopePrompt",
                        "TelescopeResults",
                        "terminal",
                        "toggleterms",
                        "Trouble",
                    },
                },
            })
            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
        end,
        post_setup = function() end,
    }
end

config.overseer = function()
    ---@return DeusConfig
    return {
        add = {
            depends = {},
            source = "stevearc/overseer.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "overseer",
        load = "now",
        s_load = "later", -- now | later (default)
        setup_param = "setup",
        setup_type = "full-setup", -- invoke-setup | full-setup (default)
        setup_opts = function() end,
        post_setup = function() end,
    }
end

config.grug = function()
    return {
        add = {
            source = "MagicDuck/grug-far.nvim",
            depends = {},
            post_checkout = nil,
            post_install = nil,
        },
        require = "grug-far",
        load = "now",
        s_load = "later",
        setup_param = "setup",
        setup_type = "full-setup",
        setup_opts = function()
            return {
                headerMaxWidth = 80,
            }
        end,
        post_setup = function() end,
    }
end

config.spider = function()
    return {
        add = { source = "chrisgrieser/nvim-spider", depends = {} },
        require = "spider",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function()
            return {
                skipInsignificantPunctuation = true,
            }
        end,
        post_setup = function()
            vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
            vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
            vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })
            vim.keymap.set(
                { "n", "o", "x" },
                "ge",
                "<cmd>lua require('spider').motion('ge')<CR>",
                { desc = "Spider-ge" }
            )
        end,
    }
end

config.multi_cursors_spec = function()
    return {
        add = {   source = "mg979/vim-visual-multi", depends = {}, post_checkout = nil, post_install = nil },
        require = nil,
        load = 'later',
        s_load = 'later',
        setup_type ="invoke-setup",
        setup_param = "setup",
        pre_setup = function()

    -- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
    -- vim.g.VM_leader = "\\"
    vim.g.VM_theme = "purplegray"

    vim.g.VM_maps = {
      -- TODO: fix mappings <C-q> already been used to check project
      -- permanent mappings
      ["Find Under"] = "<M-b>",
      ["Find Subword Under"] = "<M-b>", -- select some text firstly , then <M-b>

      -- ["Select Cursor Down"] = "<C-S-j>", -- switch upper and lower window with <C-w>jk
      -- ["Select Cursor Up"] = "<C-S-k>",
      ["Select Cursor Down"] = "<C-S-j>",

      -- ["Start Regex Search"] = "<C-q>/",
      ["Visual All"] = "\\A", --  1. selected some text in visual mode 2. press <C-q>j to select all

      -- buffer mappings
      ["Switch Mode"] = "v",
      ["Skip Region"] = "q",
      ["Remove Region"] = "Q",
      ["Goto Next"] = "}",
      ["Goto Prev"] = "{",

      -- ["Duplicate"] = "<C-q>d",

      ["Tools Menu"] = "\\t",
      ["Case Conversion Menu"] = "C",
      ["Align"] = "\\a",
    }

    -- https://github.com/mg979/vim-visual-multi/wiki/Mappings#full-mappings-list
    vim.g.VM_set_statusline = 0 -- already set via lualine component
        end,
        setup_opts = function()
        end,
        post_setup = function()
        end,
    }
end

config.highlight_colors = function()
    return {
        add = { source =  "brenoprata10/nvim-highlight-colors", depends = {}, post_install = nil, post_checkout = nil },
        require = "nvim-highlight-colors",
        load = 'now',
        s_load = 'later',
        setup_type ="invoke-setup",
        setup_param = "setup",
        setup_opts = function()
             require("nvim-highlight-colors").setup({
               render = "background",
                enable_tailwind = true,
            })
        end,
        post_setup = function()
        end,
    }
end

config.text_case = function()
    return {
        add = { source =  "johmsalas/text-case.nvim", depends = {}, post_install = nil, post_checkout = nil },
        require = "textcase",
        load = 'now',
        s_load = 'later',
        setup_type ="full-setup",
        setup_param = "setup",
        setup_opts = function()
            return {}
        end,
        post_setup = function()
        end,
    }
end

config.vim_abolish = function()
    return {
        enabled = false,
        add = { source = "tpope/vim-abolish", depends = {}, post_checkout = nil, post_install = nil },
        require = nil,
        load = "later",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function() end,
        post_setup = function() end,
    }
end

config.mini_comment = function()
    return {
      add = {
        source = "echasnovski/mini.comment",
        depends = { "JoosepAlviste/nvim-ts-context-commentstring" },
        post_install = nil,
        post_checkout = nil
      },
      require = "mini.comment",
      name = "mini.comment",
      load = 'now',
      s_load = 'later',
      setup_type = "invoke-setup",
      setup_param = "setup",
      setup_opts = function()
        require('ts_context_commentstring').setup({
          enable_autocmd = false,
          -- languages = { typescript = '// %s' },
        })

        require("mini.comment").setup({
          options = {
            custom_commentstring = function()
              return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
            end,
            ignore_blank_line = true,
            start_of_line = false,
            pad_comment_parts = true,
          },

          mappings = {
            -- Toggle comment (like `gcip` - comment inner paragraph) for both
            comment = 'gc',
            comment_line = '<leader>/',
            comment_visual = '<leader>/',
            -- Define 'comment' textobject (like `dgc` - delete whole comment block)
            textobject = 'gc',
          }
        })
      end,
      post_setup = nil,
    }
  end

return config

-- config.dial = function()
--   return {
--     add = {
--       depends = {},
--       source = "monaqa/dial.nvim",
-- post_checkout = nil, post_install = nil
--     },
--     require = "dial.config",
--     load = 'now',
--     s_load = 'later',                                    -- now | later (default)
--     setup_param = "augends:register_group(opts.groups)", --custom
--     setup_type = "invoke-setup",                         -- invoke-setup | full-setup (default)
--     setup_opts = function()
--       -- local DialOpts = function()
--       --   local augend = require("dial.augend")
--       --   local logical_alias = augend.constant.new({
--       --     elements = { "&&", "||" },
--       --     word = false,
--       --     cyclic = true,
--       --   })
--       --   local ordinal_numbers = augend.constant.new({
--       --     -- elements through which we cycle. When we increment, we go down
--       --     -- On decrement we go up
--       --     elements = {
--       --       "first",
--       --       "second",
--       --       "third",
--       --       "fourth",
--       --       "fifth",
--       --       "sixth",
--       --       "seventh",
--       --       "eighth",
--       --       "ninth",
--       --       "tenth",
--       --     },
--       --     -- if true, it only matches strings with word boundary. firstDate wouldn't work for example
--       --     word = false,
--       --     -- do we cycle back and forth (tenth to first on increment, first to tenth on decrement).
--       --     -- Otherwise nothing will happen when there are no further values
--       --     cyclic = true,
--       --   })

--       --   local weekdays = augend.constant.new({
--       --     elements = {
--       --       "Monday",
--       --       "Tuesday",
--       --       "Wednesday",
--       --       "Thursday",
--       --       "Friday",
--       --       "Saturday",
--       --       "Sunday",
--       --     },
--       --     word = true,
--       --     cyclic = true,
--       --   })

--       --   local months = augend.constant.new({
--       --     elements = {
--       --       "January",
--       --       "February",
--       --       "March",
--       --       "April",
--       --       "May",
--       --       "June",
--       --       "July",
--       --       "August",
--       --       "September",
--       --       "October",
--       --       "November",
--       --       "December",
--       --     },
--       --     word = true,
--       --     cyclic = true,
--       --   })

--       --   local capitalized_boolean = augend.constant.new({
--       --     elements = {
--       --       "True",
--       --       "False",
--       --     },
--       --     word = true,
--       --     cyclic = true,
--       --   })

--       --   return {
--       --     dials_by_ft = {
--       --       css = "css",
--       --       javascript = "typescript",
--       --       javascriptreact = "typescript",
--       --       json = "json",
--       --       lua = "lua",
--       --       markdown = "markdown",
--       --       python = "python",
--       --       sass = "css",
--       --       scss = "css",
--       --       typescript = "typescript",
--       --       typescriptreact = "typescript",
--       --       yaml = "yaml",
--       --     },
--       --     groups = {
--       --       default = {
--       --         augend.integer.alias.decimal,  -- nonnegative decimal number (5, 1, 2, 3, ...)
--       --         augend.integer.alias.hex,      -- nonnegative hex number  (0x06, 0x1a1f, etc.)
--       --         augend.date.alias["%Y/%m/%d"], -- date (2027/02/19, etc.)
--       --         ordinal_numbers,
--       --         weekdays,
--       --         months,
--       --       },
--       --       typescript = {
--       --         augend.integer.alias.decimal, -- nonnegative and negative decimal number
--       --         augend.constant.alias.bool,   -- boolean value (true <-> false)
--       --         logical_alias,
--       --         augend.constant.new({ elements = { "let", "const" } }),
--       --       },
--       --       yaml = {
--       --         augend.integer.alias.decimal, -- nonnegative and negative decimal number
--       --         augend.constant.alias.bool,   -- boolean value (true <-> false)
--       --       },
--       --       css = {
--       --         augend.integer.alias.decimal, -- nonnegative and negative decimal number
--       --         augend.hexcolor.new({
--       --           case = "lower",
--       --         }),
--       --         augend.hexcolor.new({
--       --           case = "upper",
--       --         }),
--       --       },
--       --       markdown = {
--       --         augend.misc.alias.markdown_header,
--       --       },
--       --       json = {
--       --         augend.integer.alias.decimal, -- nonnegative and negative decimal number
--       --         augend.semver.alias.semver,   -- versioning (v6.1.2)
--       --       },
--       --       lua = {
--       --         augend.integer.alias.decimal, -- nonnegative and negative decimal number
--       --         augend.constant.alias.bool,   -- boolean value (true <-> false)
--       --         augend.constant.new({
--       --           elements = { "and", "or" },
--       --           word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
--       --           cyclic = true, -- "or" is incremented into "and".
--       --         }),
--       --       },
--       --       python = {
--       --         augend.integer.alias.decimal, -- nonnegative and negative decimal number
--       --         capitalized_boolean,
--       --         logical_alias,
--       --       },
--       --     },
--       --   }
--       -- end
--       -- local opts = DialOpts()
--       -- vim.g.dials_by_ft = opts.dials_by_ft
--       local dial_config = require("dial.config")
--       local dial_augend = require("dial.augend")

--       dial_config.augends:register_group({
--         default = {
--           dial_augend.integer.alias.decimal,
--           dial_augend.integer.alias.hex,
--           dial_augend.date.alias["%Y/%m/%d"],
--           dial_augend.constant.new({
--             elements = { "true", "false" },
--             word = true,
--             cyclic = true,
--           }),
--           dial_augend.constant.new({
--             elements = { "True", "False" },
--             word = true,
--             cyclic = true,
--           }),
--           dial_augend.constant.new({
--             elements = { "and", "or" },
--             word = true,
--             cyclic = true,
--           }),
--           dial_augend.constant.new({
--             elements = { "&&", "||" },
--             word = false,
--             cyclic = true,
--           }),
--         },
--       })
--     end,
--     post_setup = function()
--       vim.keymap.set("n", "<C-a>", "<Plug>(dial-increment)", { noremap = true, silent = true, desc = "Dial Increment" })
--       vim.keymap.set("n", "<C-x>", "<Plug>(dial-decrement)", { noremap = true, silent = true, desc = "Dial Decrement" })
--       vim.keymap.set("v", "<C-a>", "<Plug>(dial-increment)", { noremap = true, silent = true, desc = "Dial Increment" })
--       vim.keymap.set("v", "<C-x>", "<Plug>(dial-decrement)", { noremap = true, silent = true, desc = "Dial Decrement" })
--       vim.keymap.set("v", "g<C-a>", "<Plug>(dial-increment)", { noremap = true, silent = true, desc = "Dial Increment" })
--       vim.keymap.set("v", "g<C-x>", "<Plug>(dial-decrement)", { noremap = true, silent = true, desc = "Dial Decrement" })
--       -- local keymaps = require("configs.base.2-keymaps").keymaps
--       -- local M = require("dial.map")

--       -- keymaps["normal"] = vim.list_extend(keymaps["normal"], {
--       --   { "<C-i>",  function() return M.manipulate("increment", "normal") end,  "Normal Increment" },
--       --   { "<C-x>",  function() return M.manipulate("decrement", "normal") end,  "Normal Decrement" },
--       --   { "g<C-i>", function() return M.manipulate("increment", "gnormal") end, "GNormal Increment" },
--       --   { "g<C-x>", function() return M.manipulate("decrement", "gnormal") end, "GNormal Decrement" },
--       -- })

--       -- keymaps["visual"] = vim.list_extend(keymaps["visual"], {
--       --   { "<C-i>",  function() return M.manipulate("increment", "visual") end,  "Visual Increment" },
--       --   { "<C-x>",  function() return M.manipulate("decrement", "visual") end,  "Visual Decrement" },
--       --   { "g<C-i>", function() return M.manipulate("increment", "gvisual") end, "GVisual Increment" },
--       --   { "g<C-x>", function() return M.manipulate("decrement", "gvisual") end, "GVisual Decrement" },
--       -- })
--     end,
--   }
-- end
-- config.mini_indentscope = function()
--   ---@return DeusConfig
--   return {
--     add = {
--       depends = {},
--       source = nil,
-- post_checkout = nil, post_install = nil
--     },
--     require = "mini.indentscope",
--     name = "mini.indentscope",
--     load = 'now',
--     s_load = 'later',
--     setup_param = "setup",
--     setup_type = "full-setup", -- invoke-setup | full-setup (default)
--     setup_opts = function()
--       return {
--         draw = {
--           delay = 0,
--           animation = require("mini.indentscope").gen_animation.none(),
--         },
--         options = { border = "top", try_as_border = true },
--         symbol = "┃",
--       }
--     end,
--     post_setup = function()
--     end,
--   }
-- end
-- --
-- config.guess_indent = function()
--   return {
--     add = {
--       depends = {},
--       source = 'nmac427/guess-indent.nvim',
--       post_checkout = nil,
--       post_install = nil,
--     },
--     require = "guess-indent",  -- Optional
--     load = 'now',
--     s_load = 'later',          -- *1=now,now | 2=now-later | 3=later-later
--     setup_param = "setup",     -- *setup,init,set,<custom>
--     setup_type = "full-setup", -- invoke-setup | *full-setup
--     setup_opts = function() end,
--     post_setup = function() end,
--   }
-- end
--
-- config.tabs_vs_spaces = function()
--   return {
--     add = {
--       depends = {},
--       source = "tenxsoydev/tabs-vs-spaces.nvim",
--       post_checkout = nil,
--       post_install = nil,
--     },
--     require = "tabs-vs-spaces", -- Optional
--     load = 'now',
--     s_load = 'later',           -- *1=now,now | 2=now-later | 3=later-later
--     setup_param = "setup",      -- *setup,init,set,<custom>
--     setup_type = "full-setup",  -- invoke-setup | *full-setup
--     setup_opts = function() end,
--     post_setup = function() end,
--   }
-- end
--
