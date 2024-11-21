local F = {}
            -- vim.notify(vim.insperct(dipslay))
local show_dotfiles = true

F.files_set_cwd = function()
  local MiniFiles = require("mini.files")
  local cur_entry_path = MiniFiles.get_fs_entry().path
  local cur_directory = vim.fs.dirname(cur_entry_path)
  if cur_directory ~= nil then
    vim.fn.chdir(cur_directory)
  end
end

function F.files_set_cwd_with_path(path)
  -- Works only if cursor is on the valid file system entry
  local MiniFiles = require("mini.files")
  if path == nil then
    local cur_entry_path = MiniFiles.get_fs_entry().path
    local cur_directory = vim.fs.dirname(cur_entry_path)
    vim.fn.chdir(cur_directory)
  else
    local new_directory = vim.fs.dirname(path)
    vim.fn.chdir(new_directory)
  end
end

function F.open_config()
  local config_path = '~/.config/nvim/'
  local MiniFiles = require("mini.files")
  MiniFiles.open(config_path)
  F.files_set_cwd(config_path)
end

function F.filter_show()
  return true
end

function F.open_current()
  local minifiles = require("mini.files")
  minifiles.open(vim.api.nvim_buf_get_name(0))
  minifiles.reveal_cwd()
end

function F.filter_hide(fs_entry)
  return not vim.startswith(fs_entry.name, ".")
end

function F.toggle_dotfiles()
  local MiniFiles = require("mini.files")
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and F.filter_show or F.filter_hide
  MiniFiles.refresh({ content = { filter = new_filter } })
end

function F.map_split(buf_id, lhs, direction)
  local MiniFiles = require("mini.files")
  local rhs = function()
    local new_target_window
    vim.api.nvim_win_call(MiniFiles.get_target_window(), function()
      vim.cmd(direction .. " split")
      new_target_window = vim.api.nvim_get_current_win()
    end)
    MiniFiles.set_target_window(new_target_window)
  end
  -- Adding `desc` will result into `show_help` entries
  local desc = "Split " .. direction
  vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
end

function F.attach_file_browser(plugin_name, plugin_open)
  local previous_buffer_name
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("MiniFiles", { clear = true }),
    desc = string.format("[%s] replacement  for Netrw", plugin_name),
    pattern = "*",
    callback = function()
      vim.schedule(function()
        local buffer_name = vim.api.nvim_buf_get_name(0)
        if vim.fn.isdirectory(buffer_name) == 0 then
          _, previous_buffer_name = pcall(vim.fn.expand, "#:p:h")
          return
        end

        -- Avoid reopening when exiting without selecting a file
        if previous_buffer_name == buffer_name then
          previous_buffer_name = nil
          return
        else
          previous_buffer_name = buffer_name
        end

        -- Ensure no buffers remain with the directory name
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = 0 })
        plugin_open(vim.fn.expand("%:p:h"))
      end)
    end,
  })
end

return F
