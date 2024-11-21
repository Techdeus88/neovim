local E = {}

-- Helper function to get visual selection
function E.get_visual_selection()
  -- Get the start and end positions
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  
  -- Debug prints
  print("Start position:", vim.inspect(start_pos))
  print("End position:", vim.inspect(end_pos))
  
  -- Get the lines in the range
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2]-1, end_pos[2], false)
  print("Lines:", vim.inspect(lines))

  if #lines == 0 then
    return ''
  end

  -- Handle single line selection
  if #lines == 1 then
    local result = string.sub(lines[1], start_pos[3], end_pos[3])
    print("Single line result:", result)
    return result
  end

  -- Handle multi-line selection
  lines[1] = string.sub(lines[1], start_pos[3])
  lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  local result = table.concat(lines, '\n')
  print("Multi-line result:", result)
  return result
end

function E.create_buffer()
    local buf = vim.api.nvim_create_buf(false, true)
    return buf
end

function E.InsertAllText(text, buf)
    local lines = vim.split(text, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

function E.InsertText(text, buf)
  -- Guard against nil or empty text
  if not text or text == '' then
    return
  end

  local lines = vim.split(text, "\n")
  vim.notify(vim.inspect(lines), vim.log.levels.INFO)
  -- Set all lines in the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end


function E.OpenBufferInSplit(buf)
  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()

  vim.api.nvim_win_set_buf(win, buf)
  return { win = win }
end

function E.SetWinBufOptions(win, content_buf)
  -- Set buffer options
  vim.bo[content_buf].filetype = 'lua'  -- or whatever filetype you want
  vim.bo[content_buf].syntax = 'on'
  vim.bo[content_buf].expandtab = true
  vim.bo[content_buf].shiftwidth = 2
  vim.bo[content_buf].tabstop = 2
  -- Set window options
  -- local win = vim.api.nvim_get_current_win()
  vim.wo[win].number = true
  vim.wo[win].relativenumber = true
  vim.wo[win].wrap = false
  vim.wo[win].signcolumn = 'yes'
  -- Enable treesitter
  vim.cmd([[TSBufEnable highlight]])
end

function E.OpenDetourBufferInSplit(buf, add_split)
  local win_remove_buf = nil
  if add_split then
    local result = vim.cmd("vsplit")
    local win_remove_buf = vim.api.nvim_get_current_win()
  end
  local Detour = add_split and "DetourCUrrentWindow" or "Detour"
  vim.cmd(Detour)
  local win_after_detour = vim.api.nvim_get_current_win()

  vim.api.nvim_win_set_buf(win_after_detour, buf)
  return { win_to_del = add_split and win_remove_buf or nil, win = win_after_detour }
end

 function E.EditVisual()
  -- Check if we're in visual mode
  local mode = vim.api.nvim_get_mode().mode
  -- Ensure we're getting the selection while still in visual mode
  vim.cmd('noau normal! "vy"')  -- Yank the selection without triggering autocommands
  local text = vim.fn.getreg('v')  -- Get the contents of register 'v'
  
  if not text or text == '' then
    vim.notify("No text selected!", vim.log.levels.WARN)
    return false
  end
  
  local buffer = E.create_buffer()
  local w = E.OpenDetourBufferInSplit(buffer, false)
  local win = w.win
  E.SetWinBufOptions(win, buffer)
  E.InsertText(text, buffer)
  return true
end

function E.EditEntireFile()
  -- Store the original buffer and window
  local original_buf = vim.api.nvim_get_current_buf()
  local original_win = vim.api.nvim_get_current_win()
  
  -- Copy file contents
  local text = table.concat(
    vim.api.nvim_buf_get_lines(original_buf, 0, -1, false),
    '\n'
  )

  -- Create new empty buffer for the background
  local empty_buf = E.create_buffer()
  -- Create buffer for the content and open in detour
  local content_buf = E.create_buffer()
  -- Open Detour Window Popup & add the buffer to it; return the window that is created when we call vsplit.
  local w = E.OpenDetourBufferInSplit(content_buf)
  -- local win = w.win
  local win_to_del = w.win_to_del
  local content_win = w.win

  -- Insert the text into the buffer
  E.SetWinBufOptions(content_win, content_buf)
  E.InsertAllText(text, content_buf)
  -- Set the empty buffer in the window used to mount Detour window
  vim.api.nvim_win_set_buf(win_to_del, empty_buf)


  return true
end

function E.ClearBuffer(buf_id)
  -- If no buffer_id is provided, use current buffer (0)
  buf_id = buf_id or 0

  -- Method 1: Set lines to empty
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, {})

  -- Method 2: Alternative using set_text
  -- vim.api.nvim_buf_set_text(buf_id, 0, 0, -1, -1, {})
end

return E

