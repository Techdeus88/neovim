--Start-of-file--
local has_git = vim.fn.executable('git') == 1

local function get_current_directory(state)
  local node = state.tree:get_node()
  if node.type ~= 'directory' or not node:is_expanded() then
    node = state.tree:get_node(node:get_parent_id())
  end
  return node:get_id()
end

return { -- Core modules ~7~
  {      -- NEO Tree: primary file manager
    'nvim-neo-tree/neo-tree.nvim',
    event = "User BaseDefered",
    depends = { 
      
      "MunifTanjim/nui.nvim" },
    checkout = 'v3.x',
    keys = {
      { '<leader>ee', '<leader>fe', desc = 'Explorer Tree (Root Dir)', remap = true },
      { '<leader>eE', '<leader>fE', desc = 'Explorer Tree (cwd)',      remap = true },
      {
        '<leader>ea',
        function()
          require('neo-tree.command').execute({ reveal = true, dir = vim.uv.cwd() })
        end,
        desc = 'Reveal in Explorer (cwd)',
      },
    },
    opts = {
      enable_git_status = has_git,
      close_if_last_window = true,
      popup_border_style = 'rounded',
      sort_case_insensitive = true,

      source_selector = {
        winbar = false,
        show_scrolled_off_parent_node = true,
        padding = { left = 1, right = 0 },
        sources = {
          { source = 'filesystem', display_name = '  Files' }, --      
          { source = 'buffers', display_name = '  Buffers' }, --      
          { source = 'git_status', display_name = ' 󰊢 Git' }, -- 󰊢      
        },
      },

      event_handlers = {
        -- Close neo-tree when opening a file.
        {
          event = 'file_opened',
          handler = function()
            require('neo-tree').close_all()
          end,
        },
      },

      default_component_configs = {
        indent = {
          with_expanders = false,
        },
        icon = {
          folder_empty = '',
          folder_empty_open = '',
          default = '',
        },
        modified = {
          symbol = '•',
        },
        name = {
          trailing_slash = true,
          highlight_opened_files = true,
          use_git_status_colors = false,
        },
        git_status = {
          symbols = {
            -- Change type
            added = 'A',
            deleted = 'D',
            modified = 'M',
            renamed = 'R',
            -- Status type
            untracked = 'U',
            ignored = 'I',
            unstaged = '',
            staged = 'S',
            conflict = 'C',
          },
        },
      },

      window = {
        width = 30, -- Default 40
        mappings = {
          ['q'] = 'close_window',
          ['?'] = 'noop',
          ['g?'] = 'show_help',
          ['<leader>'] = 'noop',

          -- Clear filter, preview and highlight search.
          ['<Esc>'] = function(state)
            require('neo-tree.sources.filesystem').reset_search(state, true)
            require('neo-tree.sources.filesystem.lib.filter_external').cancel()
            require('neo-tree.sources.common.preview').hide()
            vim.cmd([[ nohlsearch ]])
          end,

          ['<2-LeftMouse>'] = 'open',
          ['<CR>'] = 'open_with_window_picker',
          ['l'] = function(state)
            -- Toggle directories or nested items.
            local node = state.tree:get_node()
            if
                node.type == 'directory'
                or (node:has_children() and not node:is_expanded())
            then
              state.commands.toggle_node(state)
            else
              state.commands.open(state)
            end
          end,
          ['h'] = 'close_node',
          ['C'] = 'close_node',
          ['z'] = 'close_all_nodes',
          ['<C-r>'] = 'refresh',

          ['s'] = 'noop',
          ['sv'] = 'open_split',
          ['sg'] = 'open_vsplit',
          ['st'] = 'open_tabnew',

          ['<S-Tab>'] = 'prev_source',
          ['<Tab>'] = 'next_source',

          ['dd'] = 'delete',
          ['c'] = { 'copy', config = { show_path = 'relative' } },
          ['m'] = { 'move', config = { show_path = 'relative' } },
          ['a'] = { 'add', nowait = true, config = { show_path = 'relative' } },
          ['N'] = { 'add_directory', config = { show_path = 'relative' } },

          ['P'] = 'paste_from_clipboard',

          ['K'] = { 'preview', config = { use_float = true } },
          ['p'] = {
            'toggle_preview',
            config = { use_float = true },
          },

          -- Custom commands

          ['w'] = function(state)
            local normal = state.window.width
            local large = normal * 1.9
            local small = math.floor(normal / 1.6)
            local cur_width = state.win_width
            local new_width = normal
            if cur_width > normal then
              new_width = small
            elseif cur_width == normal then
              new_width = large
            end
            vim.cmd(new_width .. ' wincmd |')
          end,

          ['Y'] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg('+', path, 'c')
            end,
            desc = 'Copy Path to Clipboard',
          },

          ['O'] = {
            function(state)
              require("neotree").open(
                state.tree:get_node().path,
                { system = true }
              )
            end,
            desc = 'Open with System Application',
          },
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = false },
        find_by_full_path_words = true,
        group_empty_dirs = true,
        use_libuv_file_watcher = has_git,
        window = {
          mappings = {
            ['d'] = 'noop',
            ['/'] = 'noop',
            ['f'] = 'filter_on_submit',
            ['F'] = 'fuzzy_finder',
            ['<C-c>'] = 'clear_filter',

            -- Find file in path.
            ['gf'] = function(state)
              require("mini.pick")('files', { cwd = get_current_directory(state) })()
            end,

            -- Live grep in path.
            ['gr'] = function(state)
              require("mini.pick")('live_grep', { cwd = get_current_directory(state) })()
            end,

            -- Search and replace in path.
            ['gz'] = function(state)
              local prefills = {
                paths = vim.fn.fnameescape(get_current_directory(state)),
              }
              local grug_far = require('grug-far')
              if not grug_far.has_instance('explorer') then
                grug_far.open({ instanceName = 'explorer' })
              else
                grug_far.open_instance('explorer')
              end
              -- Doing it seperately because multiple paths isn't supported when passed
              -- with prefills update, without clearing search and other fields.
              grug_far.update_instance_prefills('explorer', prefills, false)
            end,
          },
        },

        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            '.git',
            '.hg',
            '.svc',
            '.DS_Store',
            'thumbs.db',
            '.sass-cache',
            'node_modules',
            '.pytest_cache',
            '.mypy_cache',
            '__pycache__',
            '.stfolder',
            '.stversions',
          },
          never_show_by_pattern = {
            'vite.config.js.timestamp-*',
          },
        },
      },
      buffers = {
        window = {
          mappings = {
            ['dd'] = 'buffer_delete',
          },
        },
      },
      git_status = {
        window = {
          mappings = {
            ['d'] = 'noop',
            ['dd'] = 'delete',
          },
        },
      },
      document_symbols = {
        follow_cursor = true,
        window = {
          mappings = {
            ['/'] = 'noop',
            ['F'] = 'filter',
          },
        },
      },
    },
    config = function(_, opts)
      local ok, neotree = pcall(require, "neotree")
      if not ok then return end
      neotree.setup(opts)
    end,
  },
  { -- Which-key: manage keymaps and use a nice UI to display them
    'folke/which-key.nvim',
    lazy = false,
    require = 'which-key',
    opts = {
      preset = 'helix',
    },
    config = function(_, opts)
      local which_key_ok, which_key = pcall(require, 'which-key')
      if not which_key_ok then
        vim.notify('Which-key not found', vim.log.levels.ERROR)
        return
      end

      which_key.setup(opts)
      which_key.add({
        { '<leader>a', group = 'AI' },
        { '<leader>b', group = 'Buffer' },
        { '<leader>c', group = 'Code' },
        { '<leader>d', group = 'Debug' },
        { '<leader>e', group = 'Edit' },
        { '<leader>f', group = 'Fuzzy Find' },
        { '<leader>g', group = 'Git/lsp' },
        { '<leader>l', group = 'LSP' },
        { '<leader>o', group = 'Open' },
        { '<leader>q', group = 'Quickfix' },
        { '<leader>s', group = 'Snacks/Search' },
        { '<leader>t', group = 'Toggle' },
        { '<leader>w', group = 'Window' },
        { '<leader>y', group = 'Other' },
      })
    end,
  },
  { -- Noice: advanced command bar
    'folke/noice.nvim',
    event = "User BaseDefered",
    require = 'noice',
    opts = {
      messages = nil,
      notify = {
        enabled = false,
      },
      cmdline = {
        enabled = true,
        view = 'cmdline_popup',
        relative = 'editor',
        format = {
          -- Customize the command line format
          cmdline = { icon = '󰞷', icon_hl_group = 'NoiceCmdlineIcon' },
          search_down = { icon = '󰍉', icon_hl_group = 'NoiceCmdlineIcon' },
          search_up = { icon = '󰍉', icon_hl_group = 'NoiceCmdlineIcon' },
          filter = { icon = '󰈲', icon_hl_group = 'NoiceCmdlineIcon' },
          lua = { icon = '󰢱', icon_hl_group = 'NoiceCmdlineIcon' },
          help = { icon = '󰋖', icon_hl_group = 'NoiceCmdlineIcon' },
          input = { icon = '󰞷', icon_hl_group = 'NoiceCmdlineIcon' },
        },
        position = {
          -- Adjust to position from top
          row = function()
            -- Ensure cmdline doesn't overlap with incline
            local has_incline = require('base.utils').is_available['incline']
            local tabline_height = vim.o.showtabline > 0 and 1 or 0
            local winbar_height = vim.o.showtabline > 0 and 1 or 0
            local incline_height = has_incline and 1 or 0 -- Assuming incline takes 3 rows
            -- return 1 + incline_height + winbar_height + tabline_height -- Position below incline
            return '50%'
          end,
          col = '50%', -- Center horizontally
        },
        size = {
          width = '40%',   -- Width of command line window
          height = 5, -- Automatic height
        },
      },
      views = {
        cmdline_popup = {
          border = {
            style = "none",
            padding = { 0, 1 },
          },
          filter_options = {},
          win_options = {
            winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
          },
          relative = 'editor', -- Ensure relative is set here too
          position = {
            row = '2',
            col = '50%',
          },
        },
      },
      lsp = {
        progress = {
          enabled = false,
          format = 'lsp_progress',
          format_done = 'lsp_progress_done',
          throttle = 1000 / 30,
          view = 'notify',
        },
        override = {
          -- ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
          -- ["vim.lsp.util.stylize_markdown"] = true,
          ['vim.lsp.util.stylize_markdown'] = false,
          ['cmp.entry.get_documentation'] = true,
        },
        hover = {
          enabled = false,
          view = nil,
          opts = {},
        },
        signature = {
          enabled = false,
          auto_open = {
            enabled = true,
            trigger = true,
            luasnip = true,
            throttle = 50,
          },
          view = nil,
          opts = {},
        },
        message = {
          enabled = true,
          view = 'notify',
          opts = {},
        },
        documentation = {
          view = 'hover',
          opts = {
            lang = 'markdown',
            replace = true,
            render = 'plain',
            format = { '{message}' },
            win_options = { concealcursor = 'n', conceallevel = 3 },
          },
        },
      },
    },
    config = function(_, opts)
      local noice_ok, noice = pcall(require, 'noice')
      if not noice_ok then
        vim.notify('Noice not found', vim.log.levels.ERROR)
        return
      end
      noice.setup(opts)
    end,
  },
  { -- Screenkey: show keys as you type
    'NStefan002/screenkey.nvim',
    event = "User BaseDefered",
    require = 'screenkey',
    keys = {
      { '<leader>sK', '<cmd>ScreenkeyToggle<cr>', desc = 'Toggle Screenkey' },
    },
    config = function()
      local key_ok, screenkey = pcall(require, 'screenkey')
      if not key_ok then
        vim.notify('screenkey not found', vim.log.levels.ERROR)
        return
      end
      vim.g.screenkey_statusline_component = true
      screenkey.setup({})
    end,
  },
  { -- Bookmarks: nvim plugin to manage bookmark
    'tomasky/bookmarks.nvim',
    event = "User BaseDefered",
    require = 'bookmarks',
    opts = {},
  },
  { -- FZF: lua
    'ibhagwan/fzf-lua',
    lazy = true,
    require = 'fzf-lua',
    opts = {},
  },
}
--End-of-file--
