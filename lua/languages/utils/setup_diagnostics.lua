local icons = require('base.ui.icons')
local diagnostics_config = require('languages.utils.diagnostics_config')
local show_diagnostics = require('languages.utils.show_diagnostics')

local function group(name)
  name = name or ""
  return vim.api.nvim_create_augroup('LspProgressNotify' .. name, {
    clear = false,
  })
end
local global_settings = Global.settings or {}
local virtualdiagnostic = global_settings.virtualdiagnostic
local is_empty = not virtualdiagnostic or next(virtualdiagnostic) == nil

local config_diagnostic = {
  virtual_text = (not is_empty and virtualdiagnostic.text) and { prefix = icons.common.dot } or false,
  virtual_lines = not is_empty and virtualdiagnostic.lines or false,
  update_in_insert = global_settings.update_in_insert,
  underline = global_settings.underline,
  severity_sort = true,
  signs = {
    priority = 9999,
    severity = { min = 'HINT', max = 'ERROR' },
    linehl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "None",
      [vim.diagnostic.severity.HINT] = "None",
      [vim.diagnostic.severity.INFO] = "None",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
      [vim.diagnostic.severity.HINT] = "DiagnosticHint",
      [vim.diagnostic.severity.INFO] = "DiagnosticHint",
    },
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
    },
  },
  float = diagnostics_config.shared_config.floating,
}

local M = {}
-----------------------------------------------------------------------
------------------------- Apply diagnostics ---------------------------
-----------------------------------------------------------------------
M.init_diagnostics = function()
  Debug.log("Init Diags starting...", "lsp", "INFO")

  vim.diagnostic.config(config_diagnostic)
  vim.fn.sign_define("DiagnosticSignError", {
    text = icons.diagnostics.error,
    texthl = "DiagnosticError",
  })
  vim.fn.sign_define("DiagnosticSignWarn", {
    text = icons.diagnostics.warn,
    texthl = "DiagnosticWarn",
  })
  vim.fn.sign_define("DiagnosticSignHint", {
    text = icons.diagnostics.hint,
    texthl = "DiagnosticHint",
  })
  vim.fn.sign_define("DiagnosticSignInfo", {
    text = icons.diagnostics.info,
    texthl = "DiagnosticInfo",
  })
  if Global.settings.lspprogress then
    M.enable_lsp_progress()
  end
end

-----------------------------------------------------------------------
-------------------- Apply Document Highlighting ----------------------
-----------------------------------------------------------------------
M.document_highlight = function(client, bufnr)
  -- Debug.notify("document highlight starting...", "lsp")
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      command = "lua vim.lsp.buf.document_highlight()",
      group = "TechdeusIDE",
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = bufnr,
      command = "lua vim.lsp.buf.clear_references()",
      group = "TechdeusIDE",
    })
  end
end

-----------------------------------------------------------------------
-------------------- Apply Document Auto Format -----------------------
-----------------------------------------------------------------------
M.document_auto_format = function(client, bufnr)
  Debug.log("Document auto format starting...", "lsp", "INFO")
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        if Global.settings.autoformat == true then
          vim.lsp.buf.format()
        end
      end,
      group = "TechdeusIDE",
    })
  end
end
-----------------------------------------------------------------------
-------------------- Apply inlay hint settings ------------------------
-----------------------------------------------------------------------
M.inlay_hint = function(client, bufnr)
  Debug.log("Inlay hint starting...", "lsp", "INFO")
  if
      vim.lsp.inlay_hint ~= nil
      and client.server_capabilities.inlayHintProvider
      and _G.Global.settings.inlayhint == true
  then
    vim.schedule(function()
      vim.lsp.inlay_hint.enable(true, { bufnr })
    end)
  end
end

M.enable_lsp_progress = function()
  Debug.log("LSP Progress enabled", "lsp", "INFO")

  vim.api.nvim_clear_autocmds({ group = group() })

  ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
  local progress = vim.defaulttable()
  vim.api.nvim_create_autocmd("LspProgress", {
    group = group(),
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local value = ev.data.params
          .value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
      if not client or type(value) ~= "table" then
        return
      end
      local p = progress[client.id]
      for i = 1, #p + 1 do
        if i == #p + 1 or p[i].token == ev.data.params.token then
          p[i] = {
            token = ev.data.params.token,
            msg = ("[%3d%%] %s%s"):format(
              value.kind == "end" and 100 or value.percentage or 100,
              value.title or "",
              value.message and (" **%s**"):format(value.message) or ""
            ),
            done = value.kind == "end",
          }
          break
        end
      end
      local msg = {} ---@type string[]
      progress[client.id] = vim.tbl_filter(function(v)
        return table.insert(msg, v.msg) or not v.done
      end, p)
      local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
      vim.notify(table.concat(msg, "\n"), "info", {
        id = "lsp_progress",
        title = client.name,
        opts = function(notif)
          notif.icon = #progress[client.id] == 0 and " "
              or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
        end,
      })
    end,
  })
