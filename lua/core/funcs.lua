local F = {}

--- @return table<string,table> # a table with entries for each map mode.
function F.safe_require(module)
  local ok, mod = pcall(require, module)
  if not ok then
    vim.notify(string.format('Error loading module: %s', vim.inspect(module)), vim.log.levels.ERROR)
    return { ok }
  end
  return mod
end

-- Debugging utility to print a table
--- @return nil
--- @param tbl table<string, table|number|string|boolean|nil>
function F.pretty_print(tbl)
  print(vim.inspect(tbl))
end

--- @return boolean | nil
function F.file_exists(name)
  local f = io.open(name, 'r')
  return f ~= nil and io.close(f)
end

--- @return boolean | nil
function F.dir_exists(path)
  return F.file_exists(path)
end

function F.debounce(ms, fn)
  local timer = vim.uv.new_timer()
  return function(...)
    local argv = { ... }
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(argv))
    end)
  end
end

function F.read_file(file)
  local content
  local file_content_ok, _ = pcall(function()
    content = vim.fn.readfile(file)
  end)
  if not file_content_ok then
    return nil
  end
  if type(content) == 'table' then
    return vim.fn.json_decode(content)
  else
    return nil
  end
end

function F.write_file(file, content)
  local f = io.open(file, 'w')
  if f ~= nil then
    if type(content) == 'table' then
      content = vim.fn.json_encode(content)
    end
    f:write(content)
    f:close()
  end
end

F.copy_file = function(file, dest)
  os.execute('cp ' .. file .. ' ' .. dest)
end

F.delete_file = function(f)
  os.remove(f)
end

F.change_path = function()
  return vim.fn.input("Path: ", vim.fn.getcwd() .. "/", "file")
end

F.set_global_path = function()
  local path = F.change_path()
  vim.api.nvim_command("silent :cd " .. path)
end

F.set_window_path = function()
  local path = F.change_path()
  vim.api.nvim_command("silent :lcd " .. path)
end

F.file_size = function(size, options)
  local si = {
    bits = { "b", "Kb", "Mb", "Gb", "Tb", "Pb", "Eb", "Zb", "Yb" },
    bytes = { "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" },
  }
  local function isNan(num)
    return num ~= num
  end
  local function roundNumber(num, digits)
    local fmt = "%." .. digits .. "f"
    return tonumber(fmt:format(num))
  end
  local o = {}
  for key, value in pairs(options or {}) do
    o[key] = value
  end
  local function setDefault(name, default)
    if o[name] == nil then
      o[name] = default
    end
  end
  setDefault("bits", false)
  setDefault("unix", false)
  setDefault("base", 2)
  setDefault("round", o.unix and 1 or 2)
  setDefault("spacer", o.unix and "" or " ")
  setDefault("suffixes", {})
  setDefault("output", "string")
  setDefault("exponent", -1)
  assert(not isNan(size), "Invalid arguments")
  local ceil = (o.base > 2) and 1000 or 1024
  local negative = (size < 0)
  if negative then
    size = -size
  end
  local result
  if size == 0 then
    result = {
      0,
      o.unix and "" or (o.bits and "b" or "B"),
    }
  else
    if o.exponent == -1 or isNan(o.exponent) then
      o.exponent = math.floor(math.log(size) / math.log(ceil))
    end
    if o.exponent > 8 then
      o.exponent = 8
    end
    local val
    if o.base == 2 then
      val = size / math.pow(2, o.exponent * 10)
    else
      val = size / math.pow(1000, o.exponent)
    end
    if o.bits then
      val = val * 8
      if val > ceil then
        val = val / ceil
        o.exponent = o.exponent + 1
      end
    end
    result = {
      roundNumber(val, o.exponent > 0 and o.round or 0),
      (o.base == 10 and o.exponent == 1) and (o.bits and "kb" or "kB")
      or si[o.bits and "bits" or "bytes"][o.exponent + 1],
    }
    if o.unix then
      result[2] = result[2]:sub(1, 1)
      if result[2] == "b" or result[2] == "B" then
        result = {
          math.floor(result[1]),
          "",
        }
      end
    end
  end
  assert(result)
  if negative then
    result[1] = -result[1]
  end
  result[2] = o.suffixes[result[2]] or result[2]
  if o.output == "array" then
    return result
  elseif o.output == "exponent" then
    return o.exponent
  elseif o.output == "object" then
    return {
      value = result[1],
      suffix = result[2],
    }
  elseif o.output == "string" then
    local value = tostring(result[1])
    value = value:gsub("%.0$", "")
    local suffix = result[2]
    return value .. o.spacer .. suffix
  end
