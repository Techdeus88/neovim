--Start-of-file--
local lsp_manager = require "languages.lsp_manager"
local group = vim.api.nvim_create_augroup("DeusLSP_Enable", { clear = true })

local M = {}
local filetype_cache = setmetatable({}, { __mode = "k" }) -- Make cache weak to prevent memory leaks
vim.lsp.handlers["window/showMessage"] = function(err, method, params, client_id)
  print(vim.inspect(params))
end
local function get_filetype_matches(ft)
  if not ft or ft == "" then
    return {}
  end
  if filetype_cache[ft] then
    return filetype_cache[ft]
  end

  local matches = {}
  local file_types = Global.file_types or {}

  -- Use ipairs for sequential access and better performance
  for key, filetypes in pairs(file_types) do
    if vim.tbl_contains(filetypes, ft) then
      table.insert(matches, key)
      Debug.log("Filetype matches: " .. key, "lsp", "INFO")
    end
  end

  filetype_cache[ft] = matches
  return matches
end

local attach_debounce = setmetatable({}, { __mode = "k" }) -- Make debounce table weak

local performance_metrics = {
  attachments = 0,
  errors = 0,
  last_attachment_time = 0,
}

local function update_metrics(metric_type)
  performance_metrics[metric_type] = (performance_metrics[metric_type] or 0) + 1
  if metric_type == "attachments" then
    performance_metrics.last_attachment_time = vim.loop.now()
  end
end

local function attach_lsp_to_buffer(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if attach_debounce[bufnr] then
    return
  end

  attach_debounce[bufnr] = true
  local ft = vim.bo[bufnr].filetype
  if not ft or ft == "" then
    return
  end

  local matches = get_filetype_matches(ft)
  if #matches == 0 then
    return
  end

  -- Use a more efficient coroutine pattern
  local function process_matches()
    for _, match in ipairs(matches) do
      if not lsp_manager.is_server_disabled_globally(match) then
        Debug.log("Server is disabled! Enabling now...", "lsp", "INFO")
        lsp_manager.ensure_lsp_for_buffer(match, bufnr)
      end
    end
  end

  -- Protected call
  local ok, err = pcall(process_matches)
  if not ok then
    Debug.log("Error processing LSP matches: " .. tostring(err), "lsp", "ERROR")
  end

  -- Clear debounce
  vim.defer_fn(function()
    attach_debounce[bufnr] = nil
  end, 50)

  update_metrics "attachments"
end

M.init = function()
  vim.defer_fn(function()
    Debug.log("LSP initializing successfully", "lsp", "INFO")

    -- Create a single autocommand group for all LSP-related events
    local function setup_autocommands()
      -- FileType event
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          attach_lsp_to_buffer(args.buf)
        end,
      })

      -- Buffer events
      vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
        group = group,
        callback = function(args)
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
              attach_lsp_to_buffer(args.buf)
            end
          end, 50)
        end,
      })

      -- Directory change event
      vim.api.nvim_create_autocmd("DirChanged", {
        group = group,
        pattern = "*",
        callback = function()
          vim.defer_fn(function()
            require("languages.lsp_manager").stop_servers_for_old_project()
            require("snacks").notifier.hide()
          end, 1000)
        end,
      })
    end

    -- local function setup_lsp_attach()
    --   vim.api.nvim_create_autocmd("LspAttach", {
    --     group = group,
    --     callback = function(ev)
    --       local bufnr = ev.buf
    --       local client_id = ev.data.client_id
    --       local client = vim.lsp.get_client_by_id(client_id)

    --       if not client then
    --         Debug.log('Invalid LSP client in LspAttach', 'lsp', 'ERROR')
    --         return
    --       end

    --       -- Get filetype and language tools
    --       local ft = vim.bo[bufnr].filetype
    --       local ft_to_lang_map = require("languages.base.file_types").ft_to_lang_map
    --       local lsp_tool_manager = require("languages.utils.manager")

    --       -- Setup language-specific tools
    --       if ft_to_lang_map[ft] then
    --         local language = ft_to_lang_map[ft][1]
    --         local lang_ok, language_tools = pcall(require, "languages.base.lsp." .. language)

    --         if lang_ok and language_tools then
    --           -- Setup formatters
    --           if language_tools.formatters then
    --             for formatter_name, formatter in pairs(language_tools.formatters) do
    --               lsp_tool_manager.add_formatter(ft, formatter_name, formatter)
    --             end
    --           end

    --           -- Setup linters
    --           if language_tools.linters then
    --             for linter_name, linter in pairs(language_tools.linters) do
    --               lsp_tool_manager.add_linter(ft, linter_name, linter)
    --             end
    --           end
    --         end
    --       end

    --       -- Setup client capabilities
    --       local capabilities = client.server_capabilities

    --       -- Enable completion if supported
    --       if capabilities.completionProvider then
    --         vim.lsp.completion.enable(true, client, bufnr, { autotrigger = true })
    --       end

    --       -- Setup semantic tokens if supported
    --       if capabilities.semanticTokensProvider then
    --         vim.lsp.semantic_tokens.start(bufnr, client_id)
    --       end

    --       -- Setup inlay hints if supported (Neovim 0.11+ feature)
    --       if capabilities.inlayHintProvider then
    --         vim.lsp.inlay_hint.enable(bufnr, true)
    --       end

    --       -- Setup code lens if supported
    --       if capabilities.codeLensProvider then
    --         vim.lsp.codelens.refresh()
    --       end

    --       -- Setup document highlights
    --       if capabilities.documentHighlightProvider then
    --         vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    --           group = group,
    --           buffer = bufnr,
    --           callback = function()
    --             vim.lsp.buf.document_highlight()
    --           end,
    --         })

    --         vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    --           group = group,
    --           buffer = bufnr,
    --           callback = function()
    --             vim.lsp.buf.clear_references()
    --           end,
    --         })
    --       end

    --       Debug.log(string.format("LSP client attached: %s", client.name), 'lsp', 'INFO')
    --     end,
    --   })
    -- end

    setup_autocommands()
    -- setup_lsp_attach()
  end, 50)

  -- Add user command for manual re-attachment
  vim.api.nvim_create_user_command("LspReattach", function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(bufnr) then
      attach_lsp_to_buffer(bufnr)
    end
  end, {})
