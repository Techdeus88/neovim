local popup = require("nui.popup")
local notify = require("modules.build_me.base.notify")
local utils = require("modules.build_me.base.utils")
local event = require("nui.utils.autocmd").event
local reference = nil

local function nui_popup(opts, file, readonly, close_key)
  if not utils.file_exists(file) then
    notify.error("This file does not exist", {
      title = "LVIM UI",
    })
    return
  end
  reference = popup(opts)
  pcall(function()
    reference:mount()
    local lines = utils.readlines(file)
    vim.api.nvim_buf_set_lines(reference.bufnr, 0, 1, false, lines)
    if readonly then
      vim.fn.setbufvar(reference.bufnr, "&modifiable", 0)
      vim.fn.setbufvar(reference.bufnr, "&readonly", 1)
    end
    if close_key then
      reference:map("n", close_key, function()
        reference:unmount()
      end, { noremap = true })
    end
    reference:on(event.WinLeave, function()
      reference:unmount()
    end)
  end)
end

return nui_popup
