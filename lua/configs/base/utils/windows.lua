local W = {}
local to_preview = true
local winwidth = 50
local max_number = 3

function W.Get_all_active_win_config_info()
  local win_number = vim.api.nvim_get_current_win()
  local v = vim.wo[win_number]
  local all_options = vim.api.nvim_get_all_options_info()
  local result = ""
  for key, val in pairs(all_options) do
    if val.global_local == false and val.scope == "win" then
      result = result .. "|" .. key .. "=" .. tostring(v[key] or "<not set>")
    end
  end
  return result
end

vim.api.nvim_create_user_command("ActiveWinConfigInfo", function()
  local win_info = W.Get_all_active_win_config_info()
  return win_info
end, {})

function W.set_win_pin_type(window, filetype)
  _G.winpintype[window] = filetype
  vim.schedule(function()
    vim.notify(string.format("%s is set on window %d", filetype, window), vim.log.levels.INFO,
      { title = "Techdeus Update" })
  end)
  return filetype
end

function W.get_win_pin_type(window) return _G.winpintype[window] end

function W.window_config_files()
  local width_nofocus = math.floor(winwidth / 3)
  local width_preview = math.floor(winwidth * 2)
  local width_focus = winwidth

  local cur_width = vim.fn.winwidth(0)
  local half = math.floor((winwidth + (math.huge - winwidth) / 2) + 0.4)
  if cur_width == winwidth then
    width_focus = half
  elseif cur_width == half then
    width_focus = max_number
  else
    width_focus = winwidth
  end

  return {
    width_focus = width_focus,
    width_nofocus = width_nofocus,
    width_preview = width_preview,
    preview = to_preview,
    max_number = max_number,
  }
end

function W.win_config_notification()
  local has_statusline = vim.o.laststatus > 0
  local bottom_space = vim.o.cmdheight + (has_statusline and 2 or 1)
  return {
    border = "none",
    relative = "editor",
    zindex = 200,
    anchor = "SE",
    col = vim.o.columns,
    row = vim.o.lines - bottom_space,
  }
end

function W.swap_windows()
  local window = require("picker").pick_window({
    include_current_win = false,
  })
  if window ~= nil then
    local target_buffer = vim.fn.winbufnr(window)
    -- Set the target window to contain current buffer
    vim.api.nvim_win_set_buf(window, 0)
    -- Set current window to contain target buffer
    vim.api.nvim_win_set_buf(0, target_buffer)
  end
end

W.win_config_picker_center = function()
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
W.win_config_picker_help = function()
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
W.win_config_picker_selector = function()
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

function W.create_color_scheme_picker()
  local color_schemes = vim.fn.getcompletion("", "color")
  table.sort(color_schemes)

  local choose = function(item)
    if not item then return end
    pcall(vim.cmd, "colorscheme " .. item)
  end
  local preview = function(item)
    if not item then return end
    pcall(vim.cmd, "colorscheme " .. item)
  end

  local source = {
    items = color_schemes,
    name = "Color Schemes",
    preview = preview,
    choose = choose,
  }

  local mappings = {
    preview = {
      char = "<C-p>",
      func = function()
        local item = require("mini.pick").get_picker_matches()
        pcall(vim.cmd, "colorscheme " .. item.current)
      end,
    },
  }
  local opts = { source = source, mappings = mappings }
  return opts
end

function W.add_color_scheme_picker()
  local MiniPick = require("mini.pick")

  MiniPick.registry.colorschemes = function()
    local opts = W.create_color_scheme_picker()
    local init_scheme = vim.g.colors_name
    local ColorSchemePicker = MiniPick.start(opts)

    if ColorSchemePicker == nil then
      pcall(vim.cmd, "colorscheme " .. init_scheme)
      return
    end
    return MiniPick.registry[ColorSchemePicker]
  end
end

function W.modify_help_picker()
  local MiniPick = require("mini.pick")
  MiniPick.registry.help = function()
    return MiniPick.builtin.help({}, { window = { config = W.win_config_picker_help } })
  end
end

return W
