return {
    { -- NUI component: base components -> input, search, and pop-up -- ALL colorschemes
        'grapp-dev/nui-components.nvim',
        lazy = false, 
        config = true,
    },
    {
        "HiPhish/rainbow-delimiters.nvim",
        lazy = true,
        config = function()
            local rainbow_delimiters_status_ok, rainbow_delimiters = pcall(require, "rainbow-delimiters")
            if not rainbow_delimiters_status_ok then
                return
            end
            require('rainbow-delimiters.setup').setup({
                strategy = {
                    [""] = rainbow_delimiters.strategy["global"],
                    vim = rainbow_delimiters.strategy["local"],
                },
                query = {
                    [""] = "rainbow-delimiters",
                    lua = "rainbow-blocks",
                },
                highlight = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                },
            })
        end
    },
    {
        "eero-lehtinen/oklch-color-picker.nvim",
        event = "User BaseDefered",
        checkout = "*",
        require = "oklch-color-picker",
        keys = {
            -- One handed keymap recommended, you will be using the mouse
            {
                "<leader>Cp",
                function() require("oklch-color-picker").pick_under_cursor() end,
                desc = "Color pick under cursor",
            },
        },
        opts = {},
    }
}
