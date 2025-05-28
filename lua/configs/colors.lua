--Start-of-file--
local funcs = require('core.funcs')

local color_schemes = {}
color_schemes.__index = color_schemes

color_schemes.colors = {}
color_schemes.utils = {}
color_schemes.utils.loaded = false

function color_schemes:get_colorscheme(theme)
  if theme ~= nil then
    local ok, color_modules = pcall(require, "modules.ui.themes")
    if not ok then return end
    return color_modules:get(theme)
  end
  vim.notify(string.format('Color scheme: %s does not exist', theme), vim.log.levels.WARN, { title = 'Techdeus IDE' })
  return nil
end

function color_schemes:set_colorscheme(scheme_config)
  if scheme_config ~= nil then
    self.active_colorscheme = scheme_config
    return self.active_colorscheme
  end
  return nil
end

function color_schemes:setup_colorscheme(scheme_config)
  if scheme_config ~= nil then
    local active_color_scheme = self:set_colorscheme(scheme_config)
    return active_color_scheme
  end
  return nil
end

function color_schemes:load_color_scheme(theme, opts)
  opts = opts or { show_update = false, save_write = true, err = 'Error setting up color scheme' }
  local scheme_config = color_schemes:get_colorscheme(theme)
  Debug.log(string.format("%s color scheme is loading...", theme))
  local ok, _ = pcall(function()
    if scheme_config ~= nil then
      self:setup_colorscheme(scheme_config)
      self:activate_colorscheme_async(scheme_config.require, opts)
      return true
    end
    return false
  end)
  if not ok then
    vim.notify(opts.err or 'Error loading color scheme', vim.log.levels.ERROR, {})
  end
end

function color_schemes:launch_init_colorscheme()
  local scheme_config = require("modules.ui.themes"):active()

  -- local module_configs = require('configs.modules')
  -- local Mod = module_configs.handle_register_module(scheme_config, 'ui.themes', state, 'module')
  -- if not Mod then
  --   vim.notify('Failed to register color scheme module', vim.log.levels.ERROR)
  --   return false
  -- end
  -- local setup_ok = module_configs.handle_setup_module(Mod, state.load_count, state.failed)
  -- if setup_ok then
  --   stats.success_count = stats.success_count + 1
  --   state.loaded[Mod.base.name] = true
  -- else
  --   stats.fail_count = stats.fail_count + 1
  -- end
  color_schemes:load_color_scheme(scheme_config.require, { show_update = false, save_write = false, err = 'Error setting up color scheme' })
end


function color_schemes.get_color(hl_group, attr)
  local ok, hl = pcall(function()
    return vim.api.nvim_get_hl(0, { name = hl_group })
  end)
  if ok and hl[attr] then
    return string.format('#%06x', hl[attr])
  end
  return '#000000' -- Fallback color
end

