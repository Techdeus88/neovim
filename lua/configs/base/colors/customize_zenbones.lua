-- local lush = require "lush"

-- -- Create specs with error handling
-- local specs = {
--     MiniIconsAzure = { fg = "#0B8EC6", italic = true },
--     MiniIconsCyan = { fg = "#02A384", italic = true },
--     MiniIconsGrey = { fg = "#222222", italic = true },
--     MiniIconsOrange = { fg = "#FF9C2A", italic = true },
--     MiniIconsPurple = { fg = "#800080", italic = true },
--     MiniIconsRed = { fg = "#E34A39", italic = true },
--     MiniIconsYellow = { fg = "#E58C26", italic = true },
-- }

-- -- Simplified highlight application function
-- local function apply_highlights()
--     for group, opts in pairs(specs) do
--         vim.api.nvim_set_hl(0, group, opts)
--     end
-- end

-- -- Apply immediately and set up autocommand for ColorScheme changes
-- apply_highlights()

-- vim.api.nvim_create_autocmd("ColorScheme", {
--     callback = apply_highlights,
--     group = vim.api.nvim_create_augroup("MiniIconsHighlights", { clear = true })
-- })