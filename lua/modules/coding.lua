return {
    {
        'nacro90/numb.nvim',
        lazy = true,
        require = "numb",
        opts = {},
    },
    { -- Aerial: A code outline window for skimming and quick navigation
        'stevearc/aerial.nvim',
        event = 'User BaseDefered',
        opts = {
            attach_mode = 'global',
            close_on_select = true,
            layout = {
                min_width = 30,
                default_direction = 'prefer_right',
            },
            icons = {
                File = ' ',
                Module = ' ',
                Namespace = ' ',
                Class = ' ',
                Method = ' ',
                Enum = '',
                Interface = '',
                Function = ' ',
                Variable = ' ',
                Constant = ' ',
                String = ' ',
                Number = ' ',
                Boolean = '◩ ',
                Array = ' ',
                Object = ' ',
                Key = ' ',
                Null = ' ',
                Struct = ' ',
                Operator = ' ',
                TypeParameter = ' ',
            },
        },
        config = function(_, opts)
            local ok, aerial = pcall(require, 'aerial')
            if not ok then
                return
            end
            aerial.setup(opts)
        end,
    },
}
