local P = {
    cache = {
        color_schemes = nil,
        current_scheme = nil
    }
}

local color_schemes = require("configs.colors")
local Themes = require("modules.ui.themes")

-- Cache color schemes
function P.get_color_themes()
    return Themes.names
end

-- Improved picker creation
function P.create_color_scheme_picker()
    local color_themes = P.get_color_themes()
    local choose = function(item)
        if not item or not vim.tbl_contains(color_themes, item) then return end
        local color_theme = item
        Themes:load_color_mod(color_theme, { show_update = true, save_write = true, err = 'Error setting up color scheme' })
        P.cache.current_scheme = color_theme
    end
    -- Debounced preview
    local preview_timer
    local preview = function(item)
        if preview_timer then
            preview_timer:stop()
        end
        preview_timer = vim.defer_fn(function()
            if not item or not vim.tbl_contains(color_themes, item) then return end
            local color_theme = item
            Themes:load_color_mod(color_theme, { show_update = true, save_write = true, err = 'Error setting up color scheme' })
        end, 2000)  -- 2 seconds debounce   
    end

    return {
        source = {
            items = P.get_color_themes(),
            name = "Color Schemes",
            preview = preview,
            choose = choose,
        },
        mappings = {
            preview = {
                char = "<C-p>",
                func = function()
                    local item = require("mini.pick").get_picker_matches()
                    if item then
                        preview(item)
                    end
                end,
            },
        }
    }
end

function P.add_color_scheme_picker()
    local MP_OK, MiniPick = pcall(require, "mini.pick")
    if not MP_OK then return end

    MiniPick.registry.colorschemes = function()
        local opts = P.create_color_scheme_picker()
        local init_scheme = color_schemes.active_colorscheme
        local init_theme = Global.settings.theme
        
        local ColorSchemePicker = MiniPick.start(opts)

        if ColorSchemePicker == nil then
            Themes:load_color_mod(init_theme, { show_update = true, save_write = true, err = 'Error setting up color scheme' })
            return
        end
        return MiniPick.registry[ColorSchemePicker]
    end
end

-- State recovery
function P.restore_previous_scheme()
    if P.cache.current_scheme then
        Themes:load_color_mod(P.cache.current_scheme.require, { show_update = true, save_write = true, err = 'Error setting up color scheme' })
    end
end

return P