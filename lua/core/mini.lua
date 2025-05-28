--- @module core.mini
--- @return nil
local function install_mini_deps()
    local package_path = vim.fn.stdpath("data") .. "/site"
    local deps_path = package_path .. "/pack/deps/start/mini.deps"

    if not vim.loop.fs_stat(deps_path) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/echasnovski/mini.deps",
            deps_path,
        })

        vim.cmd.packadd('mini.deps | helptags ALL')
        vim.cmd.echo('"Installed `mini.deps`" | redraw')
        Debug.log("MiniDeps is installed", "default")
    end
end

--- @return nil
local function load_mini_deps()
    local package_path = vim.fn.stdpath("data") .. "/site"
    require("mini.deps").setup({
        path = { package = package_path },
        job = {
            n_threads = 10,
            -- Add these optimizations
            timeout = 30000, -- 30 seconds timeout for operations
            retry = 2,   -- Number of retries for failed operations
        },
        cache = {
            enabled = true,
            path = vim.fn.stdpath("cache") .. "/mini-deps",
            ttl = 86400, -- 24 hours
        }
    })
    _G.add, _G.now, _G.later = MiniDeps.add, MiniDeps.now, MiniDeps.later
    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniDepsFinished",
        callback = function()
            local stats = vim.fn.timer_info()
            if stats and stats[1] then
                vim.notify(string.format("Plugins loaded in %.2f ms", stats[1].time), vim.log.levels.INFO)
            end
        end
    })
    Debug.log("MiniDeps is loaded", "default")
end

local function init()
    install_mini_deps()
    load_mini_deps()
end

return { init = init }
