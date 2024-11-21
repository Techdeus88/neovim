local config = {}

config.image = function()
    return {
        enabled = true,
        add = { source = "3rd/image.nvim", depends = {"luarocks.nvim"}, post_install = nil, post_checkout = nil },
        require = "image",
        load = "now",
        s_load = "later",
        setup_param = "setup",
        setup_type = "full-setup",
        pre_setup = function()
            package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
            package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"
        end,
        setup_opts = function()
            return {
                {
                backend = "kitty",
                processor = "magick_rock", -- or "magick_cli"
                integrations = {
                    markdown = {
                        enabled = true,
                        clear_in_insert_mode = false,
                        download_remote_images = true,
                        only_render_image_at_cursor = false,
                        filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
                    },
                    neorg = {
                        enabled = true,
                        filetypes = { "norg" },
                    },
                    typst = {
                        enabled = true,
                        filetypes = { "typst" },
                    },
                    html = {
                        enabled = true,
                    },
                    css = {
                        enabled = true,
                    },
                },
                max_width = 1024,
                max_height = 760,
                max_width_window_percentage = 90,
                max_height_window_percentage = 70,
                window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
                window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
                editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
                tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
                hijack_file_patterns = { "*.webp", "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, -- render image files as images when opened
            }, { rocks = { hererocks = true }}
        }
        end,
        post_setup = function() end,
    }
end

return config