-- Set up highlight groups
function color_schemes:setup_highlights()
  local normal = color_schemes:get_highlight('Normal')
  local constant = color_schemes:get_highlight('Constant')
  local title = color_schemes:get_highlight('Title')
  local mode_cmd_colors = color_schemes:get_highlight("MiniStatuslineModeCommand")
  local mode_insert_colors = color_schemes:get_highlight("MiniStatuslineModeInsert")
  local mode_normal_colors = color_schemes:get_highlight("MiniStatuslineModeNormal")
  local mode_other_colors = color_schemes:get_highlight("MiniStatuslineModeOther")
  local mode_replace_colors = color_schemes:get_highlight("MiniStatuslineModeReplace")
  local mode_visual_colors = color_schemes:get_highlight("MiniStatuslineModeVisual")

  vim.api.nvim_set_hl(0, 'MyTabLineText', { bg = "", fg = "#e06c75" })
  vim.api.nvim_set_hl(0, 'CopilotSuggestion', { bg = "", fg = "#555555" })
  -- Set up Tabby highlight groups
  vim.api.nvim_set_hl(0, 'TabbyFill', { bg = normal.bg })
  vim.api.nvim_set_hl(0, 'TabbyCurrentTab', {
    fg = constant.fg or '#75beff',
    bg = normal.bg or '#000000',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'TabbyCurrentWin', {
    fg = constant.fg or '#75beff',
    bg = normal.bg or '#000000',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'TabbyTab', {
    fg = normal.bg or '#000000',
    bg = constant.fg or '#75beff',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'TabbyWin', {
    fg = normal.bg or '#000000',
    bg = title.fg or '#98c379',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'TabbyHead', {
    fg = normal.bg or '#000000',
    bg = constant.fg or '#75beff',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'TabbyTail', {
    fg = normal.bg or '#000000',
    bg = title.fg or '#98c379',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'ModeCmd', {
    fg = mode_cmd_colors.fg or '#000000',
    bg = mode_cmd_colors.bg or '#98c379',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'ModeInsert', {
    fg = mode_insert_colors.fg or '#000000',
    bg = mode_insert_colors.bg or '#98c379',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'ModeNormal', {
    fg = mode_normal_colors.fg or '#000000',
    bg = mode_normal_colors.bg or '#98c379',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'ModeOther', {
    fg = mode_other_colors.fg or '#000000',
    bg = mode_other_colors.bg or '#98c379',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'ModeReplace', {
    fg = mode_replace_colors.fg or '#000000',
    bg = mode_replace_colors.bg or '#98c379',
    italic = true
  })
  vim.api.nvim_set_hl(0, 'ModeVisual', {
    fg = mode_visual_colors.fg or '#000000',
    bg = mode_visual_colors.bg or '#98c379',
    italic = true
  })
end

function color_schemes:rgb(c)
  c = string.lower(c)
  return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

-- Replace existing get_highlight function
function color_schemes:get_highlight(hl_group)
  -- Add pcall for error handling
  local ok, hl_details = pcall(function()
    -- Correct API usage with named parameter
    return vim.api.nvim_get_hl(0, { name = hl_group })
  end)

  -- Default colors for fallback
  local default_colors = { bg = nil, fg = nil }

  -- Return early if error
  if not ok then
    vim.notify("Failed to get highlight: " .. hl_group, vim.log.levels.WARN)
    return default_colors
  end

  -- Convert colors to hex format if they exist
  local bg_color = hl_details.bg and string.format('#%06x', hl_details.bg) or nil
  local fg_color = hl_details.fg and string.format('#%06x', hl_details.fg) or nil

  return {
    bg = bg_color,
    fg = fg_color
  }
end

function color_schemes:activate_colorscheme(colortheme, opts)
  local save_write = opts.save_write or false
  local user_choice = string.lower(colortheme)
  Global.settings.theme = user_choice
  if not pcall(vim.cmd.colorscheme, user_choice) then
    vim.notify(
      string.format('Error activating colorscheme: %s', user_choice),
      vim.log.levels.ERROR,
      { title = 'TECHDEUS IDE' }
    )
    return
  end
  Debug.log("Color scheme loaded: " .. user_choice)
  if save_write then
    local settings_file_path = Global.settings_path
    funcs.write_file(settings_file_path, Global.settings)
    Debug.notify(string.format("File Written to %s with theme %s", settings_file_path, user_choice))
  end
end

function color_schemes:activate_colorscheme_async(colortheme, opts)
  local async_time = opts.async_time or 10
  local user_choice = string.lower(colortheme)
  vim.defer_fn(function()
    Global.settings.theme = user_choice
    if not pcall(vim.cmd.colorscheme, user_choice) then
      vim.notify(
        string.format('Error activating colorscheme: %s', user_choice),
        vim.log.levels.ERROR,
        { title = 'TECHDEUS IDE' }
      )
      return
    end
    Debug.log("Color scheme loaded: " .. user_choice)
    if opts.show_update then
      vim.notify(string.format('ColorScheme is: %s!', user_choice), vim.log.levels.INFO, { title = 'TECHDEUS IDE' })
    end
    if opts.save_write then
      local fl_settings = vim.deepcopy(Global.settings)
      local file_path = Global.settings_path
      funcs.write_file(file_path, fl_settings)
      vim.notify(string.format('File Written to %s with theme %s', file_path, colortheme))
    end
  end, async_time)
end

function color_schemes:update_global_settings_theme(cs)
  vim.defer_fn(function()
    Global.settings.theme = cs
    local f_settings = vim.deepcopy(Global.settings)
    local success, err = pcall(require('core.funcs').write_file, Global.settings_path, f_settings)
    if not success then
      funcs.notify('Error writing settings file: ' .. tostring(err), vim.log.levels.ERROR)
    else
      funcs.notify('Settings file written successfully', vim.log.levels.INFO)
    end
  end, 50)
end

function color_schemes:get_highlight_color(group, attr)
  -- attr should be 'fg' or 'bg'
  local hl = vim.api.nvim_get_hl(0, { name = group })

  if not hl then
    return nil
  end

  local color = hl[attr]
  if color then
    -- Convert number to hex string
    return string.format('#%06x', color)
  end

  return nil
end

local function blend(foreground, alpha, background)
  alpha = type(alpha) == 'string' and (tonumber(alpha, 16) / 0xff) or alpha
  local bg = color_schemes:rgb(background)
  local fg = color_schemes:rgb(foreground)

  local blendChannel = function(i)
    local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format('#%02x%02x%02x', blendChannel(1), blendChannel(2), blendChannel(3))
end

function color_schemes:load()
  self.colors.themes = { 'ashen', 'e-ink', 'everforest', 'mies', 'neodarcula', 'okcolors', 'shadow', 'yang', 'yin' }

  if Global.settings ~= nil and Global.settings.theme ~= nil then
    self.active_colorscheme = self:get_colorscheme(Global.settings.theme)
  end

  return self
end

function color_schemes:load_colors()
  self.colors.color_base = color_schemes:get_highlight('Normal')
  self.colors.bg = self.colors.color_base.bg
  self.colors.bg_dark = blend(self.colors.bg, 0.8, '#000000')
  self.colors.bg_float = blend(self.colors.color_base.bg, 0.7, '#000000')
  self.colors.fg = self.colors.color_base.fg
  self.colors.green = color_schemes:get_highlight('Group').fg
  self.colors.red = "#e5e5e5"
  self.colors.blue = "#75beff"
  self.colors.orange = "#e5a72a"
  self.colors.purple = color_schemes:get_highlight('Statement').fg
  self.colors.cyan = color_schemes:get_highlight('Special').fg
  self.colors.yellow = blend(self.colors.orange, 0.8, '#ffffff')
  self.colors.mode_cmd_colors = color_schemes:get_color("MiniStatuslineModeCommand", "fg")
  self.colors.mode_insert_colors = color_schemes:get_color("MiniStatuslineModeInsert", "fg")
  self.colors.mode_normal_colors = color_schemes:get_color("MiniStatuslineModeNormal", "fg")
  self.colors.mode_other_colors = color_schemes:get_color("MiniStatuslineModeOther", "fg")
  self.colors.mode_replace_colors = color_schemes:get_color("MiniStatuslineModeReplace", "fg")
  self.colors.mode_visual_colors = color_schemes:get_color("MiniStatuslineModeVisual", "fg")

  return self
end

vim.api.nvim_create_user_command('LoadColorScheme', function(opts)
  color_schemes:load_color_scheme(opts.fargs[1])
  -- require("modules").launch_color_scheme(opts.fargs[1], opts.fargs[2] == 'true')
end, {
  nargs = '*',
})


-- vim.api.nvim_create_autocmd('ColorScheme', {
--   pattern = '*',
--   callback = function()
--     require("configs.colors").clear_highlight_cache()
--   end
-- })
return color_schemes
--End-of-file--