end

M.lsp_enable = function()
  return true
end

M.find_matching_keys = function(ft)
  -- if not ft or ft == "" then
  --     return {}
  -- end

  -- local matches = {}
  -- for key, filetypes in pairs(Global.file_types or {}) do
  --     if vim.tbl_contains(filetypes, ft) then
  --         table.insert(matches, key)
  --     end
  -- end
  -- return matches
  return get_filetype_matches(ft)
end

M.get_client_object = function(client_id)
  if not client_id then
    Debug.log("Client ID is required for this method", "lsp", "ERROR")
    return nil
  end

  local client = vim.lsp.get_client_by_id(client_id)
  if not client then
    Debug.log("Invalid LSP client ID: " .. tostring(client_id), "lsp", "ERROR")
    return nil
  end

  return client
end

M.is_buf_attached = function(buf, client_id)
  if not buf or not client_id then
    return false
  end
  return vim.lsp.buf_is_attached(buf, client_id)
end

M.setup = M.init
------------------------------------------------------------------------
-- vim.api.nvim_create_autocmd("LspAttach", {
--     callback = function(ev)
--         local funcs = require("core.funcs")
--         local ft_to_lang_map = require("languages.base.file_types").ft_to_lang_map
--         local lsp_tool_manager = require("languages.utils.manager")
--         local ft = vim.bo[ev.buf].filetype

--         Debug.notify(string.format("Ft is valid %s", ft))
--         local language = ft_to_lang_map[ft][1]
--         local lang_ok, language_tools = pcall(require, "languages.base" .. language)

--         if not lang_ok then
--             Debug.notify(string.format("Language tools not found for ft: %s", ft))
--             return
--         end
--         -- Get the LSP client by ID
--         local client = M.get_client_object(ev.data.client_id)
--         local client_id = client.id

--         Debug.notify("Debug: LSP client found: " .. client.name, vim.log.levels.DEBUG)
--         -- Ensure the client is attached to the buffer
--         if not M.is_buf_attached(ev.buf, client_id) then
--             Debug.notify("LSP client is not attached to buffer: " .. ev.buf, vim.log.levels.WARN)
--             return
--         end
--         -- Formatters and Linters
--         if language_tools.formatters ~= nil then
--             for formatter_name, formatter in pairs(language_tools.formatters) do
--                 lsp_tool_manager.add_formatter(ft, formatter_name, formatter)
--             end
--         end
--         if language_tools.linters ~= nil then
--             for linter_name, linter in pairs(language_tools.linters) do
--                 lsp_tool_manager.add_linter(ft, linter_name, linter)
--             end
--         end
--         Debug.notify("Debug: LSP client attached: " .. client.name)
--         -- Capabilities check and enable
--         local has_comp = client:supports_method("textDocument/completion")
--         -- Enable LSP completion if supported
--         if has_comp then
--             -- vim.lsp.completion.enable(true, client, ev.buf, { autotrigger = true })
--             Debug.notify("Debug: LSP completion enabled for " .. client.name, vim.log.levels.DEBUG)
--         end
--     end,
-- })

-- vim.lsp.config('*', {
--     capabilities = {
--         textDocument = {
--             semanticTokens = {
--                 multilineTokenSupport = true,
--             }
--         }
--     },
--     root_markers = { '.git' },
-- })

return M
--End-of-file--
