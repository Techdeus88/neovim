local globals = require("core.globals")
require("configs.base.utils.log")


local M = {}

function M.merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      if M.is_array(t1[k]) then
        t1[k] = M.concat(t1[k], v)
      else
        M.merge(t1[k], t2[k])
      end
    else
      t1[k] = v
    end
  end
  return t1
end

function M.concat(t1, t2)
  for i = 1, #t2 do
    table.insert(t1, t2[i])
  end
  return t1
end

M.is_array = function(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then return false end
  end
  return true
end

M.file_exists = function(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

M.assert_string = function(n, val) return M.assert_arg(n, val, "string", nil, nil, 3) end

M.assert_arg = function(n, val, tp, verify, msg, lev)
  if type(val) ~= tp then error(("argument %d expected a '%s', got a '%s'"):format(n, tp, type(val)), lev or 2) end
  if verify and not verify(val) then error(("argument %d: '%s' %s"):format(n, val, msg), lev or 2) end
  return val
end

M.readlines = function(file)
  M.assert_string(1, file)
  local f = io.open(file, "r")
  local res = {}
  if f ~= nil then
    for line in f:lines() do
      table.insert(res, line)
    end
    f:close()
  else
    table.insert(res, "File not exists!")
  end
  return res
end

M.calculate_input_width = function(default, prompt)
  local result = 40
  if prompt ~= nil then result = #prompt + 40 end
  if default ~= nil then
    if #default + 40 > result then result = #default + 40 end
  end
  return result
end

M.calculate_select_width = function(entries, prompt)
  local result = 6
  for _, entry in pairs(entries) do
    if #entry.text + 6 > result then result = #entry.text + 6 end
  end
  if #prompt ~= nil then
    if #prompt + 6 > result then result = #prompt + 6 end
  end
  return result + 6
end

M.format_select_entries = function(entries, formatter)
  local formatItem = formatter or tostring
  local results = {
    select.separator("", {
      char = " ",
    }),
  }
  for _, entry in pairs(entries) do
    table.insert(results, select.item(string.format("%s", formatItem(entry))))
  end
  return results
end
local util = {}

M.get_user_config = function(key, default)
  local status_ok, user = pcall(require, 'user')
  if not status_ok then
    return default
  end

  local user_config = user[key]
  if user_config == nil then
    return default
  end
  return user_config
end

M.get_root_dir = function()
  local bufname = vim.fn.expand('%:p')
  if vim.fn.filereadable(bufname) == 0 then
    return
  end

  local parent = vim.fn.fnamemodify(bufname, ':h')
  local git_root = vim.fn.systemlist('git -C ' .. parent .. ' rev-parse --show-toplevel')
  if #git_root > 0 and git_root[1] ~= '' then
    return git_root[1]
  else
    return parent
  end
end

M.get_file_type_cmd = function(extension)
  local root = util.get_root_dir()

  if extension == 'arb' and root then
    local gemfile_exists = vim.fn.filereadable(root .. '/Gemfile') == 1
    local pubspec_exists = vim.fn.filereadable(root .. '/pubspec.yaml') == 1
    if gemfile_exists then
      return 'setfiletype ruby'
    end
    if pubspec_exists then
      return 'setfiletype json'
    end
  end
  return ''
end

M.is_present = function(bin)
  return vim.fn.executable(bin) == 1
end

M.telescope_select = function(options, options_desc, select_prompt)
  require('telescope.pickers')
      .new({}, {
        prompt_title = select_prompt,
        results_title = options_desc,
        finder = require('telescope.finders').new_table({
          results = options,
          entry_maker = require('telescope.make_entry').gen_from_file(),
        }),
        sorter = require('telescope.sorters').get_fzy_sorter(),
        previewer = require('telescope.previewers').vim_buffer_cat.new({}),
      })
      :find()
end

return M