end

M.disable_lsp_progress = function()
  Debug.log("LSP Progress disabled", "lsp", "INFO")
  vim.api.nvim_clear_autocmds({ group = group() })
end

----------------------------------------------------------------------
--------------------- Apply LSP Capabilities -------------------------
----------------------------------------------------------------------
M.get_capabilities = function()
  Debug.log("Getting capabilities enabled", "lsp", "INFO")
  ----------------------------------------------------------------------
  -------------------- Create LSP Capabilities -------------------------
  ----------------------------------------------------------------------
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities["offsetEncoding"] = "utf-8
  capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.preselectSupport = true
  capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
  capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
  capabilities.textDocument.completion.completionItem.resolveSupport =
  { properties = { 'documentation', 'detail', 'additionalTextEdits' } }
  capabilities.experimental = { snippetTextEdit = true, workspaceWillRename = true }
  capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
  capabilities.textDocument.documentSymbol = { hierarchicalDocumentSymbolSupport = true }
  capabilities.textDocument.codeAction = {
    codeActionLiteralSupport = {
      codeActionKind = {
        valueSet = {
          '',
          'quickfix',
          'refactor',
          'refactor.extract',
          'refactor.inline',
          'refactor.rewrite',
          'source',
          'source.organizeImports',
        },
      },
    },
  }
  capabilities.textDocument.semanticTokens = {
    multilineTokenSupport = true,
  }
  local cap = require("blink.cmp").get_lsp_capabilities(capabilities)
  return cap
end

M.get_cpp_capabilities = function()
  Debug.log("Getting CPP capabilities enabled", "lsp", "INFO")
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  return require("blink.cmp").get_lsp_capabilities(capabilities)
end

-----------------------------------------------------------------------
-------------------- Apply Omni/Tags settings -------------------------
-----------------------------------------------------------------------
function M.omni_tags(client, bufnr)
  Debug.log("Omni Tags...", "lsp", "INFO")
  -- omni
  if client.server_capabilities.completionProvider then
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  end
  -- tags
  if client.server_capabilities.definitionProvider then
    vim.api.nvim_buf_set_option(bufnr, 'tagfunc', 'v:lua.vim.lsp.tagfunc')
  end
end

-----------------------------------------------------------------------
-------------------- Apply navic navbar settings ----------------------
-----------------------------------------------------------------------
function M.navic(client, bufnr)
  Debug.log("Navic enabled", "lsp", "INFO")
  if client.server_capabilities.documentSymbolProvider then
    local ok, navic = pcall(require, 'nvim-navic')
    if not ok then
      vim.notify("Navic not available! Please check...", vim.log.levels.WARN, { title = "Techdeus IDE" })
      return
    end
    navic.attach(client, bufnr)
  end
end