end

F.remove_duplicate = function(tbl)
  if type(tbl) ~= "table" then return end
  local hash = {}
  local res = {}
  for _, v in ipairs(tbl) do
    if not hash[v] then
      res[#res + 1] = v
      hash[v] = true
    end
  end
  return res
end

F.delete_packages_file = function()
  local deus_packages_file = Global.cache_path .. '/.deus_packages'
  os.remove(deus_packages_file)
end

function F.deus_notify()
  -- delay notifications till funcs.notify was replaced or after 500ms
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.uv.new_timer()
  local check = assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    vim.schedule(function()
      ---@diagnostic disable-next-line: no-unknown
      for _, notif in ipairs(notifs) do
        vim.notify(tostring(vim.F.unpack_len(notif)))
      end
    end)
  end

  -- wait till funcs.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
  Debug.log("Notifications delayed", "default")
end

local multi_line_patterns = {
  "%-%-%[%[.-%]%]", -- --[[ multi-line comment ]]
  "/%*.-%*/",       -- /* multi-line comment */
  "<!%-%-.-%-%->",  -- <!-- multi-line comment -->
}

local single_line_patterns = {
  "^%s*%-%-[^%-%[].*$", -- -- single-line comment (but not ---)
  "^%s*//.*$",          -- // single-line comment
  "^%s*#[^%x%d].*$",    -- # single-line comment (but not #hex)
  "^%s*;.*$",           -- ; single-line comment
  "^%s*{{!.-}}%s*$",    -- {{! handlebars single-line comment }}
  "^%s*{#.-#}%s*$",     -- {# django/jinja single-line comment #}
  "%s%-%-[^%-%[].*$",   -- inline -- comment
  "%s//.*$",            -- inline // comment
  "%s#[^%x%d].*$",      -- inline # comment (but not #hex)
  "%s;.*$",             -- inline ; comment
}

F.remove_comments = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(original_lines, "\n")
  local multi_line_comment_count = 0
  local multi_line_total_lines = 0
  for _, pattern in ipairs(multi_line_patterns) do
    content = content:gsub(pattern, function(match)
      multi_line_comment_count = multi_line_comment_count + 1
      local line_count = select(2, match:gsub("\n", "")) + 1
      multi_line_total_lines = multi_line_total_lines + line_count
      return string.rep("\n", line_count)
    end)
  end
  local lines = vim.split(content, "\n", { trimempty = false })
  local result_lines = {}
  local single_line_comment_count = 0
  for i, line in ipairs(lines) do
    local modified_line = line
    local is_original_empty = original_lines[i] and original_lines[i]:match("^%s*$") or false
    if not modified_line:match("#%x%x%x%x%x%x?") then
      for _, pattern in ipairs(single_line_patterns) do
        local before = #modified_line
        modified_line = modified_line:gsub(pattern, "")
        if #modified_line < before then
          single_line_comment_count = single_line_comment_count + 1
        end
      end
    end
    modified_line = modified_line:gsub("%s+$", "")
    if modified_line:match("%S") or is_original_empty then
      table.insert(result_lines, modified_line)
    end
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result_lines)
  vim.notify(
    "Deleted comments: \n"
    .. "Single-line: "
    .. single_line_comment_count
    .. "\n"
    .. "Multi-line: "
    .. multi_line_comment_count
    .. " (Total lines: "
    .. multi_line_total_lines
    .. ")",
    vim.log.levels.INFO
  )
end


return F
