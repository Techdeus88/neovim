--Start-of-file--
local _, funcs = pcall(require, "core.funcs")

local dashboard_sections = function()
  _G.duration_dashboard_ns = get_duration "Startup"
  local get_tip = function()
    local handle_tip = funcs.safe_require "base.tip"
    local tip = handle_tip()
    return table.concat(tip, "\n")
  end
  local icons = funcs.safe_require "base.ui.icons"
  local opts = {
    { section = "startup", enabled = false },
    {
      align = "right",
      padding = 2,
      width = 60,
      pane = 1,
      header = [[
# :""8""           8   8:
# :  8  eeeee eeee e   e:
# :  8  e     e    eeeee:
# :  e  88eee e    eeeee:
# :  e  8     8    8   8:
# :  e  88eee 8888 e   e:]],
    },
    {
      section = "keys",
      pane = 1,
      title = "The keys...",
      icon = icons.ui.Keyboard,
      indent = 4,
      enabled = true,
    },
    { desc = "", padding = 0 },
    {
      icon = icons.ui.Project,
      pane = 1,
      padding = 0,
      indent = 4,
      desc = "Pick projects",
      action = "<cmd>lua Snacks.picker.projects()<cr>",
      key = "cp",
    },
    {
      icon = icons.ui.Color,
      pane = 1,
      padding = 0,
      indent = 4,
      desc = "Pick colorschemes",
      action = "<cmd>Pick colorschemes<cr>",
      key = "cs",
    },
    {
      icon = icons.ui.Bug,
      padding = 0,
      indent = 4,
      desc = "MiniDeps update",
      action = function()
        require("mini.deps").update(nil, { force = true })
      end,
      key = "mu",
    },
    {
      icon = icons.ui.Neovim,
      key = "mc",
      padding = 0,
      indent = 4,
      desc = "MiniDeps clean",
      action = function()
        require("mini.deps").clean(nil, { force = true })
      end,
    },
    {
      icon = icons.Packages,
      key = "mm",
      padding = 0,
      indent = 4,
      desc = "Mason",
      action = function()
        vim.cmd "Mason"
      end,
    },
    {
      icon = icons.Packages,
      key = "mn",
      padding = 1,
      indent = 4,
      desc = "Notes",
      action = function()
        vim.cmd "NoNeckPain"
      end,
    },
    {
      pane = 1,
      align = "left",
      desc = get_tip(),
      title = "The why...",
      padding = 0,
      icon = icons.ui.Music,
    },
    { desc = "", padding = 0 },
    {
      padding = 2,
      width = 60,
      pane = 2,
      align = "left",
      header = [[
    :e             e88ee: #
    :8 88888 e   8 e:     #
:ee88e e     e   8 eeeee: #
:8   8 ee888 8   e 88888: #
:e   e 8     8   e     8: #
:88ee8·ee888 e8e8e·8ee88: #]],
    },
    {
      pane = 2,
      enabled = true,
      section = "projects",
      indent = 4,
      title = "The projects...",
      icon = icons.ui.Dashboard,
    },
    {
      pane = 2,
      align = "left",
      text = "",
      padding = 0,
    },
    {
      pane = 2,
      enabled = true,
      section = "recent_files",
      limit = 8,
      indent = 4,
      icon = icons.ui.NewFile,
      title = "The files...",
    },
    {
      pane = 2,
      align = "left",
      text = "",
      padding = 0,
    },
    {
      pane = 2,
      title = "The metrics...",
      padding = 0,
      icon = icons.Environment,
    },

    {
      pane = 2,
      icon = icons.ui.Time,
      indent = 2,
      padding = 0,
      align = "left",
      desc = duration_dashboard_ns,
    },
  }
  return opts
end

local Themes = require "modules.ui.themes"
local ActiveSchemeConfig = Themes:active()
local theme = Global.settings.theme
Themes:load_color_mod(theme)

return { -- Start modules 5~
  { -- plenary: plenary.nvim
    "nvim-lua/plenary.nvim",
    lazy = true,
    config = true,
  },
  { -- NUI: base ui for neovim: input, search and popup
    "MunifTanjim/nui.nvim",
    lazy = false,
    config = true,
  },
  { -- snacks: small modules that enhance neovim across the board
    "folke/snacks.nvim",
    lazy = false,
    require = "snacks",
    init = function()
      vim.g.snacks_notifier_lsp_progress = false
      vim.g.snacks_notifier_lsp_status = false
      local function patch_snacks_dashboard()
        local group_states = {}
        local orig_del_augroup = vim.api.nvim_del_augroup_by_id
        _G.__safe_del_augroup = function(id)
          if not group_states[id] then
            group_states[id] = true
            pcall(orig_del_augroup, id)
          end
        end
        vim.api.nvim_del_augroup_by_id = _G.__safe_del_augroup
        local dashboard = require "snacks.dashboard"
        if dashboard then
          local orig_open = dashboard.open
          dashboard.open = function(opts)
            local instance = orig_open(opts)
            if instance and instance.augroup then
              group_states[instance.augroup] = false
              pcall(function()
                for _, cmd in
                  ipairs(vim.api.nvim_get_autocmds {
                    group = instance.augroup,
                    event = { "BufWipeout", "BufDelete" },
                  })
                do
                  pcall(vim.api.nvim_del_autocmd, cmd.id)
                end
                vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
                  group = instance.augroup,
                  buffer = instance.buf,
                  callback = function()
                    if type(instance.fire) == "function" then
                      pcall(function()
                        instance:fire "Closed"
                      end)
                    end
                    _G.__safe_del_augroup(instance.augroup)
                  end,
                })
              end)
            end
            return instance
          end
        end
      end
      patch_snacks_dashboard()

      local function fzf_scratch()
        local Snacks = require "snacks"
        local entries = {}
        local items = Snacks.scratch.list()
        local item_map = {}
        local utils = require "fzf-lua.utils"
        local function hl_validate(hl)
          return not utils.is_hl_cleared(hl) and hl or nil
        end
        local function ansi_from_hl(hl, s)
          return utils.ansi_from_hl(hl_validate(hl), s)
        end
        for _, item in ipairs(items) do
          item.icon = item.icon or Snacks.util.icon(item.ft, "filetype")
          item.branch = item.branch and ("branch:%s"):format(item.branch) or ""
          item.cwd = item.cwd and vim.fn.fnamemodify(item.cwd, ":p:~") or ""
          local display = string.format("%s %s %s %s", item.cwd, item.icon, item.name, item.branch)
          table.insert(entries, display)
          item_map[display] = item
        end
        local fzf = require "fzf-lua"
        fzf.fzf_exec(entries, {
          prompt = "Scratch Buffers",
          fzf_opts = {
            ["--header"] = string.format(
              ":: <%s> to %s | <%s> to %s",
              ansi_from_hl("FzfLuaHeaderBind", "enter"),
              ansi_from_hl("FzfLuaHeaderText", "Select Scratch"),
              ansi_from_hl("FzfLuaHeaderBind", "ctrl-d"),
              ansi_from_hl("FzfLuaHeaderText", "Delete Scratch")
            ),
          },
          actions = {
            ["default"] = function(selected)
              local item = item_map[selected[1]]
              Snacks.scratch.open {
                icon = item.icon,
                file = item.file,
                name = item.name,
                ft = item.ft,
              }
            end,
            ["ctrl-d"] = function(selected)
              local item = item_map[selected[1]]
              os.remove(item.file)
              vim.notify("Deleted scratch file: " .. item.file)
            end,
          },
        })
      end

      vim.api.nvim_create_autocmd("User", {
        callback = function()
          local Snacks = require "snacks"
          -- Setup some global for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command
          -- Create some toggle mappings
          Snacks.toggle.option("spell", { name = "Spelling" }):map "<leader>ts"
          Snacks.toggle.option("wrap", { name = "Wrap" }):map "<leader>tw"
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map "<leader>tL"
          Snacks.toggle.diagnostics():map "<leader>td"
          Snacks.toggle.line_number():map "<leader>tl"
          Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map "<leader>tc"
          Snacks.toggle.treesitter():map "<leader>tT"
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map "<leader>tb"
          Snacks.toggle.inlay_hints():map "<leader>th"
          Snacks.toggle.indent():map "<leader>tg"
          Snacks.toggle.dim():map "<leader>tD"
          vim.keymap.set("n", "<Leader>sf", function()
            fzf_scratch()
          end, { noremap = true, silent = true, desc = "Fzf scratch" })
        end,
      })
      -- Add this to ensure dashboard is enabled
      -- vim.g.snacks_dashboard_disable = false
      -- -- Create a safe version of the augroup deletion function
      -- local original_del_augroup = vim.api.nvim_del_augroup_by_id
      -- vim.api.nvim_del_augroup_by_id = function(id)
      --   pcall(original_del_augroup, id)
      -- end

      -- -- Alternatively, try directly patching the file on disk
      -- -- This is more extreme but might be necessary
      -- local plugin_path = vim.fn.stdpath('data') .. '/site/pack/deps/opt/snacks.nvim/lua/snacks/dashboard.lua'
      -- if vim.fn.filereadable(plugin_path) == 1 then
      --   local content = table.concat(vim.fn.readfile(plugin_path), '\n')
      --   content =
      --       content:gsub('vim.api.nvim_del_augroup_by_id%(group_id%)', 'pcall(vim.api.nvim_del_augroup_by_id, group_id)')
      --   vim.fn.writefile(vim.split(content, '\n'), plugin_path)
      -- end
    end,
    keys = {
      {
        "<leader><space>",
        function()
          require("snacks").picker.smart()
        end,
        desc = "Smart Find Files",
      },
      {
        "<leader>,",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>/",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>:",
        function()
          require("snacks").picker.command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader><S-n>",
        function()
          require("snacks").picker.notifications()
        end,
        desc = "Notification History",
      },
      {
        "<leader>e",
        function()
          require("snacks").explorer()
        end,
        desc = "File Explorer",
      },
      {
        "<leader>fb",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fc",
        function()
          require("snacks").picker.files { cwd = vim.fn.stdpath "config" }
        end,
        desc = "Find Config File",
      },
      {
        "<leader>ff",
        function()
          require("snacks").picker.files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>fg",
        function()
          require("snacks").picker.git_files()
        end,
        desc = "Find Git Files",
      },
      {
        "<leader>fp",
        function()
          require("snacks").picker.projects()
        end,
        desc = "Projects",
      },
      {
        "<leader>fr",
        function()
          require("snacks").picker.recent()
        end,
        desc = "Recent",
      },
      {
        "<leader>gb",
        function()
          require("snacks").picker.git_branches()
        end,
        desc = "Git Branches",
      },
      {
        "<leader>gl",
        function()
          require("snacks").picker.git_log()
        end,
        desc = "Git Log",
      },
      {
        "<leader>gL",
        function()
          require("snacks").picker.git_log_line()
        end,
        desc = "Git Log Line",
      },
      {
        "<leader>gs",
        function()
          require("snacks").picker.git_status()
        end,
        desc = "Git Status",
      },
      {
        "<leader>gS",
        function()
          require("snacks").picker.git_stash()
        end,
        desc = "Git Stash",
      },
      {
        "<leader>gd",
        function()
          require("snacks").picker.git_diff()
        end,
        desc = "Git Diff (Hunks)",
      },
      {
        "<leader>gf",
        function()
          require("snacks").picker.git_log_file()
        end,
        desc = "Git Log File",
      },
      {
        "<leader>sb",
        function()
          require("snacks").picker.lines()
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>sB",
        function()
          require("snacks").picker.grep_buffers()
        end,
        desc = "Grep Open Buffers",
      },
      {
        "<leader>sg",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>sw",
        function()
          require("snacks").picker.grep_word()
        end,
        desc = "Visual selection or word",
        mode = { "n", "x" },
      },
      {
        '<leader>s"',
        function()
          require("snacks").picker.registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>s/",
        function()
          require("snacks").picker.search_history()
        end,
        desc = "Search History",
      },
      {
        "<leader>sa",
        function()
          require("snacks").picker.autocmds()
        end,
        desc = "Autocmds",
      },
      {
        "<leader>sb",
        function()
          require("snacks").picker.lines()
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>sc",
        function()
          require("snacks").picker.command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader>sC",
        function()
          require("snacks").picker.commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>sd",
        function()
          require("snacks").picker.diagnostics()
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>sD",
        function()
          require("snacks").picker.diagnostics_buffer()
        end,
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>sh",
        function()
          require("snacks").picker.help()
        end,
        desc = "Help Pages",
      },
      {
        "<leader>sH",
        function()
          require("snacks").picker.highlights()
        end,
        desc = "Highlights",
      },
      {
        "<leader>si",
        function()
          require("snacks").picker.icons()
        end,
        desc = "Icons",
      },
      {
        "<leader>sj",
        function()
          require("snacks").picker.jumps()
        end,
        desc = "Jumps",
      },
      {
        "<leader>sk",
        function()
          require("snacks").picker.keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>sl",
        function()
          require("snacks").picker.loclist()
        end,
        desc = "Location List",
      },
      {
        "<leader>sm",
        function()
          require("snacks").picker.marks()
        end,
        desc = "Marks",
      },
      {
        "<leader>sM",
        function()
          require("snacks").picker.man()
        end,
        desc = "Man Pages",
      },
      {
        "<leader>sp",
        function()
          require("snacks").picker.lazy()
        end,
        desc = "Search for Plugin Spec",
      },
      {
        "<leader>sq",
        function()
          require("snacks").picker.qflist()
        end,
        desc = "Quickfix List",
      },
      {
        "<leader>sR",
        function()
          require("snacks").picker.resume()
        end,
        desc = "Resume",
      },
      {
        "<leader>su",
        function()
          require("snacks").picker.undo()
        end,
        desc = "Undo History",
      },
      {
        "<leader>uC",
        function()
          require("snacks").picker.colorschemes()
        end,
        desc = "Colorschemes",
      },
      {
        "gd",
        function()
          require("snacks").picker.lsp_definitions()
        end,
        desc = "Goto Definition",
      },
      {
        "gD",
        function()
          require("snacks").picker.lsp_declarations()
        end,
        desc = "Goto Declaration",
      },
      {
        "gr",
        function()
          require("snacks").picker.lsp_references()
        end,
        nowait = true,
        desc = "References",
      },
      {
        "gI",
        function()
          require("snacks").picker.lsp_implementations()
        end,
        desc = "Goto Implementation",
      },
      {
        "gy",
        function()
          require("snacks").picker.lsp_type_definitions()
        end,
        desc = "Goto T[y]pe Definition",
      },
      {
        "<leader>ss",
        function()
          require("snacks").picker.lsp_symbols()
        end,
        desc = "LSP Symbols",
      },
      {
        "<leader>sS",
        function()
          require("snacks").picker.lsp_workspace_symbols()
        end,
        desc = "LSP Workspace Symbols",
      },
      {
        "<leader>z",
        function()
          require("snacks").zen()
        end,
        desc = "Toggle Zen Mode",
      },
      {
        "<leader>Z",
        function()
          require("snacks").zen.zoom()
        end,
        desc = "Toggle Zoom",
      },
      {
        "<leader>.",
        function()
          require("snacks").scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          require("snacks").scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
      {
        "<leader>n",
        function()
          require("snacks").notifier.show_history()
        end,
        desc = "Notification History",
      },
      {
        "<leader>bd",
        function()
          require("snacks").bufdelete()
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>cR",
        function()
          require("snacks").rename.rename_file()
        end,
        desc = "Rename File",
      },
      {
        "<leader>gB",
        function()
          require("snacks").gitbrowse()
        end,
        desc = "Git Browse",
        mode = { "n", "v" },
      },
      {
        "<leader>gg",
        function()
          require("snacks").lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>un",
        function()
          require("snacks").notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<c-/>",
        function()
          require("snacks").terminal()
        end,
        desc = "Toggle Terminal",
      },
      {
        "<c-_>",
        function()
          require("snacks").terminal()
        end,
        desc = "which_key_ignore",
      },
      {
        "]]",
        function()
          require("snacks").words.jump(vim.v.count1)
        end,
        desc = "Next Reference",
        mode = { "n", "t" },
      },
      {
        "[[",
        function()
          require("snacks").words.jump(-vim.v.count1)
        end,
        desc = "Prev Reference",
        mode = { "n", "t" },
      },
      {
        "<leader>N",
        desc = "Neovim News",
        function()
          require("snacks").win {
            file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
            width = 0.6,
            height = 0.6,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = "yes",
              statuscolumn = " ",
              conceallevel = 3,
            },
          }
        end,
      },
      {
        "<leader><space>",
        function()
          require("snacks").picker.smart()
        end,
        desc = "Smart Find Files",
      },
      {
        "<leader>,",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>/",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>:",
        function()
          require("snacks").picker.command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader>n",
        function()
          require("snacks").picker.notifications()
        end,
        desc = "Notification History",
      },
      {
        "<leader>e",
        function()
          require("snacks").explorer()
        end,
        desc = "File Explorer",
      },
      {
        "<leader>fb",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fc",
        function()
          require("snacks").picker.files {
            cwd = vim.fn.stdpath "config",
          }
        end,
        desc = "Find Config File",
      },
      {
        "<leader>ff",
        function()
          require("snacks.picker").files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>fg",
        function()
          require("snacks.picker").git_files()
        end,
        desc = "Find Git Files",
      },
      {
        "<leader>fp",
        function()
          require("snacks.picker").projects()
        end,
        desc = "Projects",
      },
      {
        "<leader>fr",
        function()
          require("snacks.picker").recent()
        end,
        desc = "Recent",
      },
      {
        "<leader>gb",
        function()
          require("snacks.picker").git_branches()
        end,
        desc = "Git Branches",
      },
      {
        "<leader>gl",
        function()
          require("snacks.picker").git_log()
        end,
        desc = "Git Log",
      },
      {
        "<leader>gL",
        function()
          require("snacks.picker").git_log_line()
        end,
        desc = "Git Log Line",
      },
      {
        "<leader>gs",
        function()
          require("snacks.picker").git_status()
        end,
        desc = "Git Status",
      },
      {
        "<leader>gS",
        function()
          require("snacks.picker").git_stash()
        end,
        desc = "Git Stash",
      },
      {
        "<leader>gd",
        function()
          require("snacks.picker").git_diff()
        end,
        desc = "Git Diff (Hunks)",
      },
      {
        "<leader>gf",
        function()
          require("snacks.picker").git_log_file()
        end,
        desc = "Git Log File",
      },
      {
        "<leader>sb",
        function()
          require("snacks.picker").lines()
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>sB",
        function()
          require("snacks.picker").grep_buffers()
        end,
        desc = "Grep Open Buffers",
      },
      {
        "<leader>sg",
        function()
          require("snacks.picker").grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>sw",
        function()
          require("snacks.picker").grep_word()
        end,
        mode = { "n", "x" },
        desc = "Visual selection or word",
      },
      {
        '<leader>s"',
        function()
          require("snacks.picker").registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>s/",
        function()
          require("snacks.picker").search_history()
        end,
        desc = "Search History",
      },
      {
        "<leader>sa",
        function()
          require("snacks.picker").autocmds()
        end,
        desc = "Autocmds",
      },
      {
        "<leader>sb",
        function()
          require("snacks.picker").lines()
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>sc",
        function()
          require("snacks.picker").command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader>sC",
        function()
          require("snacks.picker").commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>sd",
        function()
          require("snacks.picker").diagnostics()
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>sD",
        function()
          require("snacks.picker").diagnostics_buffer()
        end,
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>sh",
        function()
          require("snacks.picker").help()
        end,
        desc = "Help Pages",
      },
      {
        "<leader>sH",
        function()
          require("snacks.picker").highlights()
        end,
        desc = "Highlights",
      },
      {
        "<leader>si",
        function()
          require("snacks.picker").icons()
        end,
        desc = "Icons",
      },
      {
        "<leader>sj",
        function()
          require("snacks.picker").jumps()
        end,
        desc = "Jumps",
      },
      {
        "<leader>sk",
        function()
          require("snacks.picker").keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>sl",
        function()
          require("snacks.picker").loclist()
        end,
        desc = "Location List",
      },
      {
        "<leader>sm",
        function()
          require("snacks.picker").marks()
        end,
        desc = "Marks",
      },
      {
        "<leader>sM",
        function()
          require("snacks.picker").man()
        end,
        desc = "Man Pages",
      },
      {
        "<leader>sp",
        function()
          require("snacks.picker").lazy()
        end,
        desc = "Search for Plugin Spec",
      },
      {
        "<leader>sq",
        function()
          require("snacks.picker").qflist()
        end,
        desc = "Quickfix List",
      },
      {
        "<leader>sR",
        function()
          require("snacks.picker").resume()
        end,
        desc = "Resume",
      },
      {
        "<leader>su",
        function()
          require("snacks.picker").undo()
        end,
        desc = "Undo History",
      },
      {
        "<leader>uC",
        function()
          require("snacks.picker").colorschemes()
        end,
        desc = "Colorschemes",
      },
      {
        "gd",
        function()
          require("snacks.picker").lsp_definitions()
        end,
        desc = "Goto Definition",
      },
      {
        "gD",
        function()
          require("snacks.picker").lsp_declarations()
        end,
        desc = "Goto Declaration",
      },
      {
        "gr",
        function()
          require("snacks.picker").lsp_references()
        end,
        nowait = true,
        desc = "References",
      },
      {
        "gI",
        function()
          require("snacks.picker").lsp_implementations()
        end,
        desc = "Goto Implementation",
      },
      {
        "gy",
        function()
          require("snacks.picker").lsp_type_definitions()
        end,
        desc = "Goto T[y]pe Definition",
      },
      {
        "<leader>ss",
        function()
          require("snacks.picker").lsp_symbols()
        end,
        desc = "LSP Symbols",
      },
      {
        "<leader>sS",
        function()
          require("snacks.picker").lsp_workspace_symbols()
        end,
        desc = "LSP Workspace Symbols",
      },
    },
    opts = {
      animate = {
        enabled = true,
        duration = 7,
        easing = "inOutQuad",
        fps = 120,
      },
      dim = {
        animate = {
          duration = {
            step = 7,
            total = 210,
          },
        },
      },
      dashboard = {
        enabled = true,
        pane_gap = 4,
        sections = dashboard_sections(),
      },
      image = { enabled = true },
      layout = {
        enabled = true,
        width = 0.6,
        height = 0.6,
        zindex = 50,
      },
      debug = {
        enabled = false,
      },
      notify = { enabled = true },
      notifier = {
        enabled = true,
        top_down = true,
        timeout = 5000,
        margin = {
          top = 2,
          right = 1,
          bottom = 2,
          left = 1,
        },
        padding = true,
        icons = {
          error = " ",
          warn = " ",
          info = " ",
          debug = " ",
          trace = " ",
        },
        split = {
          {
            position = "top",
            height = 0.4,
            width = 0.4,
          },
          {
            position = "right",
            height = 0.4,
            width = 0.4,
          },
        },
        width = {
          min = 40,
          max = 0.4,
        },
        height = {
          min = 1,
          max = 0.6,
        },
        sort = { "level", "added" },
        level = vim.log.levels.TRACE,
        keep = function(_)
          return vim.fn.getcmdpos() > 0
        end,
        style = "compact",
        date_format = "%R",
        more_format = " ↓ %d lines ",
        refresh = 50,
      },
      profiler = {
        enabled = false,
      },
      health = {
        enabled = true,
      },
      bigfile = {
        enabled = true,
        notify = true,
        size = Global.settings.bigfile.size,
        line_length = Global.settings.bigfile.lines,
      },
      input = { enabled = true },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = false },
      scroll = { enabled = false },
      terminal = { enabled = false },
      scratch = { enabled = true },
      statuscolumn = { enabled = false },
      lazygit = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      notification = {
        title = "TECHDEUS IDE",
        border = { "─", "─", "─", " ", "─", "─", "─", " " },
      },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      blame_line = {
        width = 0.6,
        height = 0.6,
        border = vim.g.borderStyle,
        title = " 󰉚 Git blame ",
      },
      zen = {
        fixbuf = true,
        backdrop = { transparent = false, blend = 80 },
      },

      words = {
        enabled = true,
        debounce = 200, -- time in ms to wait before updating
        notify_jump = false, -- show a notification when jumping
        notify_end = true, -- show a notification when reaching the end
        foldopen = true, -- open folds after jumping
        jumplist = true, -- set jump point before jumping
        modes = { "n", "i", "c" }, -- modes to show references},
        styles = {
          notification = {
            wo = { wrap = true }, -- Wrap notifications
          },
        },
      },
      styles = {
        dashboard = {
          zindex = 10,
          height = 0,
          width = 60,
          padding = {
            top = 1,
            bottom = 1,
            left = 2,
            right = 2,
          },
          bo = {
            bufhidden = "wipe",
            buftype = "nofile",
            buflisted = false,
            filetype = "snacks_dashboard",
            swapfile = false,
            undofile = false,
          },
          wo = {
            colorcolumn = "",
            cursorcolumn = false,
            cursorline = false,
            foldmethod = "manual",
            list = false,
            number = false,
            relativenumber = false,
            sidescrolloff = 0,
            signcolumn = "no",
            spell = false,
            statuscolumn = "",
            statusline = "",
            winbar = "",
            winhighlight = "Normal:SnacksDashboardNormal,NormalFloat:SnacksDashboardNormal",
            wrap = false,
          },
        },
        notification = {
          title = "TECHDEUS IDE",
          border = { "─", "─", "─", " ", "─", "─", "─", " " },
        },
        blame_line = {
          width = 0.6,
          height = 0.6,
          border = vim.g.borderStyle,
          title = " 󰉚 Git blame ",
        },
        zen = {
          fixbuf = true,
          backdrop = { transparent = true, blend = 21 },
        },
        scratch = {
          wo = { winhighlight = "NormalFloat:NormalFloat" },
          border = { " ", " ", " ", " ", " ", " ", " ", " " },
        },
      },
    },
    config = function(_, opts)
      local snacks_ok, snacks = pcall(require, "snacks")
      if not snacks_ok then
        vim.notify("snacks.nvim not found", vim.log.levels.ERROR)
        return
      end
      local icons = require "base.ui.icons"
      _G.stats = require("base.metrics").get_module_stats()
      local duration_dashboard_final = get_duration "Completed"
      local module_count = require("base.utils.modules").count_plugins()

      table.insert(opts.dashboard.sections, {
        id = "metrics_duration_final",
        pane = 2,
        indent = 4,
        padding = 0,
        icon = icons.ui.Check,
        align = "left",
        desc = duration_dashboard_final,
      })
      table.insert(opts.dashboard.sections, {
        id = "metrics",
        pane = 2,
        icon = icons.Packages,
        indent = 6,
        padding = 0,
        align = "left",
        desc = string.format("Loaded %s out of %s modules", stats.added, module_count),
      })
      table.insert(opts.dashboard.sections, {
        id = "metrics_2",
        pane = 2,
        desc = string.format(
          "%s lazy, %s waiting %s",
          stats.lazy,
          stats.not_loaded,
          stats.type.dependencies > 0 and string.format("and %s dependencies", stats.type.dependencies) or ""
        ),
        indent = 8,
        icon = icons.lazy.not_loaded,
        padding = 0,
        align = "left",
      })
      table.insert(opts.dashboard.sections, {
        pane = 2,
        indent = 12,
        padding = 0,
        align = "left",
        icon = icons.ui.Color,
        desc = string.format("Colorscheme is %s...", Global.settings.theme),
      })

      table.insert(opts.dashboard.sections, {
        pane = 2,
        align = "left",
        text = "",
        padding = 0,
      })

      opts.notifier.lsp_progress = false
      opts.notifier.lsp_status = false

      snacks.setup(opts)
      -- -- Register a handler for dashboard updates
      -- Events:register_handler('User DashboardUpdate', {
      --   handler = function()
      --     local stats = require('base.metrics').get_module_stats()
      --     local duration_dashboard_final = get_duration("Done")

      --     if snacks.dashboard and snacks.dashboard.instance then
      --       -- Update your dashboard sections here
      --       for _, section in ipairs(snacks.dashboard.instance.sections) do
      --         -- Update sections
      --         print(vim.inspect(section))
      --         if section.id ~= nil then
      --           if section.id == 'metrics' then
      --             section.desc = string.format('Loaded %s out of %s modules', stats.loaded, stats.total)
      --           elseif section.id == "metrics_2" then
      --             section.desc = string.format('%s lazy & %s waiting & %s dependencies', stats.lazy, stats.not_loaded,
      --               stats.type.dependencies)
      --           elseif section.id == 'metrics_duration_final' then
      --             section.desc = duration_dashboard_final
      --           elseif section.id == "metrics_total" then
      --             section.desc = string.format('Giving you %s plugins', stats.type.modules + stats.type.dependencies)
      --           end
      --         end
      --       end
      --       snacks.dashboard.instance:refresh()
      --     end
      --   end
      -- })

      -- -- Setup periodic updates
      -- local timer = vim.uv.new_timer()
      -- timer:start(0, 3000, vim.schedule_wrap(function()
      --   Events:emit_event('User DashboardUpdate', {}, false)
      -- end))
    end,
  },
  { -- Mini.nvim
    "echasnovski/mini.nvim",
    require = "mini",
    lazy = true,
    depends = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    keys = {
      {
        "<leader>?",
        "<cmd>Pick oldfiles<cr>",
        desc = "Search file history",
      },
      {
        "<leader><space>",
        "<cmd>Pick buffers<cr>",
        desc = "Search open files",
      },
      {
        "<leader>ff",
        "<cmd>Pick files<cr>",
        desc = "Search all files",
      },
      {
        "<leader>fg",
        "<cmd>Pick grep_live<cr>",
        desc = "Search in project",
      },
      {
        "<leader>fd",
        "<cmd>Pick diagnostic<cr>",
        desc = "Search diagnostics",
      },
      {
        "<leader>fs",
        "<cmd>Pick buf_lines<cr>",
        desc = "Buffer local search",
      },
      { "<leader>bc", "<cmd>lua pcall(MiniBufremove.delete)<cr>", desc = "Close buffer" },
      {
        "|d",
        function()
          return require("mini.diff").toggle_overlay
        end,
        desc = "Toggle diff overlay",
      },
      {
        "|g",
        function()
          return require("mini.diff").toggle
        end,
        desc = "Toggle git signs",
      },
      {
        "ghy",
        function()
          return require("mini.diff").operator "yank" .. "gh"
        end,
        expr = true,
        remap = true,
        desc = "Copy hunk's reference lines",
      },
      {
        "-",
        function()
          local mini_files = require "mini.files"
          mini_files.open(mini_files.get_latest_path())
        end,
        desc = "File explorer (Latest file)",
      },
      {
        "<leader>-",
        function()
          local mini_files = require "mini.files"
          mini_files.open(vim.api.nvim_buf_get_name(0), false)
          if mini_files.close() then
            return
          end
          mini_files.open()
        end,
        desc = "File Explorer (Directory)",
      },
    },
    config = function()
      local ok, MiniIcons = pcall(require, "mini.icons")
      if not ok then
        vim.notify("Mini.nvim is not loading", vim.log.levels.ERROR, {})
        return
      end

      local function safe_setup(module, opts)
        local ok, mod = pcall(require, module)
        if not ok then
          Debug.log(string.format("Error requiring %s", module), "default")
          return
        end
        if type(mod.setup) ~= "function" then
          Debug.log(string.format("Module %s is missing a setup function", module), "default")
          return
        end
        ok, err = pcall(mod.setup, opts)
        if not ok then
          Debug.log(string.format("Error loading %s: %s", module, err), "default")
        else
          Debug.log(string.format("%s loaded successfully", module), "default")
        end
      end

      local w_configs = require "configs.windows"

      -- Table of modules to configure.
      local modules = {
        { "mini.icons", { style = "glyph" } },
        { "mini.ai", { n_lines = 500 } },
        { "mini.pairs", {} },
        {
          "mini.comment",
          {
            options = {
              custom_commentstring = function()
                return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
              end,
              ignore_blank_line = true,
              start_of_line = false,
              pad_comment_parts = true,
            },
            mappings = {
              comment = "gc",
              comment_line = "gcc",
              comment_visual = "gc",
              textobject = "gc",
            },
          },
        },
        { "mini.extra", {} },
        { "mini.cursorword", { delay = 10 } },
        { "mini.notify", { lsp_progress = { enable = false } } },
        {
          "mini.bufremove",
          {
            mappings = {
              remove = "br",
              wipeout = "bR",
            },
          },
        },
        -- { "mini.tabline",     { tabpage_section = "right" } },
        { "mini.animate", {} },
        { "mini.indentscope", {} },
        {
          "mini.files",
          {
            options = {
              open_files_do_not_replace_types = {
                "terminal",
                "Trouble",
                "qf",
                "aerial",
                "NoNeckPain",
                "edgy",
              },
              permanent_delete = false,
              use_as_default_explorer = true,
              mappings = {
                close = "q",
                go_in = "l",
                go_in_plus = "<S-l>",
                go_out = "h",
                reset = "<BS>",
                reveal_cwd = "@",
                show_help = "g?",
                synchronize = "=",
                trim_left = "<",
                trim_right = ">",
              },
            },
          },
        },
        -- {
        -- 'mini.statusline',
        -- {
        --   content = {
        -- active = function()
        -- local mini_statusline = require('mini.statusline')
        -- local mode, mode_hl = mini_statusline.section_mode({ trunc_width = 120 })
        -- local diagnostics = mini_statusline.section_diagnostics({ trunc_width = 75 })
        -- local lsp = mini_statusline.section_lsp({ icon = 'LSP', trunc_width = 75 })
        -- local filename = mini_statusline.section_filename({ trunc_width = 140 })
        -- local percent = '%2p%%'
        -- local location = '%3l:%-2c'
        -- return mini_statusline.combine_groups({
        --   { hl = mode_hl,                 strings = { mode } },
        --   { hl = 'MiniStatuslineDevinfo', strings = { diagnostics, lsp } },
        --   '%<',
        --   { hl = 'MiniStatuslineFilename', strings = { filename } },
        --   '%=',
        --   { hl = 'MiniStatuslineFileinfo', strings = { percent } },
        --   { hl = mode_hl,                  strings = { location } },
        -- })
        -- end,
        -- },
        -- },
        -- },
        {
          "mini.surround",
          {
            mappings = {
              add = "gsa",
              delete = "gsd",
              find = "gsf",
              find_left = "gsF",
              highlight = "gsh",
              replace = "gsr",
              update_n_lines = "gsn",
            },
          },
        },
        {
          "mini.pick",
          {
            mappings = {
              toggle_info = "<C-k>",
              toggle_preview = "<C-p>",
              move_down = "<Tab>",
              move_up = "<S-Tab>",
              choose_in_vsplit = "<C-CR>",
              refine = "<C-J>",
              choose_marked = "<C-Q>",
            },
            options = {
              use_cache = true,
            },
            window = {
              config = w_configs.win_config_picker_center(),
            },
          },
        },
      }

      for _, mod in ipairs(modules) do
        safe_setup(mod[1], mod[2])
      end
      -- mini_icons mock vim web devicons & tweak lsp kind
      MiniIcons.mock_nvim_web_devicons()
      MiniIcons.tweak_lsp_kind()

      require("configs.pickers").add_color_scheme_picker()
      require("configs.projects").add_project_picker()
    end,
  },
}
-- [[
--     # :""8""           8   8:       :e             e88ee: #
--     # :  8  eeeee eeee e   e:       :e 88888 e   8 e      #
--     # :  8  e     e    eeeee:   :ee88e e     e   8 eeeee: #
--     # :  e· 88eee e    eeeee:   :8   8 ee888 8   e 88888: #
--     # :  e· 8     8    8   8:   :e   e 8     8   e     8: #
--     # :  e· 88eee·8888·e   e:   ·88ee8·ee888 e8e8e·8ee88: #
-- ]]
--End-of-file--
