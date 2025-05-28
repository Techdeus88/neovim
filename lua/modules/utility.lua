--Start-of-file--

return { -- Utility modules ~1~
    {
        "NStefan002/2048.nvim",
        cmd = "Play2048",
        config = function()
            require("2048").setup()
        end,
    },
    {
        "OXY2DEV/helpview.nvim",
        lazy = true,
        config = function()
            local ok, helpview = pcall(require, "helpview")
            if not ok then return end
            helpview.setup()
        end,
    },
}
--End-of-file--
