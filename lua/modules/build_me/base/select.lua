local select = require("nui.menu")
local event = require("nui.utils.autocmd").event
local reference = nil

local function nui_select(opts, on_choice)
  local userChoice = function(choiceIndex)
    on_choice(choiceIndex["text"])
  end
  reference = select(opts.opts, {
    lines = opts.formatted_entries,
    on_close = function()
      reference = nil
    end,
    on_submit = function(item)
      userChoice(item)
      reference = nil
    end,
  })
  pcall(function()
    reference:mount()
    reference:on(event.BufLeave, reference.menu_props.on_close, { once = true })
  end)
end

return nui_select
