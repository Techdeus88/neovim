local config = {}

config.battery = function()
    return {
        add = {source = "justinhj/battery.nvim", depends = {}, post_install = nil, post_checkout = nil},
        require = "battery",
        load = 'now',
        s_load = 'now',
        setup_type = "full-setup",
        setup_param = "setup",
        setup_opts = function()
            return {
                update_rate_seconds = 900,           -- Number of seconds between checking battery status
                show_status_when_no_battery = true, -- Don't show any icon or text when no battery found (desktop for example)
                show_plugged_icon = true,           -- If true show a cable icon alongside the battery icon when plugged in
                show_unplugged_icon = true,         -- When true show a diconnected cable icon when not plugged in
                show_percent = false,                -- Whether or not to show the percent charge remaining in digits
                vertical_icons = true,              -- When true icons are vertical, otherwise shows horizontal battery icon
                multiple_battery_selection = "min",     -- Which battery to choose when multiple found. "max" or "maximum", "min" or "minimum" or a number to pick the nth battery found (currently linux acpi only)
            }
        end,
        post_setup = function()end,
    }
end

return config