-----------------------------------------------------------------------
----------------------- Apply LSP Mappings ----------------------------
-----------------------------------------------------------------------
M.keymaps = function(_, bufnr)
  local function create_safe_command(capability_name, command)
    return function()
      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      local has_capability = false
      for _, client in ipairs(clients) do
        if client.server_capabilities and client.server_capabilities[capability_name] then
          has_capability = true
          Debug.log(string.format("Capability granted: %s", capability_name))
          break
        end
      end
      if has_capability then
        pcall(command)
      end
    end
  end

  local _border = {
    { "🭽", "FloatBorder" },
    { "▔", "FloatBorder" },
    { "🭾", "FloatBorder" },
    { "▕", "FloatBorder" },
    { "🭿", "FloatBorder" },
    { "▁", "FloatBorder" },
    { "🭼", "FloatBorder" },
    { "▏", "FloatBorder" },
  }

  local function bordered_hover(_opts)
    _opts = _opts or {}
    return vim.lsp.buf.hover(vim.tbl_deep_extend("force", _opts, {
      border = _border,
    }))
  end
  local function bordered_signature_help(_opts)
    _opts = _opts or {}
    return vim.lsp.buf.signature_help(vim.tbl_deep_extend("force", _opts, {
      border = _border,
    }))
  end

  local mappings = {
    {
      mode = "n",
      lhs = "ld",
      capability = "definitionProvider",
      command = vim.lsp.buf.definition,
      desc = "LspDefinition",
    },
    {
      mode = "n",
      lhs = "lD",
      capability = "declarationProvider",
      command = vim.lsp.buf.declaration,
      desc = "LspDeclaration",
    },
    {
      mode = "n",
      lhs = "gt",
      capability = "typeDefinitionProvider",
      command = vim.lsp.buf.type_definition,
      desc = "LspTypeDefinition",
    },
    {
      mode = "n",
      lhs = "lr",
      capability = "referencesProvider",
      command = vim.lsp.buf.references,
      desc = "LspReferences",
    },
    {
      mode = "n",
      lhs = "li",
      capability = "implementationProvider",
      command = vim.lsp.buf.implementation,
      desc = "LspImplementation",
    },
    {
      mode = "n",
      lhs = "lR",
      capability = "renameProvider",
      command = vim.lsp.buf.rename,
      desc = "LspRename",
    },
    {
      mode = "n",
      lhs = "la",
      capability = "codeActionProvider",
      command = vim.lsp.buf.code_action,
      desc = "LspCodeAction",
    },
    {
      mode = "n",
      lhs = "gs",
      capability = "signatureHelpProvider",
      command = bordered_signature_help,
      desc = "LspSignatureHelp",
    },
    {
      mode = "n",
      lhs = "gL",
      capability = "codeLensProvider",
      command = vim.lsp.codelens.refresh,
      desc = "LspCodeLensRefresh",
    },
    {
      mode = "n",
      lhs = "gl",
      capability = "codeLensProvider",
      command = vim.lsp.codelens.run,
      desc = "LspCodeLensRun",
    },
    {
      mode = "n",
      lhs = "gh",
      capability = "hoverProvider",
      command = vim.lsp.buf.hover,
      desc = "LspHover",
    },
    {
      mode = "n",
      lhs = "K",
      capability = "hoverProvider",
      command = bordered_hover,
      desc = "LspHover",
    },
  }

  local function setup_format_mappings()
    local has_format_capability = false
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
      if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
        has_format_capability = true
        break
      end
    end
    if has_format_capability then
      vim.keymap.set("n", "lf", function()
        vim.cmd("LspFormat")
      end, { noremap = true, silent = true, buffer = bufnr, desc = "LspFormat" })
      Debug.log(string.format("Has formatting: %s", has_format_capability and "yes" or "no"), "lsp", "INFO")
    end
  end

  Debug.log("LSP keymaps is starting. ", "lsp", "INFO")
  for _, mapping in ipairs(mappings) do
    vim.keymap.set(mapping.mode, mapping.lhs, create_safe_command(mapping.capability, mapping.command), {
      noremap = true,
      silent = true,
      buffer = bufnr,
      desc = mapping.desc,
    })
  end
  setup_format_mappings()
end

-- Add methods to interact with show_diagnostics
M.show_line_diagnostics = show_diagnostics.show_line_diagnostics
M.goto_next = show_diagnostics.goto_next
M.goto_prev = show_diagnostics.goto_prev
M.show_diagnostics_float = show_diagnostics.line

-- Add keymaps for diagnostics
M.setup_diagnostics_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', ']d', M.goto_next, vim.tbl_extend('force', opts, { desc = 'Next Diagnostic' }))
  vim.keymap.set('n', '[d', M.goto_prev, vim.tbl_extend('force', opts, { desc = 'Previous Diagnostic' }))
  vim.keymap.set('n', 'gl', M.show_line_diagnostics, vim.tbl_extend('force', opts, { desc = 'Show Line Diagnostics' }))
end

return M
--End-of-file--
--------------------------------------------------------------------------------
-----------------------------------------------------------------------
-------------------- Apply formatting settings ------------------------
-----------------------------------------------------------------------
-- if vim.fn.has("nvim-0.11") == 0 then   -- TODO: Delete when dropping 0.10 support
--   vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", silent = true })
--   vim.lsp.handlers["textDocument/signatureHelp"] =
--       vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", silent = true })
--       local original_handler = vim.lsp.handlers['textDocument/publishDiagnostics']
--       vim.lsp.handlers['textDocument/publishDiagnostics'] = require('core.funcs').debounce(200, function(...)
--         original_handler(...)
--       end)
--       local opts = vim.tbl_deep_extend('force', server, { capabilities = L.capabilities, flags = L.flags })
-- end

-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
--   local uri = result.uri
--   local ns = vim.api.nvim_create_namespace("lsp_diagnostics")
--   local bufnr = vim.uri_to_bufnr(uri)
--   if not bufnr then return end
--   local diagnostics = vim.diagnostic.get(bufnr)
--   vim.diagnostic.set(ns, bufnr, diagnostics)

--   if not config then config = {} end
--   config.underline = config.underline ~= false
--   config.virtual_text = config.virtual_text ~= false
--   config.signs = config.signs ~= false
--   config.update_in_insert = config.update_in_insert == true

--   for i, diagnostic in ipairs(diagnostics) do
--     diagnostic.message = string.format("%s: %s", diagnostic.source, diagnostic.message)
--     vim.diagnostic.show(ns, bufnr, diagnostic, config)
--   end
-- end
-- )

--   vim.lsp.diagnostic.on_publish_diagnostics, {
--     underline = Global.lsp.config.underline,
--     virtual_text = get_vt(),
--     signs = Global.lsp.config.signs,
--     update_in_insert = Global.lsp.config.update_in_insert,
--   }
--------------------------------------------------------------------------------
