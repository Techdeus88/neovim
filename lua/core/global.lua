--Start-of-file--
local home = os.getenv("HOME")

local function read_file(file)
    local content
    local file_content_ok, _ = pcall(function()
        content = vim.fn.readfile(file)
    end)
    if not file_content_ok then
        return nil
    end
    if type(content) == 'table' then
        local success, result = pcall(vim.fn.json_decode, content)
        return success and result or nil
    end
    return nil
end

local function getOS()
    if jit then
        return jit.os
    end
    
    local fh = io.popen("uname -o", "r")
    if not fh then
        return "other"
    end
    
    local os_name = fh:read("*l")
    fh:close()
    
    if not os_name then
        return "other"
    end
    
    if os_name:match("Darwin") then
        return "mac"
    elseif os_name:match("Linux") then
        return "linux"
    elseif os_name:match("Windows") then
        return "unsupported"
    else
        return "other"
    end
end

local global = {
    techdeus_path = home .. "/.config/nvim",
    cache_path = home .. "/.cache/nvim",
    deps_path = vim.fn.stdpath("data") .. "/site/pack/deps/start/mini.deps",
    package_path = vim.fn.stdpath("data") .. "/site",
    packer_path = home .. "/.local/share/nvim/site",
    snapshot_path = home .. "/.config/nvim/.snapshots",
    modules_path = home .. "/.config/nvim/lua/modules",
    settings_path = home .. "/.config/nvim/lua/base/settings.json",
    mason_path = home .. "/.local/share/nvim/mason",
    module_home = vim.fn.stdpath("data") .. "/site/pack/deps/start/",
    global_config = home .. "/.config/nvim/lua/core/global",
    home = home,
    first_install = not vim.loop.fs_stat(vim.fn.stdpath("data") .. "/site/pack/deps/start/mini.deps"),
    os = getOS(),
    settings = read_file(home .. "/.config/nvim/lua/base/settings.json"),
    files = {},
    lsps = {
        formatters = {},
        linters = {},
        servers = {}
    },
}

local function init()
    _G.Global = global
end

return { init = init }

--End-of-file--
