local text = require("nui.text")
local utils = require("modules.build_me.base.utils")

local M = {}

M.input = function(default, prompt, opts)
  local default_opts = {
    relative = "cursor",
    position = {
      row = 1,
      col = 0,
    },
    size = {
      width = utils.calculate_input_width(default, prompt),
    },
    border = {
      highlight = "FloatBorder:LvimInputBorder",
      style = { " ", " ", " ", " ", " ", " ", " ", " " },
      text = {
        top = text(prompt, "LvimInputBorder"),
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:LvimInputNormal",
    },
    prompt_prefix = "➤ ",
  }
  opts = utils.merge(default_opts, opts)
  return opts
end

M.select = function(entries, stuff, opts)
  local formatted_entries = utils.format_select_entries(entries, stuff.format_item)
  local default_opts = {
    relative = "editor",
    position = "50%",
    size = {
      width = utils.calculate_select_width(formatted_entries, stuff.prompt or "Choice:"),
      height = #formatted_entries,
    },
    border = {
      highlight = "FloatBorder:LvimSelectBorder",
      style = { " ", " ", " ", " ", " ", " ", " ", " " },
      text = {
        top = text(stuff.prompt or "Choice:", "LvimSelectBorder"),
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:LvimSelectNormal",
    },
  }
  opts = utils.merge(default_opts, opts)
  return {
    opts = opts,
    formatted_entries = formatted_entries,
  }
end

M.popup = function(title, ft, opts)
  local default_opts = {
    enter = true,
    focusable = true,
    position = "50%",
    relative = "editor",
    size = {
      width = "90%",
      height = "85%",
    },
    border = {
      highlight = "FloatBorder:LvimPopupBorder",
      style = { " ", " ", " ", " ", " ", " ", " ", " " },
      text = {
        top = text(title, "LvimPopupBorder"),
        top_align = "center",
      },
    },
    buf_options = {
      filetype = ft,
    },
    win_options = {
      winhighlight = "Normal:LvimPopupNormal",
    },
  }
  opts = utils.merge(default_opts, opts)
  return opts
end

return M
