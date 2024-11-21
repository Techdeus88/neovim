local config = {}


config.run_auto_cmds = function()
    local global = require("core.globals")
    local group = vim.api.nvim_create_augroup("DeusIDE", {
        clear = true,
    })

    local function augroup(name) return vim.api.nvim_create_augroup("techdeus" .. name, { clear = true }) end

    -- Strip trailing spaces before write
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        group = augroup("strip_space"),
        pattern = { "*" },
        callback = function() vim.cmd([[ %s/\s\+$//e ]]) end,
    })
    -- Fix the list chars for text files
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "text",
            "markdown",
            "org",
        },
        callback = function() vim.opt_local.listchars = "tab:  ,nbsp: ,trail: ,space: ,extends:→,precedes:←" end,
        group = group,
    })
    -- Default tab and shift stop is 4. Change to 2 for the filetypes listed below.
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "c",
            "cpp",
            "dart",
            "haskell",
            "objc",
            "objcpp",
            "ruby",
            "markdown",
            "org",
        },
        callback = function()
            vim.bo.syntax = ""
            vim.opt_local.tabstop = 2
            vim.opt_local.shiftwidth = 2
        end,
        group = group,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "NeogitStatus",
            "Outline",
            "calendar",
            "dapui_breakpoints",
            "dapui_scopes",
            "dapui_stacks",
            "dapui_watches",
            "git",
            "netrw",
            "octo",
            "org",
            "toggleterm",
        },
        callback = function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.cursorcolumn = false
            vim.opt_local.colorcolumn = "0"
        end,
        group = group,
    })
    -- Mason related notification
    vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsStartingInstall",
        callback = function()
            vim.schedule(function() vim.notify("Mason-tool-installer is starting...") end)
        end,
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        callback = function(e)
            vim.schedule(function()
                vim.notify(vim.inspect(e.data)) -- print the table that lists the programs that were installed
            end)
        end,
    })

    -- Wrap and Check for spell in text filetypes
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup("wrap_spell"),
        pattern = { "gitcommit", "markdown" },
        callback = function()
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
        end,
    })

    -- Auto create dir when saving a file, in case some intermediate directory does not exist
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        group = augroup("auto_create_dir"),
        callback = function(event)
            local file = vim.loop.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        end,
    })

    -- Check if we need to reload the file when it changed
    vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
        group = augroup("checktime"),
        callback = function()
            if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
        end,
    })

    -- Disable format options
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup("disable_formatoptions"),
        pattern = "*",
        callback = function() vim.opt_local.formatoptions:remove({ "c", "r", "o" }) end,
    })

    -- resize splits if window got resized
    -- resize splits if window got resized
    vim.api.nvim_create_autocmd({ "VimResized" }, {
        group = augroup("resize_splits"),
        callback = function() vim.cmd("tabdo wincmd =") end,
    })

    -- close some filetypes with <q>
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup("close_with_q"),
        pattern = {
            "PlenaryTestPopup",
            "grug-far",
            "help",
            "lspinfo",
            "notify",
            "qf",
            "spectre_panel",
            "startuptime",
            "tsplayground",
            "neotest-output",
            "checkhealth",
            "neotest-summary",
            "neotest-output-panel",
            "dbout",
            "gitsigns-blame",
        },
        callback = function(event)
            vim.bo[event.buf].buflisted = false
            vim.schedule(function()
                vim.keymap.set("n", "q", function()
                    vim.cmd("close")
                    pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
                end, {
                    buffer = event.buf,
                    silent = true,
                    desc = "Quit buffer",
                })
            end)
        end,
    })

    -- Fix conceallevel for env and markdown files
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = globals.event.augroup("env_conceal"),
        pattern = { ".env", ".powenv", ".markdown", ".md" },
        callback = function() vim.opt_local.conceallevel = 2 end,
    })

    -- Fix conceallevel for json files
    vim.api.nvim_create_autocmd("FileType", {
        group = globals.event.augroup("json_conceal"),
        pattern = { "json", "jsonc", "json5" },
        callback = function() vim.opt_local.conceallevel = 0 end,
    })

    vim.api.nvim_create_autocmd("TextYankPost", {
        desc = "Highlight on yank",
        group = globals.event.augroup("highlight-yank"),
        callback = function() (vim.hl or vim.highlight).on_yank({ higroup = "Visual", timeout = 200 }) end,
    })

    -- go to last loc when opening a buffer
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = augroup("last_loc"),
        callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
        end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
            vim.defer_fn(function()
                local plugins = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/opt", "*", 0, 1)
                global.plugins = plugins
            end, 5000)
        end,
        once = true,
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
            local buf_id = args.data.buf_id
            local F = require("configs.base.utils.files")

            vim.keymap.set("n", "h.", F.toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })

            vim.keymap.set("n", "ss", F.files_set_cwd, { buffer = args.data.buf_id, desc = "Set cwd" })

            F.map_split(buf_id, "<C-f>s", "horizontal", false)
            F.map_split(buf_id, "<C-f>v", "vertical", false)
            F.map_split(buf_id, "<C-f>S", "horizontal", true)
            F.map_split(buf_id, "<C-f>V", "vertical", true)
        end,
    })

    local MiniFiles = require("mini.files")
    local utils_files = require("configs.base.utils.files")
    local mini_files_open_folder = function(path) MiniFiles.open(path) end
    utils_files.attach_file_browser("mini.files", mini_files_open_folder)

    local minifiles_augroup = vim.api.nvim_create_augroup("techdeus-mini-files", {})

    vim.api.nvim_create_autocmd("User", {
        group = minifiles_augroup,
        pattern = "MiniFilesWindowOpen",
        callback = function(args) vim.api.nvim_win_set_config(args.data.win_id, { border = "rounded" }) end,
    })

    vim.api.nvim_create_autocmd("User", {
        group = minifiles_augroup,
        pattern = "MiniFilesExplorerOpen",
        callback = function()
            MiniFiles.set_bookmark("c", vim.fn.stdpath("config"), { desc = "Config" })
            MiniFiles.set_bookmark(
                "m",
                vim.fn.stdpath("data") .. "/site/pack/deps/start/mini.nvim",
                { desc = "mini.nvim" }
            )
            MiniFiles.set_bookmark("p", vim.fn.stdpath("data") .. "/site/pack/deps/opt", { desc = "Plugins" })
            MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
        end,
    })
    -- Add Padding to Mini.Files Window Titles
    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowUpdate",
        callback = function(args)
            local conf = vim.api.nvim_win_get_config(args.data.win_id)
            -- Ensure title padding
            if conf.title[#conf.title][1] ~= " " then table.insert(conf.title, { " ", "NormalFloat" }) end
            if conf.title[1][1] ~= " " then table.insert(conf.title, 1, { " ", "NormalFloat" }) end

            vim.api.nvim_win_set_config(args.data.win_id, conf)
        end,
    })
