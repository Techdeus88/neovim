local config = {}

config.navic = function()
    return {
        add = {
            source = "SmiteshP/nvim-navic",
            depends = {},
            post_checkout = nil,
            post_install = nil
        },
        require = "nvim-navic",
        load = 'now',
        s_load = 'later',
        setup_type = "invoke-setup",
        setup_param = nil,
        setup_opts = function()
            local Config = require("modules.build_me.heirline.base")
            Config.setup_navic_state()
        end,
        post_setup = function()
        end,
    }
end

config.heirline = function()
    return {
        add = { source = "rebelot/heirline.nvim", depends = { "echasnovski/mini.icons", "justinhj/battery.nvim" }, post_checkout = nil, post_install = nil },
        require = "heirline",
        load = 'now',
        s_load = 'later',
        setup_type = "invoke-setup",
        setup_param = nil,
        setup_opts = function()
            local Config = require("modules.build_me.heirline.base")
            Config.setup_heirline_state()
        end,
        post_setup = function()
            local funcs = require("core.funcs")
            local Config = require("modules.build_me.heirline.base")
            -- Create a command to reload heirline
            vim.api.nvim_create_user_command("ReloadHeirline", function()
                funcs.reload_plugin("configs.base.colors").base_colors()
                funcs.reload_plugin("heirline")
                funcs.reload_plugin("modules.build_me.heirline.status_line")
                funcs.reload_plugin("modules.build_me.heirline.status_column")
                funcs.reload_plugin("modules.build_me.heirline.win_bar")
                -- Re-setup heirline after reload
                Config.setup_heirline_state()
            end, {})
            -- Add a keymap for quick reloading during development
            vim.keymap.set("n", "<leader>rH", "<cmd>ReloadHeirline<CR>", { desc = "Reload Heirline" })
        end,
    }
end

return config
