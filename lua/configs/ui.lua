local U = {}
--- Splits content into two sections: left-aligned and right-aligned.
-- @param buf number: The buffer to set the content in.
-- @param left_content string: The content to align to the left.
-- @param right_content string: The content to align to the right.
function U.split_content(buf, left_content, right_content)
  -- Get the width of the current window
  local win_width = vim.api.nvim_win_get_width(0)

  -- Calculate the display width of the left and right content
  local left_width = vim.fn.strdisplaywidth(left_content)
  local right_width = vim.fn.strdisplaywidth(right_content)

  -- Ensure the content fits within the window
  if left_width + right_width > win_width then
    vim.notify('Content is too wide to fit in the window', vim.log.levels.ERROR)
    return
  end

  -- Calculate the padding between the left and right content
  local padding = win_width - left_width - right_width
  local spacer = string.rep(' ', padding)

  -- Combine the left content, spacer, and right content
  local line = left_content .. spacer .. right_content

  -- Set the line in the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { line })
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'readonly', true)
end

function U.Rename_tab(tabname)
  local select = require('configs.select').build_select
  -- Predefined options
  local tab_name_items = {
    'Dev',
    'Frontend',
    'Backend',
    'Terminal',
    'Services',
    'Testing',
    'Docs',
    'Help',
    'Configs',
    'Custom',
  }
  select(tab_name_items, {
    prompt = 'Select tab name (' .. tabname .. ')',
    format_item = function(item)
      return string.format('%s', item)
    end,
  }, function(choice)
    if not choice then
      return -- User cancelled
    end
    if choice == 'Custom' then
      -- Show input prompt for custom name
      vim.ui.input({
        prompt = 'Enter custom tab name: ',
        default = '',
      }, function(custom_name)
        if custom_name and #custom_name > 0 then
          require('tabby.feature.tab_name').set(0, custom_name)
          return custom_name
        end
      end)
    else
      -- Use selected predefined name
      require('tabby.feature.tab_name').set(0, choice)
    end
  end)

  -- Format options for display
  local function format_option(option)
    return string.format('%s', option)
  end
  local items = tab_name_items
  local opts = {
    prompt = 'Select tab name (' .. tabname .. ')',
    format_item = format_option,
  }

  select(items, opts, function(choice)
    if not choice then
      return -- User cancelled
    end

    if choice == 'Custom' then
      -- Show input prompt for custom name
      vim.ui.input({
        prompt = 'Enter custom tab name: ',
        default = '',
      }, function(custom_name)
        if custom_name and #custom_name > 0 then
          require('tabby.feature.tab_name').set(0, custom_name)
          return custom_name
        end
      end)
    else
      --Use selected predefined name
      require('tabby.feature.tab_name').set(0, choice)
    end
  end)
end

U.Space = function(spcs)
  spcs = spcs or 1
  return { provider = string.rep(' ', spcs) }
end

U.Align = { provider = '%=' }

U.ScrollBarIcon = {
  provider = function()
    return '▅'
  end,
  hl = 'StatusLineNC',
}

return U
