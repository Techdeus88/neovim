-----------------------------------Formatting----------------------------------
local config = {}

config.lsp_config = function()
    return {
        add = {
            depends = {
                "VonHeikemen/lsp-zero.nvim",
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",
                "WhoIsSethDaniel/mason-tool-installer.nvim",
            },
            source = "neovim/nvim-lspconfig",
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

config.lsp_zero = function()
    return {
        add = {
            depends = {},
            source = "VonHeikemen/lsp-zero.nvim",
            checkout = "v4.x",
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

config.fidget = function()
    return {
        add = {
            depends = {},
            source = "j-hui/fidget.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "fidget",
        load = "now",
        s_load = "now", -- *1=now,now | 2=now-later | 3=later-later
        setup_param = "setup", -- *setup,init,set,<custom>
        setup_type = "invoke-setup", -- invoke-setup | *full-setup
        setup_opts = function() require("fidget").setup() end,
        post_setup = function() end,
    }
end

config.mason = function()
    return {
        add = {
            depends = {},
            source = "williamboman/mason.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "mason", -- Optional
        load = "now",
        s_load = "later", -- *1=now,now | 2=now-later | 3=later-later
        setup_param = "setup", -- *setup,init,set,<custom>
        setup_type = "full-setup", -- invoke-setup | *full-setup
        setup_opts = function()
            local icons = require("configs.base.ui.icons")
            return {
                PATH = "append",
                log_level = vim.log.levels.INFO,

                max_concurrent_installers = 8,

                ui = {
                    check_outdated_packages_on_open = true,
                    border = "rounded",
                    width = 0.8,
                    height = 0.8,

                    icons = {
                        package_installed = icons.ui.Gear,
                        package_pending = icons.ui.Download,
                        package_uninstalled = icons.ui.Plus,
                    },

                    keymaps = {
                        toggle_package_expand = "<CR>",
                        install_package = "i",
                        update_package = "u",
                        check_package_version = "c",
                        update_all_packages = "U",
                        check_outdated_packages = "C",
                        uninstall_package = "x",
                        cancel_installation = "<C-c>",
                        apply_language_filter = "<C-f>",
                    },
                },
            }
        end,
        post_setup = function() end,
    }
end

config.mason_lsp = function()
    return {
        add = {
            depends = {},
            source = "williamboman/mason-lspconfig.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "mason-lspconfig", -- Optional
        load = "now",
        s_load = "later", -- *1=now,now | 2=now-later | 3=later-later
        setup_param = "setup", -- *setup,init,set,<custom>
        setup_type = "full-setup", -- invoke-setup | *full-setup
        setup_opts = function() end,
        post_setup = function() end,
    }
end

config.mason_tool_installer = function()
    return {
        add = {
            depends = {},
            source = "WhoIsSethDaniel/mason-tool-installer.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "mason-tool-installer", -- Optional
        load = "now",
        s_load = "later", -- *1=now,now | 2=now-later | 3=later-later
        setup_param = "setup", -- *setup,init,set,<custom>
        setup_type = "full-setup", -- invoke-setup | *full-setup
        setup_opts = function() return {} end,
        post_setup = function() end,
    }
end

config.nvim_completion = function()
    return {
        add = {
            source = "hrsh7th/nvim-cmp",
            depends = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-cmdline",
                "hrsh7th/cmp-emoji",
            },
            post_install = nil,
            post_checkout = nil,
        },
        require = "cmp",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            local icons = require("configs.base.ui.icons")
            local kind_icons = icons.kind
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_snipmate").lazy_load()
            cmp.setup({
                preselect = "item",
                completion = {
                    completeopt = "menu,menuone,preview,noselect",
                },
                formatting = {
                    fields = { "abbr", "kind", "menu" },
                    expandable_indicator = true,
                    format = function(entry, vim_item)
                        vim_item.kind = kind_icons[vim_item.lind]

                        if entry.source.name == "copilot" then
                            vim_item.kind = icons.git.Octoface
                            vim_item.kind_hl_group = "CmpItemKindCopilot"
                        end

                        vim_item.menu = ({
                            copilot = "[Copilot]",
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                            cmdline = "[CMD Line]",
                            emoji = "[Emoji]",
                        })[entry.source.name]
                        return vim_item
                    end,
                },
                sources = {
                    { name = "copilot" },
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "nvim_lua" },
                    { name = "luasnip", keyword_length = 2 },
                    { name = "buffer", keyword_length = 3 },
                    { name = "lazydev", group_index = 0 },
                },
                snippet = {
                    expand = function(args)
                        -- You need Neovim v0.10 to use vim.snippet
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
                    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
                    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<C-y>"] = cmp.config.disable,
                    ["<C-c>"] = cmp.mapping({
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    }),
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = false,
                    }),
                    -- ["<Tab>"] = cmp_action.luasnip_supertab(),
                    -- ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expandable() then
                            luasnip.expand()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                confirm_opts = {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                },
                window = {
                    documentation = {
                        border = "rounded",
                        winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
                    },
                    completion = {
                        border = "rounded",
                        winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
                    },
                    scrollbar = true,
                },
                experimental = {
                    ghost_text = true,
                },
            })
        end,
        post_setup = function() end,
    }
end

config.luasnip = function() --[Dev]: Vim Snippets engine [snippet engine] + [snippet templates]--
    return {
        add = {
            source = "l3mon4d3/luasnip",
            depends = {
                "saadparwaiz1/cmp_luasnip",
                "rafamadriz/friendly-snippets",
                "zeioth/normalsnippets",
                "benfowler/telescope-luasnip.nvim",
            },
            post_install = nil,
            post_checkout = function() return { build = "make install_jsregexp" or nil } end,
        },
        require = "luasnip",
        load = "now",
        s_load = "later",
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function() return {} end,
        post_setup = function() end,
    }
end

config.folding = function()
    return {
        add = { source = "kevinhwang91/nvim-ufo", depends = { "kevinhwang91/promise-async" } },
        require = "ufo",
        load = "now",
        s_load = "later",
        setup_type = "invoke-setup",
        setup_param = "setup",
        setup_opts = function()
            -- Open up space in the editor to the gutter area
            vim.opt.signcolumn = "yes"
            require("ufo").setup({})
            return
        end,
        post_setup = function() end,
    }
end

config.formatters = function()
    return {
        add = {
            depends = {},
            source = "stevearc/conform.nvim",
            post_checkout = nil,
            post_install = nil,
        },
        require = "conform",
        load = "now",
        s_load = "later",
        setup_param = "setup",
        setup_type = "full-setup",
        setup_opts = function()
            return {
                formatters_by_ft = {
                    lua = { "stylua" },
                    fish = { "fish_indent" },
                    sh = { "shfmt" },
                    javascript = { "prettierd", "prettier", stop_after_first = true },
                    typescript = { "prettierd", "prettier", stop_after_first = true },
                    typescriptreact = {
                        "prettierd",
                        "prettier",
                        stop_after_first = true,
                    },
                    javascriptreact = {
                        "prettierd",
                        "prettier",
                        stop_after_first = true,
                    },
                    go = { "gofumpt", "goimports", "gomodifytags" },
                    python = { "isort", "black", "autoflake", "autopep8" },
                    css = { "prettierd" },
                    html = { "prettierd" },
                    json = { "prettierd" },
                    yaml = { "prettierd" },
                    markdown = { "prettierd" },
                    r = { "my_styler" },
                },
                formatters = {
                    injected = { options = { ignore_errors = true } },
                    -- # Example of using dprint only when a dprint.json file is present
                    dprint = {
                        condition = function(ctx)
                            return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
                        end,
                    },
                    shfmt = {
                        inherit = false,
                        command = "shfmt",
                        prepend_args = function() return { "-i", "2", "-filename", "$FILENAME" } end,
                    },
                    my_styler = {
                        command = "R",
                        -- A list of strings, or a function that returns a list of strings
                        -- Return a single string instead of a list to run the command in a shell
                        args = { "-s", "-e", "styler::style_file(commandArgs(TRUE)[1])", "--args", "$FILENAME" },
                        stdin = false,
                    },
                },
            }
        end,
        post_setup = function()
            return vim.keymap.set(
                "n",
                "<leader>bf",
                function() require("conform").format() end,
                { desc = "Format buffer" }
            )
        end,
    }
end

config.linters = function()
    return {
        add = {
            depends = {},
            source = "mfussenegger/nvim-lint", -- Required
            post_checkout = nil,
            post_install = nil,
        },
        require = "lint", -- Optional
        load = "now",
        s_load = "later", -- *1=now,now | 2=now-later | 3=later-later
        setup_param = "setup", -- *setup,init,set,<custom>
        setup_type = "invoke-setup", -- invoke-setup | *full-setup
        setup_opts = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                fish = { "fish" },
                markdown = { "markdownlint" },
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                python = { "flake8", "pylint" },
                lua = { "luacheck" },
                css = { "stylelint" },
                go = { "golangci-lint" },
                json = { "jsonlint" },
                dockerfile = { "hadolint" },
                rst = { "vale" },
                ruby = { "ruby" },
                terraform = { "tflint" },
                text = { "vale" },
            }

            lint.linters = {
                eslint_d = {
                    args = {
                        "--no-warn-ignored",
                        "--format",
                        "json",
                        "--stdin",
                        "--stdin-filename",
                        function() return vim.api.nvim_buf_get_name(0) end,
                    },
                },
                "vale",
                "flake8",
                "pylint",
                "markdownlint",
                "jsonlint",
                "fish",
                "typos",
                "golangci-lint",
                "ruby",
                "luacheck",
                "tflint",
                ["*"] = "typos",
            }
        end,
        post_setup = function()
            local function find_nearest_node_modules_dir()
                -- current buffer dir
                local current_dir = vim.fn.expand("%:p:h")
                while current_dir ~= "/" do
                    if vim.fn.isdirectory(current_dir .. "/node_modules") == 1 then return current_dir end
                    current_dir = vim.fn.fnamemodify(current_dir, ":h")
                end
                return nil
            end

            vim.keymap.set("n", "<leader>bl", function()
                local lint = require("lint")
                local ft = vim.bo.filetype
                local js_types = { "javascript", "typescript", "javascriptreact", "typescriptreact" }
                if not vim.tbl_contains(js_types, ft) then
                    lint.try_lint()
                    return
                end
                local original_cwd = vim.fn.getcwd()
                local node_modules_dir = find_nearest_node_modules_dir()
                if node_modules_dir then vim.cmd("cd " .. node_modules_dir) end
                lint.try_lint()
                vim.cmd("cd " .. original_cwd)
            end, { desc = "Lint buffer" })
        end,
    }
end

return config
