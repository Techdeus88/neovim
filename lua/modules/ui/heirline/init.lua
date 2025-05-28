return { -- UI Modules ~5~ -
  {      -- Tabby.nvim: maage the tabline with tabs/window combo
    "nanozuki/tabby.nvim",
    require = "tabby",
    event = "User BaseFile",
    keys = {
      {
        "<leader>tR",
        function()
          require("configs.ui").rename_tab()
        end,
        desc = "Tab Rename",
      },
      {
        "<leader>ta",
        ":$tabnew<CR>",
        desc = "Tab: new",
        noremap = true,
      },
      {
        "<leader>tc",
        ":tabclose<CR>",
        desc = "Tab: close",
        noremap = true,
      },
      {
        "<leader>to",
        ":tabonly<CR>",
        desc = "Tab: only",
        noremap = true,
      },
      {
        "<leader>tn",
        ":tabn<CR>",
        desc = "Tab: next",
        noremap = true,
      },
      {
        "<leader>tp",
        ":tabp<CR>",
        desc = "Tab: prev",
        noremap = true,
      },
      {
        "<leader>tmp",
        ":-tabmove<CR>",
        desc = "Tab: Move to prev pos",
        noremap = true,
      },
      {
        "<leader>tmn",
        ":+tabmove<CR>",
        desc = "Tab: move to next pos",
        noremap = true,
      },
    },
    config = function()
      local ok, Tabby = pcall(require, "tabby")
      if not ok then
        vim.notify("Tabby not loading", vim.log.levels.ERROR, {})
        return
      end

      local icons = require("base.utils").get_icons "base"
      local Tabby_Api = require "tabby.module.api"
      local win_name = require "tabby.feature.win_name"
      local col = require "configs.colors"
      local common = require "modules.ui.heirline.common"

      -- Get colors
      local base_colors = common.get_base_colors()
      local mode_colors = common.get_mode_colors()

      local theme = {
        fill = "TabLineFill",
        current_tab = {
          fg = base_colors.constant.fg,
          bg = base_colors.normal.bg,
          style = "italic",
        },
        current_win = {
          fg = mode_colors.normal.fg,
          bg = base_colors.normal.bg,
          style = "italic",
        },
        tab = {
          fg = base_colors.normal.bg,
          bg = base_colors.constant.fg,
          style = "italic",
        },
        win = {
          fg = base_colors.normal.bg,
          bg = base_colors.title.fg,
          style = "italic",
        },
        head = {
          fg = base_colors.normal.bg,
          bg = base_colors.constant.fg,
          style = "italic",
        },
        tail = {
          fg = base_colors.normal.bg,
          bg = base_colors.title.fg,
          style = "italic",
        },
      }

      -- Update colors when colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          base_colors = common.get_base_colors()
          mode_colors = common.get_mode_colors()
        end,
      })

      local function get_dynamic_content()
        -- Function to get counts
        local function get_total_wins()
          return #vim.api.nvim_list_wins()
        end
        local function get_total_tabs()
          return #vim.api.nvim_list_tabpages()
        end

        -- Create the counts string with proper spacing
        local left_counts = string.format(" [%d", get_total_tabs())
        local right_counts = string.format("%d] ", get_total_wins())

        return {
          hl = theme.fill,
          { left_counts,  hl = { fg = theme.current_tab.fg } },
          { ":",          hl = theme.fill },
          { right_counts, hl = { fg = theme.current_win.fg } },
        }
      end

      local function get_git_branch(bufnr)
        local branch = vim.b[bufnr or 0].gitsigns_head or ""
        if branch and branch ~= "" then
          return " " .. branch .. " "
        end
        return " [No-Git-Repo] "
      end

      local function win_label(winid, top)
        local icon = top and "" or ""
        return string.format(" %s  %s ", icon, win_name.get(winid, { mode = "unique" }))
      end

      local function calculate_content_widths(tabs, wins)
        local left_width = 0
        local right_width = 0

        -- Calculate left content width (project name + tabs)
        local project_name = vim.fs.basename(vim.loop.cwd())
        left_width = left_width + #project_name + 2 -- Project name + spacing

        -- Add tab widths
        tabs.foreach(function(tab)
          left_width = left_width + #tab.name() + 4 -- Tab name + separators
        end)

        -- Calculate right content width (git branch + windows)
        local branch = get_git_branch()
        right_width = right_width + #branch + 2 -- Branch + spacing

        -- Add window widths
        wins.foreach(function(win)
          right_width = right_width + #win_label(win.id) + 4 -- Window label + separators
        end)

        return left_width, right_width
      end

      local function create_centered_content(left_width, right_width)
        local total_width = vim.o.columns
        local center_content = get_dynamic_content()
        local center_width = #string.format("[%d:%d]", #vim.api.nvim_list_tabpages(), #vim.api.nvim_list_wins()) + 4

        -- Calculate padding to center the content
        local total_content_width = left_width + center_width + right_width
        local available_space = total_width - total_content_width
        local left_padding = math.floor(available_space / 2)
        local right_padding = available_space - left_padding

        -- Ensure minimum padding
        left_padding = math.max(2, left_padding)
        right_padding = math.max(2, right_padding)

        return {
          { string.rep(" ", left_padding),  hl = theme.fill },
          center_content,
          { string.rep(" ", right_padding), hl = theme.fill },
        }
      end

      Tabby.setup {
        line = function(line)
          local current_tab = Tabby_Api.get_current_tab()
          local current_win = Tabby_Api.get_tab_current_win(current_tab)
          local tabs = line.tabs()
          local wins = line.wins_in_tab(line.api.get_current_tab())

          -- Calculate content widths
          local left_width, right_width = calculate_content_widths(tabs, wins)

          return {
            -- Left section with project name
            { "%<" },
            {
              { " " .. icons.ui.Neovim .. " ",                 hl = theme.head },
              { " " .. vim.fs.basename(vim.loop.cwd()) .. " ", hl = theme.head },
              line.sep("", theme.head, theme.fill),
            },
            -- Tabs section
            line.tabs().foreach(function(tab)
              local is_current = tab.id == current_tab
              local hl = is_current and theme.current_tab or theme.tab
              return {
                line.sep("", hl, theme.fill),
                { " " .. tab.name() .. " ", hl = hl },
                line.sep("", hl, theme.fill),
              }
            end),
            -- Center section with counts
            { "%=%<" },
            create_centered_content(left_width, right_width),
            { "%>" },
            -- Windows section
            line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
              local is_current = win.id == current_win
              local hl = is_current and theme.current_win or theme.win
              return {
                line.sep("", hl, theme.fill),
                { win_label(win.id, is_current), hl = hl },
                line.sep("", hl, theme.fill),
              }
            end),
            -- Right section with git branch
            {
              line.sep("", theme.tail, theme.fill),
              { get_git_branch(),              hl = theme.tail },
              { " " .. icons.GitBranch .. " ", hl = theme.tail },
            },
            { "%>" },
          }
        end,
        option = {
          tab_name = {
            name_fallback = function(tabid)
              local options = {
                "Dev",
                "Frontend",
                "Backend",
                "Terminal",
                "Services",
                "Testing",
                "Docs",
                "Help",
                "Configs",
                "Custom",
              }
              return options[tabid] or "Tab"
            end,
          },
          buf_name = { mode = "unique" },
          theme = theme,
          nerdfont = true,
        },
      }
    end,
  },
  { -- Heirline components: ready made heirline components
    "zeioth/heirline-components.nvim",
    lazy = true,
    config = function()
      local ok, heirline_components = pcall(require, "heirline-components")
      if not ok then
        return
      end
      local h_icons = require("base.utils").get_icons "heirline"
      heirline_components.setup {
        icons = h_icons,
        colors = nil,
      }
    end,
  },
  { -- Heirline: manages, statusline, winbar, and statuscolumn
    "rebelot/heirline.nvim",
    depends = { "zeioth/heirline-components.nvim" },
    event = "User BaseDefered",
    init = function()
      vim.api.nvim_set_hl(0, 'WinBar', { fg = '#FFD700', bg = 'NONE', bold = true })     -- Transparent background
      vim.api.nvim_set_hl(0, 'WinBarNC', { fg = '#808080', bg = 'NONE', italic = true }) -- For inactive
    end,
    config = function()
      local statuscolumn = require("modules.ui.heirline.statuscolumn").get_statuscolumn()
      local statusline = require("modules.ui.heirline.statusline").get_statusline()
      local winbar = require("modules.ui.heirline.winbar").get_winbar()
      local buf_types = require "modules.ui.heirline.buf_types"
      local file_types = require "modules.ui.heirline.file_types"

      local ok, heirline = pcall(require, "heirline")
      local h_ok, _ = pcall(require, "heirline-components")
      local lib = require "heirline-components.all"
      if not ok or not h_ok then
        vim.notify("Heirline is not loading", vim.log.levels.ERROR, { title = "Techdeus IDE Error" })
        return
      end

      local file_types_winbar = {}
      for i, v in ipairs(file_types) do
        file_types_winbar[i] = v
      end
      table.insert(file_types_winbar, "qf")
      table.insert(file_types_winbar, "replacer")
      -- Setting heirline up...
      lib.init.subscribe_to_events()
      heirline.load_colors(lib.hl.get_colors())
      local h_opts = {
        opts = {
          disable_winbar_cb = function(args) -- We do this to avoid showing it on the greeter.
            local is_disabled = not require("heirline-components.buffer").is_valid(args.buf)
                or lib.condition.buffer_matches({
                  buftype = buf_types,
                  filetype = file_types,
                }, args.buf)
            return is_disabled
          end,
        },
        winbar = winbar,
        statuscolumn = statuscolumn,
        statusline = statusline,
      }
      heirline.setup(h_opts)
    end,
  },
  { -- Incline: a minimal statusline
    "b0o/incline.nvim",
    event = "User BaseFile",
    init = function()
      -- Cache for highlights to avoid redundant API calls
      local highlight_cache = {}
      local function set_incline_highlights()
        vim.api.nvim_set_hl(0, "InclineNormal", { bg = "NONE", fg = "" })
        vim.api.nvim_set_hl(0, "InclineNormalNC", { bg = "NONE", fg = "" })
        highlight_cache["InclineNormal"] = { bg = "NONE", fg = "" }
        highlight_cache["InclineNormalNC"] = { bg = "NONE", fg = "" }
      end
      set_incline_highlights()
    end,
    config = function()
      local ok, incline = pcall(require, "incline")
      if not ok then
        return
      end

      incline.setup({
        debounce_threshold = {
          falling = 500, rising = 250
        },
        hide = {
          cursorline = true,
          focused_win = false,
          only_win = false
        },
        highlight = {
          groups = {
            InclineNormal = {
              default = true,
              group = "Normal"
            },
            InclineNormalNC = {
              default = true,
              group = "NormalNC"
            }
          }
        },
        ignore = {
          buftypes = "special",
          filetypes = require "modules.ui.heirline.file_types",
          floating_wins = true,
          unlisted_buffers = true,
          wintypes = function(winid, wintype)
            local zen_view = package.loaded["zen-mode.view"]
            return zen_view and zen_view.is_open() and winid ~= zen_view.win or wintype ~= ""
          end,
        },
        window = {
          zindex = 30,
          padding = { left = 1, right = 1 },
          margin = {
            vertical = { top = 0, bottom = 0 },
            horizontal = { left = 0, right = 0 },
          },
          placement = {
            vertical = "bottom",
            horizontal = "center",
          },
        },
        render = function(props)
          local helpers = require "base.utils.helpers"
          local icons = require("base.utils").get_icons "base"
          local col = require "configs.colors"
          local colors = col.colors
          local C = require("modules.ui.heirline.common")
          local bufnr = props.buf
          local modified = vim.bo[bufnr].modified
          local f_color = modified and "#7C0A02" or "#666666"
          local diff_cache = setmetatable({}, { __mode = "k" })
          -- Cache for file information
          local file_cache = setmetatable({}, { __mode = "k" })

          -- Optimized render type function with caching
          local render_type_cache = nil
          local last_render_check = 0
          local render_type = function()
            local now = vim.loop.now()
            if render_type_cache and (now - last_render_check) < 1000 then
              return render_type_cache
            end
            last_render_check = now

            local show = Global.settings.statusline["boo_incline"]
            local map = {
              file_info = function()
                return show == "file_info"
              end,
              toggle = function()
                return show == "toggle"
              end,
              window = function()
                return show == "window"
              end,
            }
            render_type_cache = map.file_info() and "file_info"
                or map.toggle() and "toggle"
                or map.window() and "window"
                or ""
            return render_type_cache
          end

          local function get_file_name(props)
            local bufnr = props.buf
            if file_cache[bufnr] then
              return file_cache[bufnr]
            end
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
            local result = filename == "" and "[No name]" or filename .. (modified and " *" or "")
            file_cache[bufnr] = result
            return result
          end

          local function get_diff(bufnr)
            if diff_cache[bufnr] then
              return diff_cache[bufnr]
            end
            local buf = vim.api.nvim_buf_get_name(bufnr)
            local ftime = vim.fn.getftime(buf)
            if ftime == -1 then
              diff_cache[bufnr] = "File never saved"
              return diff_cache[bufnr]
            end
            local diff = os.difftime(vim.fn.localtime(), ftime)
            local time_display = helpers.time_display(diff)
            local result = helpers.prettify_result(time_display, "short")
            diff_cache[bufnr] = result
            return result
          end

          -- Cache for editor type checks
          local editor_cache = setmetatable({}, { __mode = "k" })
          local function is_editor(bufnr)
            if editor_cache[bufnr] ~= nil then
              return editor_cache[bufnr]
            end
            local ft_type = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
            local result = helpers.WindowViewFiletype(ft_type, "tO") == "Editor"
            editor_cache[bufnr] = result
            return result
          end

          local function get_file_perms(buf)
            local path = vim.api.nvim_buf_get_name(buf)
            local perms = vim.fn.getfperm(path)
            local parts = C.split_permission_string(perms)
            -- Handle non-file buffers
            if path == "" then
              perms = "---------"
              return
            end
            -- Get permissions and handle errors
            if not perms or perms == "" then
              perms = "---------"
              vim.notify(string.format("No permissions found for file: %s", path), vim.log.levels.WARN)
              return
            end

            if vim.tbl_contains(Global.fts, vim.bo[0].filetype) then
              return {
                { parts[1], { " │ " }, guifg = "#ff5555" },
                { parts[2], { " │ " }, guifg = "#50fa7b" },
                { parts[3], guifg = "#bd93f9" },
              }
            end
            return ""
          end

          local window_cache = setmetatable({}, { __mode = "k" })
          local function get_window_info(props)
            local win_id = props.win
            if window_cache[win_id] then
              return window_cache[win_id]
            end

            local win_number = vim.api.nvim_win_get_number(props.win)
            local total_windows = #vim.api.nvim_list_wins()
            local ft_type = vim.api.nvim_get_option_value("filetype", {
              buf = vim.api.nvim_win_get_buf(props.win),
            })

            local result = {
              {
                helpers.WindowViewFiletype(ft_type, "tO") == "Editor" and " " or "  ",
                gui = "bold,italic",
                group = "Special",
              },
              {
                helpers.WindowViewFiletype(ft_type, "combo"),
                gui = "bold,italic",
                group = "Special",
              },
              {
                "(" .. win_number,
                group = "Special",
                gui = "italic",
              },
              {
                "/",
                group = "Special",
                gui = "italic",
              },
              {
                total_windows,
                group = "Special",
                gui = "italic",
              },
              {
                ":",
                group = "Special",
                gui = "italic",
              },
              {
                win_id .. ")",
                gui = "bold,italic",
                group = "Special",
              },
            }
            window_cache[win_id] = result
            return result
          end

          local function get_stats()
            local wc = vim.fn.wordcount()
            local mode = vim.fn.mode()
            local lines = vim.api.nvim_buf_line_count(0)

            local isVisualMode = mode:find('[vV]')

            local chars = (isVisualMode and wc.visual_chars ~= nil) and wc.visual_chars .. '/' .. wc.chars or wc.chars
            local words = (isVisualMode and wc.visual_words ~= nil) and wc.visual_words .. '/' .. wc.words or wc.words
            local lines = (isVisualMode and wc.visual_lines ~= nil) and wc.visual_lines .. '/' .. lines or lines
            return {
            { { chars, guifg = f_color }, icons.cmp.Chars .. ' ', guifg = "#bd93f9" },
            { { words, guifg = f_color }, icons.cmp.Words .. ' ', guifg = "#50fa7b" },
            { { lines, guifg = f_color }, icons.cmp.Lines .. ' ', guifg = "#ff5555" },
            }
          end

          -- Optimized feature toggle with caching
          local feature_cache = setmetatable({}, { __mode = "k" })

          local function toggle_feature(icon, label, condition, color)
            local cache_key = string.format("%s_%s_%s", icon or label, tostring(condition), color)
            if feature_cache[cache_key] then
              return feature_cache[cache_key]
            end
            local f_color = condition and color or colors.gray or "#666666"
            local result = { " " .. (icon or label), guifg = f_color }
            feature_cache[cache_key] = result
            return result
          end

          -- Batch feature updates
          local function toggle_all(buf, win)
            if not is_editor(buf) then
              return {}
            end

            local features = {
              {
                icon = icons.common.search,
                label = "SEARCH",
                condition = vim.wo[win].spell,
                color = colors.blue,
              },
              {
                icon = icons.common.lsp,
                label = "LSP",
                condition = vim.wo.wrap,
                color = colors.green,
              },
              {
                icon = icons.documents.File,
                label = "FILE",
                condition = vim.bo[buf].modifiable,
                color = colors.yellow,
              },
              {
                icon = icons.outline.String.icon,
                label = "SPELL",
                condition = vim.wo[win].spell,
                color = colors.red,
              },
              {
                icon = icons.ctrlspace.SLeft .. " " .. icons.ctrlspace.SRight,
                label = "WRAP",
                condition = vim.wo[win].wrap,
                color = colors.purple,
              },
              {
                icon = icons.outline.Constant.icon,
                label = "PIN",
                condition = require("stickybuf").is_pinned(win),
                color = colors.blue,
              },
              {
                icon = "📝",
                label = "MOD",
                condition = vim.bo[buf].modified,
                color = colors.red,
              },
            }

            local result = {}
            for _, feature in ipairs(features) do
              local content = toggle_feature(feature.icon, feature.label, feature.condition, feature.color)
              table.insert(result, content)
              table.insert(result, { " " })
            end
            return result
          end

          local stats = get_stats()
          local modified_status = { get_diff(bufnr) }
          local file_perms = { get_file_perms(bufnr) }
          local window_info = get_window_info(props)
          local toggle_content = toggle_all(bufnr, props.win)

          -- Optimized render function with caching
          local render_cache = setmetatable({}, { __mode = "k" })

          -- Clear caches periodically
          local cache_cleanup_timer = vim.loop.new_timer()
          cache_cleanup_timer:start(0, 300000, function() -- Every 5 minutes
            file_cache = setmetatable({}, { __mode = "k" })
            editor_cache = setmetatable({}, { __mode = "k" })
            feature_cache = setmetatable({}, { __mode = "k" })
            diff_cache = setmetatable({}, { __mode = "k" })
            window_cache = setmetatable({}, { __mode = "k" })
            render_cache = setmetatable({}, { __mode = "k" })
            render_type_cache = nil
          end)
          return {
            {
              { get_file_name(props), { ' ┊ ' }, guifg = f_color, gui = modified and 'bold,italic' or 'bold' },
              { file_perms, guifg = f_color, gui = modified and 'bold,italic' or 'bold' },
              { ('' or '') .. ' ', guifg = '', guibg = 'none' },
              { { '┊  ' }, modified_status, guifg = f_color, gui = "italic" },
              { ('' or '') .. ' ', guifg = '', guibg = 'none' },
              { { '┊ ' }, toggle_content },
              { { '┊ ' }, stats, guifg = f_color, gui = "italic" },
              { { '┊ ' }, vim.api.nvim_win_get_number(props.win), group = 'DevIconWindows' },
              guifg = "",
              guibg = "NONE",
            }
          }
        end
      })
    end
  }
}
--End-of-file--
