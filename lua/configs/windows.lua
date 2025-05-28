local W = {}

--Start-of-file--
local W = {}

function W.calculate_dynamic_width(content, max_width_percentage)
  local max_width = 0
  for _, line in ipairs(content) do
    local line_width = vim.fn.strdisplaywidth(line)
    max_width = math.max(max_width, line_width)
  end

  -- Limit the width to a percentage of the screen width
  local screen_width = vim.o.columns
  local max_allowed_width = math.floor(screen_width * (max_width_percentage or 0.5))
  return math.min(max_width, max_allowed_width)
end

function W.open_dynamic_window(content)
  local buf = vim.api.nvim_create_buf(false, true) -- Create a scratch buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  local win_width = W.calculate_dynamic_width(content, 0.5) -- 80% of screen width
  local win_height = #content + 2 -- Add padding for borders

  local win = vim.api.nvim_open_win(buf, false, {
    split = 'right',
    width = win_width,
    height = win_height,
    row = math.floor((vim.o.lines - win_height) / 2),
    col = math.floor((vim.o.columns - win_width) / 2),
    style = "minimal",
    border = "rounded",
  })

  -- Set window options
  vim.api.nvim_win_set_option(win, "signcolumn", "no")
  vim.api.nvim_win_set_option(win, "number", false)
  vim.api.nvim_win_set_option(win, "relativenumber", false)
  vim.api.nvim_win_set_option(win, "cursorline", false)
  vim.api.nvim_win_set_option(win, "colorcolumn", "")
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_win_set_option(win, "textwidth", 0)

  return win, buf
end

function W.split_vertically()
    local cmd = function()
        if vim.bo.buftype == "terminal" then
            local Terminal = require("toggleterm.terminal").Terminal
            Terminal:new({}):toggle()
        else
            vim.cmd("rightbelow vsplit")
        end
    end
    vim.keymap.set("n", "<leader>wl", cmd)
    vim.api.nvim_create_user_command("SplitVertically", cmd, {})
end

function W.split_horizontally()
    local cmd = "split"
    vim.api.nvim_create_user_command("SplitHorizontally", cmd, {})
end

function W.close_window_or_buffer()
    local closeWindowOrBuffer = function()
        local isOk, _ = pcall(vim.cmd, "close")

        if not isOk then
            vim.cmd("bd")
        end
    end
    vim.keymap.set("n", "<M-w>", closeWindowOrBuffer)
end

function W.maximize_windows()
    require("base.utils.editor").window.close_all_other_windows({
        "filesystem", -- neo-tree
        "Trouble",
        "term",
    })
end

W.popup_window = {
  cmd = function()
    local api = vim.api

    local buf = api.nvim_create_buf(false, true)

    local opts = {
      style = "minimal",
      relative = "editor",
      height = api.nvim_get_option("lines") - 2,
      width = api.nvim_get_option("columns") - 3,
      title = "Popup",
      row = 2,
      col = 3,
      border = "rounded",
      zindex = 20,
    }

    -- Create the floating window with the current buffer
    api.nvim_open_win(buf, true, opts)

    -- Set the buffer's modifiable option to true
    api.nvim_buf_set_option(buf, "modifiable", true)
  end,
  actions = function(cmd)
    vim.api.nvim_create_user_command("PopupWindow", cmd, {})
  end,
}
W.popup_window.actions(W.popup_window.cmd)

W.open_in_popup_window = {
  cmd = function()
    W.popup_window.cmd()
    require("snacks.picker").extensions.smart_open.smart_open({
      cwd_only = true,
      filename_first = false,
    })
  end,
  actions = function(cmd)
    vim.api.nvim_create_user_command("OpenInPopupWindow", cmd, {})
  end,
}
function W.maximize_windows_all()
    local cmd = function()
        require("base.utils.editor").window.close_all_other_windows({})
    end
    vim.keymap.set("n", "<leader>wO", cmd)
end

function W.maximize_windows_as_popup()
    local cmd = function()
        local api = vim.api

        -- Get the current buffer
        local current_buf = api.nvim_get_current_buf()

        -- Get the editor's dimensions
        local win_width = api.nvim_get_option("columns")
        local win_height = api.nvim_get_option("lines")

        -- Define the floating window options
        local opts = {
            style = "minimal",
            relative = "editor",
            height = win_height - 2,
            width = win_width - 3,
            row = 2,
            col = 3,
            border = "rounded",
        }

        -- Create the floating window with the current buffer
        api.nvim_open_win(current_buf, true, opts)

        -- Set the buffer's modifiable option to true
        api.nvim_buf_set_option(current_buf, "modifiable", true)
    end
    vim.keymap.set("n", "<leader>wp", cmd)
    vim.api.nvim_create_user_command("MaxmiseWindowsAsPopup", cmd, {})
end

function W.resize_window()
    vim.keymap.set("n", "<C-M-l>", "<cmd>vertical resize +5<cr>", { desc = "Increase window width" })
    vim.keymap.set("n", "<C-M-h>", "<cmd>vertical resize -5<cr>", { desc = "Decrease window width" })
    vim.keymap.set("n", "<C-M-j>", "<cmd>resize -5<cr>", { desc = "Increase window height" })
    vim.keymap.set("n", "<C-M-k>", "<cmd>resize +5<cr>", { desc = "Decrease window height" })
end

function W.win_config_picker_center()
  local height = math.floor(0.618 * vim.o.lines)
  local width = math.floor(0.618 * vim.o.columns)
  return {
    anchor = "NW",
    height = height,
    width = width,
    border = "rounded",
    row = math.floor(0.5 * (vim.o.lines - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
  }
end

function W.win_config_picker_help()
  return {
    height = 20,
    width = 40,
    anchor = "SE",
    row = vim.o.lines,
    col = vim.o.columns,
    border = "rounded",
    relative = "editor",
  }
end

function W.win_config_picker_selector()
  local height = 10
  local width = vim.o.columns

  return {
    anchor = "NE",
    height = height,
    width = width,
    border = "rounded",
    relative = "cursor",
    type = "float",
    position = { 0, -2 },
    zindex = 200,
  }
end

function W.modify_help_picker()
  local MiniPick = require('mini.pick')
  MiniPick.registry.help = function()
    return MiniPick.builtin.help({}, { window = { config = W.win_config_picker_help } })
  end
end

return W
