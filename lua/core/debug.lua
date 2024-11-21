-- selene: allow(global_usage)

local D = {}

function D.get_loc()
  local me = debug.getinfo(1, "S")
  local level = 2
  local info = debug.getinfo(level, "S")
  while info and (info.source == me.source or info.source == "@" .. vim.env.MYVIMRC or info.what ~= "Lua") do
    level = level + 1
    info = debug.getinfo(level, "S")
  end
  info = info or me
  local source = info.source:sub(2)
  source = vim.loop.fs_realpath(source) or source
  return source .. ":" .. info.linedefined
end

---@param value any
---@param opts? {loc:string}
-- Add this at the top of the file, after the local D = {} line
D.log_file = vim.fn.stdpath("cache") .. "/nvim_debug.log"

function D._dump(value, opts)
  opts = opts or {}
  opts.loc = opts.loc or D.get_loc()
  if vim.in_fast_event() then
    return vim.schedule(function()
      D._dump(value, opts)
    end)
  end
  opts.loc = vim.fn.fnamemodify(opts.loc, ":~:.")
  local msg = vim.inspect(value)
  -- Format the log message
  local log_msg = string.format("[%s] %s\n%s\n\n", os.date("%Y-%m-%d %H:%M:%S"), opts.loc, msg)
  -- Append to log file
  local file = io.open(D.log_file, "a")
  if file then
    file:write(log_msg)
    file:close()
  else
    print("Failed to open log file: " .. D.log_file)
  end
end

function D.dump(...)
  local value = { ... }
  if vim.tbl_isempty(value) then
    value = {}
  else
    value = vim.tbl_islist(value) and vim.tbl_count(value) <= 1 and value[1] or value
  end
  D.dump(value)
end

function D.extmark_leaks()
  local nsn = vim.api.nvim_get_namespaces()

  local counts = {}

  for name, ns in pairs(nsn) do
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local count = #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
      if count > 0 then
        counts[#counts + 1] = {
          name = name,
          buf = buf,
          count = count,
          ft = vim.bo[buf].ft,
        }
      end
    end
  end
  table.sort(counts, function(a, b)
    return a.count > b.count
  end)
  dd(counts)
end

function D.estimateSize(value, visited)
  if value == nil then
    return 0
  end
  local bytes = 0

  -- initialize the visited table if not already done
  --- @type table<any, true>
  visited = visited or {}

  -- handle already-visited value to avoid infinite recursion
  if visited[value] then
    return 0
  else
    visited[value] = true
  end

  if type(value) == "boolean" or value == nil then
    bytes = 4
  elseif type(value) == "number" then
    bytes = 8
  elseif type(value) == "string" then
    bytes = string.len(value) + 24
  elseif type(value) == "function" then
    bytes = 32 -- base size for a function
    -- add size of upvalues
    local i = 1
    while true do
      local name, val = debug.getupvalue(value, i)
      if not name then
        break
      end
      bytes = bytes + D.estimateSize(val, visited)
      i = i + 1
    end
  elseif type(value) == "table" then
    bytes = 40 -- base size for a table entry
    for k, v in pairs(value) do
      bytes = bytes + D.estimateSize(k, visited) + D.estimateSize(v, visited)
    end
    local mt = debug.getmetatable(value)
    if mt then
      bytes = bytes + D.estimateSize(mt, visited)
    end
  end
  return bytes
end

function D.module_leaks(filter)
  local sizes = {}
  for modname, mod in pairs(package.loaded) do
    if not filter or modname:match(filter) then
      local root = modname:match("^([^%.]+)%..*$") or modname
      -- root = modname
      sizes[root] = sizes[root] or { mod = root, size = 0 }
      sizes[root].size = sizes[root].size + D.estimateSize(mod) / 1024 / 1024
    end
  end
  sizes = vim.tbl_values(sizes)
  table.sort(sizes, function(a, b)
    return a.size > b.size
  end)
  dd(sizes)
end

function D.get_upvalue(func, name)
  local i = 1
  while true do
    local n, v = debug.getupvalue(func, i)
    if not n then
      break
    end
    if n == name then
      return v
    end
    i = i + 1
  end
end

function D.clear_log()
  local file = io.open(D.log_file, "w")
  if file then
    file:close()
    print("Debug log cleared")
  else
    print("Failed to clear debug log")
  end
end

return D
