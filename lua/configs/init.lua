local config = {}
local helper = {}

helper.is_config_function = function(conf)
    if type(conf) ~= "function" then return false end
    return true
end

helper.is_disabled = function(conf)
    -- Having nil for enabled is indirectly saying that the plugin is enabled and to add it to the session and configure it.
    if conf.enabled ~= nil and not conf.enabled then return true end
    return false
end

helper.is_enabled = function(conf)
    if conf.enabled == nil or (conf.enabled ~= nil and conf.enabled) then return true end
    return false
end

helper.add_config = function(add, name)
    if add.source then
        MiniDeps.add({
            source = add.source,
            depends = add.depends,
            checkout = add.checkout ~= nil and add.checkout or nil,
            monitor = add.monitor ~= nil and add.monitor or nil,
            hooks = {
                post_install = (add.post_install ~= nil or not add.post_install == "") and add.post_install or nil,
                post_checkout = (add.post_checkout ~= nil or not add.post_checkout == "") and add.post_checkout or nil,
            },
        })
        add_to_log(string.format("Module %s added to session. MiniDeps.add()", name))
    else
        vim.notify("No source specified for adding plugin: " .. name, vim.log.levels.WARN)
    end
end

helper.add_plugin = function(plugin_config, load_type, name)
    local function add()
        local success, result = pcall(function() return helper.add_config(plugin_config.add, name) end)
        if not success then
            vim.notify(string.format("Error adding plugin: %s .. %s", name, result), vim.log.levels.ERROR)
            return false
        end
        return true -- Indicate success
    end

    -- Create a mapping table for load types
    local load_functions = {
        now = function() return MiniDeps.now(add) end,
        later = function()
            MiniDeps.later(add)
            return true
        end,
    }

    -- Check if the load_type is valid and call the corresponding function
    local load_function = load_functions[load_type]

    if load_function then
        return load_function() -- Call the mapped function
    else
        vim.notify(string.format("<%s>: Invalid load type specified. Use 'now' or 'later'.", name), vim.log.levels.WARN)
        vim.notify(name, vim.log.levels.WARN)
        return false -- Indicate failure`   q1
    end
end

helper.pre_plugin = function(c, plugin_name, idx)
    MiniDeps.now(function()
        c.pre_setup()
        add_to_log(string.format("Pre setup complete - %s", plugin_name), plugin_name, idx)
    end)
end

helper.setup_config = function(setup_opts, require_name, plugin_name, setup_type, setup_param)
    if not setup_opts then
        vim.notify("No setup options provided for plugin: " .. plugin_name, vim.log.levels.WARN)
        return true, "No setup required" -- Indicate that no setup is needed
    end

    local success, result = pcall(function()
        if setup_type == "full-setup" then
            local module = require(require_name)
            local opts = setup_opts()
            if setup_param == "setup" then
                return module.setup(opts)
            elseif setup_param == "set" then
                return module.set(opts)
            elseif setup_param == "init" then
                return module.init(opts)
            else
                vim.notify("Invalid setup param specified. Use 'setup', 'set', or 'init'", vim.log.levels.WARN)
                return false
            end
        elseif setup_type == "invoke-setup" then
            setup_opts()
            return true
        else
            vim.notify("Invalid setup type specified. Use 'full-setup' or 'invoke-setup'", vim.log.levels.WARN)
            return false
        end
    end)

    return success, result
end

helper.post_plugin = function(c, plugin_name, idx)
    MiniDeps.later(function()
        c.post_setup()
        add_to_log(string.format("Post setup complete - %s", plugin_name), plugin_name, idx)
    end)
end

helper.setup_plugin = function(require_name, plugin_name, setup_opts, load_type, setup_type, setup_param)
    local function setup()
        local success, result = helper.setup_config(setup_opts, require_name, plugin_name, setup_type, setup_param)
        if not success then
            vim.notify(string.format("Error adding plugin: %s .. %s", plugin_name, result), vim.log.levels.ERROR)
            return false
        end
        add_to_log(string.format("Module configuration & setup complete - %s", plugin_name))
        return true
    end

    -- Create a mapping table for load types
    local load_functions = {
        now = function() MiniDeps.now(setup) end,
        later = function()
            MiniDeps.later(setup)
            return true
        end,
    }
    -- Check if the load_type is valid and call the corresponding function
    local load_function = load_functions[load_type]

    if load_function then
        return load_function() -- Call the mapped function
    else
        vim.notify("Invalid load type specified. Use 'now' or 'later'", vim.log.levels.WARN)
        return false -- Indicate failure
    end
end

config.mini_config = function(conf, idx)
    ---@type DeusConfigWrapper
    if not helper.is_config_function(conf) then return end
    local c = conf()
    if helper.is_enabled(c) then
        -- Attempt to extract the plugin name from the source
        local plugin_name = c.require
        if c.pre_setup ~= nil then helper.pre_plugin(c, plugin_name, idx) end
        add_to_log(string.format("Start mini module %s-%s load", plugin_name, idx), config, plugin_name, idx)
        helper.setup_plugin(c.require, plugin_name, c.setup_opts, c.load, c.setup_type, c.setup_param)
        -- All mini modules that run through the mini config are lazy loaded...
        if c.post_setup ~= nil then helper.post_plugin(c, plugin_name, idx) end
        add_to_log(string.format("End mini module %s-%s install complete", plugin_name, idx))
        return { result = true, config = c }
    end
    return { result = false, config = c }
end

---@type DeusConfigWrapper
config.default_config = function(conf, idx)
    local Debug = require("core.debug")

    if not helper.is_config_function(conf) then return { result = false, config = nil } end
    -- initialize configuration
    local c = conf()

    -- Debug dump of the module configuration
    Debug._dump(c, {
        loc = "Module Load",
    })

    Debug._dump(c, {
        module_size = (Debug.estimateSize(c) / 1024) .. " KB",
    })
    -- If disabled then return
    if helper.is_enabled(c) then
        -- Attempt to extract the plugin name from the source
        local plugin_name = c.add.source and c.add.source:match("([^/]+)$") or c.name or c.require
        -- Load the pre-setup function if available
        if c.pre_setup ~= nil then helper.pre_plugin(c, plugin_name, idx) end
        add_to_log(string.format("Start module '%s-%s' install and setup", plugin_name, idx), plugin_name, idx)
        -- Add the plugin if it has a source
        if c.add and c.add.source ~= nil then helper.add_plugin(c, c.load, plugin_name) end
        -- Setup the plugin if it requires setup options
        if c.require ~= nil and c.setup_opts then
            helper.setup_plugin(c.require, plugin_name, c.setup_opts, c.s_load, c.setup_type, c.setup_param)
        end
        -- Post setup methods to run immediately after the module is configured
        if c.post_setup ~= nil then helper.post_plugin(c, plugin_name, idx) end
        add_to_log(string.format("End module '%s-%s' install and setup complete", plugin_name, idx), idx, plugin_name)
        return { result = true, config = c }
    end

    return { result = false, config = c }
end

return config
