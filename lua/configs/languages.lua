local L = {}
local funcs = require("core.funcs")

-- Initialize the Global.lsps structure properly at startup to avoid nil checks
local function ensure_lsp_structures()
  Global.lsps = Global.lsps or {}
  Global.lsps.servers = Global.lsps.servers or {}
  Global.lsps.linters = Global.lsps.linters or {}
  Global.lsps.formatters = Global.lsps.formatters or {}
end

-- Call this once at module load
ensure_lsp_structures()

function L.add_lsp(filetype, lsp)
  -- Ensure Global.lsps.servers entry exists
  Global.lsps.servers[filetype] = Global.lsps.servers[filetype] or {}

  -- Check for duplicates in Global.lsps.servers
  local found = false
  for i, g_lsp in ipairs(Global.lsps.servers[filetype]) do
    if lsp.name == g_lsp.name then
      -- Update existing entry
      Global.lsps.servers[filetype][i] = { lsp.name, lsp }
      found = true
    end
  end
  if not found then
    table.insert(Global.lsps.servers[filetype], { lsp.name, lsp })
  end
end

function L.add_linter(filetype, linter_name, linter_config)
  local lint = funcs.safe_require('lint')
  if lint then
    -- Ensure linter definition exists
    if lint.linters[linter_name] == nil then
      lint.linters[linter_name] = linter_config
    end

    -- Ensure linters_by_ft entry exists
    lint.linters_by_ft[filetype] = lint.linters_by_ft[filetype] or {}

    -- Check for duplicates before inserting into linters_by_ft
    if not vim.tbl_contains(lint.linters_by_ft[filetype], linter_name) then
      table.insert(lint.linters_by_ft[filetype], linter_name)
    end

    -- Ensure Global.lsps.linters entry exists
    Global.lsps.linters[filetype] = Global.lsps.linters[filetype] or {}

    -- Check for duplicates in Global.lsps.linters
    local found = false
    for i, g_linter in ipairs(Global.lsps.linters[filetype]) do
      if linter_name == g_linter[1] then
        -- Update existing entry
        Global.lsps.linters[filetype][i] = { linter_name, linter_config }
        found = true
        break
      end
    end
    if not found then
      table.insert(Global.lsps.linters[filetype], { linter_name, linter_config })
    end
  end
end

function L.add_formatter(filetype, formatter_name, formatter_config)
  local conform = funcs.safe_require('conform')

  if conform then
    -- Ensure formatter definition exists
    if conform.formatters.fname == nil then
      conform.formatters[formatter_name] = formatter_config
    end

    -- Ensure formatters_by_ft entry exists
    conform.formatters_by_ft[filetype] = conform.formatters_by_ft[filetype] or {}

    -- Check for duplicates before inserting into formatters_by_ft
    if not vim.tbl_contains(conform.formatters_by_ft[filetype], formatter_name) then
      table.insert(conform.formatters_by_ft[filetype], formatter_name)
    end

    Global.lsps.formatters[filetype] = Global.lsps.formatters[filetype] or {}

    -- Check for duplicates in Global.lsps.formatters
    local found = false
    for i, g_formatter in ipairs(Global.lsps.formatters[filetype]) do
      if formatter_name == g_formatter[1] then
        -- Update existing entry
        Global.lsps.formatters[filetype][i] = { formatter_name, formatter_config }
        found = true
        break
      end
    end
    if not found then
      table.insert(Global.lsps.formatters[filetype], { formatter_name, formatter_config })
    end
  end
end

-- Function to convert Global.lsps data into a summary
function L.get_tools_summary()
  local summary = {
    servers = {},
    linters = {},
    formatters = {}
  }
  -- Count LSP servers
  for ft, servers in pairs(Global.lsps.servers or {}) do
    summary.servers[ft] = #servers
  end
  -- Count linters
  for ft, linters in pairs(Global.lsps.linters or {}) do
    summary.linters[ft] = #linters
  end
  -- Count formatters
  for ft, formatters in pairs(Global.lsps.formatters or {}) do
    summary.formatters[ft] = #formatters
  end
  vim.notify(vim.inspect(summary), vim.log.levels.INFO, { title = "Techdeus IDE" })
  return summary
end

-- Function to get all configured tools for a filetype
function L.get_tools_for_filetype(filetype)
  local tools = {
    servers = Global.lsps.servers[filetype] or {},
    linters = Global.lsps.linters[filetype] or {},
    formatters = Global.lsps.formatters[filetype] or {}
  }

  return tools
end

-- Helper function to check if an item exists in a table
function L.has_tool(tool_type, filetype, tool_name)
  if tool_type == "lsp" and Global.lsps.servers[filetype] then
    for _, server in ipairs(Global.lsps.servers[filetype]) do
      if server.name == tool_name then
        return true
      end
    end
  elseif tool_type == "linter" and Global.lsps.linters[filetype] then
    for _, linter in ipairs(Global.lsps.linters[filetype]) do
      if linter[1] == tool_name then
        return true
      end
    end
  elseif tool_type == "formatter" and Global.lsps.formatters[filetype] then
    for _, formatter in ipairs(Global.lsps.formatters[filetype]) do
      if formatter[1] == tool_name then
        return true
      end
    end
  end
  return false
end

vim.keymap.set("n", "<leader>lS", function() L.get_tools_summary() end, { desc = "Tools Summary" })

return L
