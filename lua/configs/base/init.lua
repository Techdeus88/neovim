local global_success, global = pcall(require, "core.globals")
if not global_success then
    print("Error loading core.globals: " .. global)
    return
end

local funcs_success, funcs = pcall(require, "core.funcs")
if not funcs_success then
    print("Error loading core.funcs: " .. funcs)
    return
end

local options_success, options = pcall(require, "configs.base.1-options")
if not options_success then
    print("Error loading core.options: " .. options)
    return
end

local cmds_success, cmds = pcall(require, "configs.base.2-cmds_auto_user")
if not cmds_success then
    print("Error loading core.autocmds: " .. cmds)
    return
end

local km_success, km = pcall(require, "configs.base.3-keymaps")
if not km_success then
    print("Error loading core.keymaps: " .. km)
    return
end

local icons_success, icons = pcall(require, "configs.base.ui.icons")
if not icons_success then
    print("Error loading core.icons: " .. icons)
    return
end

local group = vim.api.nvim_create_augroup("DeusIDE", {
    clear = true,
})

local configs = {}

configs["1_base_techdeus"] = function()
    local function deus_theme()
        local status
        if _G.DEUS_SETTINGS.theme == "tokyobones" then
            status = "tokyobones"
        elseif _G.DEUS_SETTINGS.theme == "seoulbones" then
            status = "seoulbones"
        elseif _G.DEUS_SETTINGS.theme == "randombones" then
            status = "randombones"
        elseif _G.DEUS_SETTINGS.theme == "forestbones" then
            status = "forestbones"
        elseif _G.DEUS_SETTINGS.theme == "rosebones" then
            status = "rosebones"
        elseif _G.DEUS_SETTINGS.theme == "nordbones" then
            status = "nordbones"
        elseif _G.DEUS_SETTINGS.theme == "duckbones" then
            status = "duckbones"
        elseif _G.DEUS_SETTINGS.theme == "neobones" then
            status = "neobones"
        elseif _G.DEUS_SETTINGS.theme == "vimbones" then
            status = "vimbones"
        elseif _G.DEUS_SETTINGS.theme == "zenburned" then
            status = "zenburned"
        elseif _G.DEUS_SETTINGS.theme == "zenbones" then
            status = "zenbones"
        elseif _G.DEUS_SETTINGS.theme == "zenwritten" then
            status = "zenwritten"
        end

        local ui_config = require("modules.build_me.base.config")
        local select = require("modules.build_me.base.select")
        local notify = require("modules.build_me.base.notify")
        local opts = ui_config.select({
            "zenwritten",
            "zenburned",
            "zenbones",
            "seoulbones",
            "neobones",
            "vimbones",
            "duckbones",
            "nordbones",
            "rosebones",
            "tokyobones",
            "forestbones",
            "randombones",
            "Cancel",
        }, { prompt = "Theme (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Cancel" then
            else
                local user_choice = string.lower(choice)
                user_choice = string.gsub(user_choice, " ", "-")

                _G.DEUS_SETTINGS["theme"] = user_choice
                global["theme"] = user_choice
                local f_settings = vim.deepcopy(_G.DEUS_SETTINGS)
                funcs.write_file(global.deus_path .. "/lua/configs/settings.json", f_settings)
                notify.info("Theme: " .. choice, { title = "DEUS IDE" })
            end
        end)
    end

    vim.api.nvim_create_user_command("DeusTheme", deus_theme, {})
    local function deus_float_height()
        local status = tostring(_G.DEUS_SETTINGS.floatheight)
        if status == "1" then status = "1.0" end
        local ui_config = require("modules.build_me.base.config")
        local select = require("modules.build_me.base.select")
        local notify = require("modules.build_me.base.notify")
        local opts = ui_config.select({
            "0.1",
            "0.2",
            "0.3",
            "0.4",
            "0.5",
            "0.6",
            "0.7",
            "0.8",
            "0.9",
            "1.0",
            "Cancel",
        }, { prompt = "Float height (current: " .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Cancel" then
            else
                local user_choice = choice
                _G.DEUS_SETTINGS["floatheight"] = tonumber(user_choice) + 0.0
                global["settings"]["floatheight"] = tonumber(user_choice) + 0.0

                local fl_settings = vim.deepcopy(_G.DEUS_SETTINGS)
                funcs.write_file(global.deus_path .. "/lua/configs/settings.json", fl_settings)
                notify.info("Float height: " .. choice, { title = "Deus IDE" })
                -- local editor_config = require("modules.base.configs.editor")
                -- editor_config.fzf_lua()
                -- editor_config.telescope_nvim()
                -- local deus_ui_config = require("modules.base.configs.ui")
                -- deus_ui_config.deus_fm()
                -- local version_control_config = require("modules.base.configs.version_control")
                -- version_control_config.deus_forgit()
            end
        end)
    end
    vim.api.nvim_create_user_command("DeusFloatHeight", deus_float_height, {})
    vim.api.nvim_create_user_command(
        "EditorConfigCreate",
        "lua require'core.funcs'.copy_file(require'core.globals'.deus_path .. '/lua/configs/templates/.editorconfig', vim.fn.getcwd() .. '/.editorconfig')",
        {}
    )
end

configs["2_base_options"] = function()
    options.global()
    vim.g.gitblame_enabled = 0
    vim.g.gitblame_highlight_group = "CursorLine"
    pcall(function() vim.opt.splitkeep = "screen" end)
    vim.g.netrw_banner = 0
    vim.g.netrw_hide = 1
    vim.g.netrw_browse_split = 0
    vim.g.netrw_altv = 1
    vim.g.netrw_liststyle = 1
    vim.g.netrw_winsize = 20
    vim.g.netrw_keepdir = 1
    vim.g.netrw_list_hide = "(^|ss)\zs.S+"
    vim.g.netrw_localcopydircmd = "cp -r"
end

configs["3_base_events"] = function() cmds.run_auto_cmds() end

configs["4_base_languages"] = function()
    vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        callback = function() require("languages").setup() end,
        group = group,
    })
end

configs["5_base_commands"] = function() cmds.run_user_cmds() end

configs["6_base_keymaps"] = function()
    local keymaps = km.keymaps
    local keymaps_ft = km.keymaps_ft

    funcs.keymaps("n", { noremap = true, silent = true }, keymaps.normal)
    funcs.keymaps("x", { noremap = true, silent = true }, keymaps.visual)
    funcs.keymaps("i", { noremap = true, silent = true }, keymaps.insert)
    keymaps_ft.set()
end

configs["7_base_ctrlspace_pre_config"] = function()
    vim.g.ctrlspace_use_tablineend = 1
    vim.g.CtrlSpaceLoadLastWorkspaceOnStart = 0
    vim.g.CtrlSpaceSaveWorkspaceOnSwitch = 1
    vim.g.CtrlSpaceSaveWorkspaceOnExit = 1
    vim.g.CtrlSpaceUseTabline = 0
    vim.g.CtrlSpaceUseArrowsInTerm = 1
    vim.g.CtrlSpaceUseMouseAndArrowsInTerm = 1
    vim.g.CtrlSpaceGlobCommand = "rg --files --follow --hidden -g '!{.git/*,node_modules/*,target/*,vendor/*}'"
    vim.g.CtrlSpaceIgnoredFiles = "\v(tmp|temp)[\\/]"
    vim.g.CtrlSpaceSearchTiming = 10
    vim.g.CtrlSpaceEnableFilesCache = 1
    vim.g.CtrlSpaceSymbols = icons.ctrlspace
end

return configs
