local custom_input = require("nui.input")
local event = require("nui.utils.autocmd").event
local reference = nil

local function nui_input(opts, on_send)
  reference = custom_input(opts, {
    prompt = opts.prompt_prefix,
    default_value = opts.default,
    on_close = function()
      reference = nil
    end,
    on_submit = function(value)
      on_send(value)
      reference = nil
    end,
  })
  pcall(function()
    reference:mount()
    reference:map("n", "<esc>", reference.input_props.on_close, { noremap = true })
    reference:map("n", "q", reference.input_props.on_close, { noremap = true })
    reference:map("i", "<esc>", reference.input_props.on_close, { noremap = true })
    reference:on(event.BufLeave, reference.input_props.on_close, { once = true })
  end)
end

return nui_input
