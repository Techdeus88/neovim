local globals = require("core.globals")
local funcs = require("core.funcs")

vim.uv = vim.uv

pcall(function() vim.loader.enable() end)

if globals.os == "unsupported" then
    print("Your OS is not supported!")
else
    local vim = vim
    vim.g.mapleader = " "
    vim.g.maplocalleader = ";"
    vim.keymap.set("n", " ", "", { noremap = true })
    vim.keymap.set("x", " ", "", { noremap = true })
    globals["diagnostics"] = {}
    globals["diagnostics"]["path"] = vim.fn.getcwd()
    globals["diagnostics"]["method"] = "global"
    globals["settings"] = funcs.read_file(globals.deus_path .. "/lua/configs/settings.json")
    _G.DEUS_SETTINGS = funcs.read_file(globals.deus_path .. "/lua/configs/settings.json")
    local Mini = require("core.mini") -- ACCESS MINI MODULE
    Mini.load() -- LOAD MINI
    Mini.load_mini_deps() -- Load MINI DEPS
    funcs.configs() -- LOAD ALL BASE CONFIGURATIONS
    Mini.load_modules() -- LOAD ALL MODULE CONFIGURATIONS
end