end

config.run_user_cmds = function()
  -- Reload neovim config
  vim.api.nvim_create_user_command('ReloadConfig', function()
    for name, _ in pairs(package.loaded) do
      if name:match('^modules') then
        package.loaded[name] = nil
      end
    end
    dofile(vim.env.MYVIMRC)
    vim.notify('Nvim configuration reloaded!', vim.log.levels.INFO)
  end, {})

  vim.api.nvim_create_user_command('CopyRelativePath', function()
    local path = vim.fn.expand('%')
    vim.fn.setreg('+', path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
  end, {})

  vim.api.nvim_create_user_command('CopyAbsolutePath', function()
    local path = vim.fn.expand('%:p')
    vim.fn.setreg('+', path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
  end, {})

  vim.api.nvim_create_user_command('CopyFileName', function()
    local path = vim.fn.expand('%:t')
    vim.fn.setreg('+', path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
  end, {})

  -- Switch to git root or file parent dir
  vim.api.nvim_create_user_command('RootDir', function()
    local root = require('lib.util').get_root_dir()

    if root == '' then
      return
    end
    vim.cmd('lcd ' .. root)
  end, {})

  vim.api.nvim_create_user_command("CloseFloatWindows", 'lua require("core.funcs").close_float_windows()', {})
  vim.api.nvim_create_user_command("SetGlobalPath", 'lua require("core.funcs").set_global_path()', {})
  vim.api.nvim_create_user_command("SetWindowPath", 'lua require("core.funcs").set_window_path()', {})
  vim.api.nvim_create_user_command("SudoWrite", 'lua require("core.funcs").sudo_write()', {})
  vim.api.nvim_create_user_command("Quit", 'lua require("core.funcs").quit()', {})
  vim.api.nvim_create_user_command("Save", function()
    vim.schedule(function()
      pcall(function() vim.cmd("w") end)
    end)
  end, {})
  vim.api.nvim_create_user_command("Fitten", "lua require('fittencode')", {})
  vim.api.nvim_create_user_command("TroubleToggle", "Trouble diagnostics toggle", {})

end
return config
