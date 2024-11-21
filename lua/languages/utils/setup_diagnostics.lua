local globals = require("core.globals")
local funcs = require("core.funcs")
local icons = require("configs.base.ui.icons")
local ui_config = require("modules.build_me.base.config")
local select = ui_config.select
local Lsp_zero = require("lsp-zero")

local LspConfig = {}

local function get_vt()
  local vt
  if globals.lsp.config.virtualdiagnostic then
    vt = {
      prefix = icons.common.dot,
    }
  else
    vt = false
  end
  return vt
end

local config_diagnostic = {
  virtual_text = get_vt(),
  update_in_insert = globals.lsp.config.update_in_insert,
  underline = globals.lsp.config.underline,
  severity_sort = true,
  signs = {
    priority = 9999,
    severity = { min = "HINT", max = "ERROR" },
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
    },
  },
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
}

LspConfig.init_diagnostics = function()
  -- Configure Auto Formatting
  local function deus_auto_format()
    local status
    if globals.lsp.config.autoformat == true then
      status = "Enabled"
    else
      status = "Disabled"
    end
    local opts = ui_config.select({
      "Enable",
      "Disable",
      "Cancel",
    }, { prompt = "AutoFormat (" .. status .. ")" }, {})
    select(opts, function(choice)
      if choice == "Enable" then
        globals.lsp.config["autoformat"] = true
        funcs.write_file(globals.deus_path .. "/lua/core/globals.lua", globals)
      elseif choice == "Disable" then
        globals.lsp.config["autoformat"] = false
        funcs.write_file(globals.deus_path .. "/lua/core/globals.lua", globals)
      end
    end)
  end
  vim.api.nvim_create_user_command("DeusAutoFormat", deus_auto_format, {})
  -- Configure Inlay Hints
  local function deus_inlay_hint()
    local status
    if globals.lsp.config.inlayhint == true then
      status = "Enabled"
    else
      status = "Disabled"
    end
    local opts = ui_config.select({
      "Enable",
      "Disable",
      "Cancel",
    }, { prompt = "InlayHint (" .. status .. ")" }, {})
    select(opts, function(choice)
      if choice == "Enable" then
        local buffers = vim.api.nvim_list_bufs()
        for _, bufnr in ipairs(buffers) do
          if vim.lsp.inlay_hint ~= nil then vim.lsp.inlay_hint.enable(true, { bufnr }) end
        end
        globals.lsp.config["inlayhint"] = true
        funcs.write_file(globals.deus_path .. "/lua/core/globals.lua", globals)
      elseif choice == "Disable" then
        local buffers = vim.api.nvim_list_bufs()
        for _, bufnr in ipairs(buffers) do
          if vim.lsp.inlay_hint ~= nil then vim.lsp.inlay_hint.enable(false, { bufnr }) end
        end
        globals.lsp.config["inlayhint"] = false
        funcs.write_file(globals.deus_path .. "/lua/core/globals.lua", globals)
      end
    end)
  end
  vim.api.nvim_create_user_command("DeusInlayHint", deus_inlay_hint, {})
  vim.diagnostic.config(config_diagnostic)
  local function deus_virtual_diagnostic()
    local status
    if globals.lsp.virtualdiagnostic == true then
      status = "Enabled"
    else
      status = "Disabled"
    end
    local opts = ui_config.select({
      "Enable",
      "Disable",
      "Cancel",
    }, { prompt = "VirtualDiagnostic (" .. status .. ")" }, {})
    select(opts, function(choice)
      if choice == "Enable" then
        globals.lsp.config["virtualdiagnostic"] = true
        funcs.write_file(globals.deus_path .. "/lua/core/globals.lua", globals)
      elseif choice == "Disable" then
        globals.lsp.config["virtualdiagnostic"] = false
        funcs.write_file(globals.deus_path .. "/lua/core/globals.lua", globals)
      end
      local config = vim.diagnostic.config
      config({
        virtual_text = get_vt(),
      })
    end)
  end
  vim.api.nvim_create_user_command("DeusVirtualDiagnostic", deus_virtual_diagnostic, {})

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
end

LspConfig.omni = function(client, bufnr)
  if client.server_capabilities.completionProvider then
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    Lsp_zero.omnifunc.setup({
      autocomplete = true,
      use_fallback = true,
      update_on_delete = false,
      trigger = "<C-Space>",
      tabcomplete = true,
      select_behavior = "insert",
      verbose = true,
    })
  end
end

LspConfig.tag = function(client, bufnr)
  if client.server_capabilities.definitionProvider then
    vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
  end
end

LspConfig.document_highlight = function(client, bufnr)
  if client.server_capabilities.documentHighlightProvider then
    Lsp_zero.highlight_symbol(client, bufnr)
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = bufnr,
      command = "lua vim.lsp.buf.document_highlight()",
      group = "DeusIDE",
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = bufnr,
      command = "lua vim.lsp.buf.clear_references()",
      group = "DeusIDE",
    })
  end
end

LspConfig.document_formatting = function(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    Lsp_zero.format_on_save({
      format_opts = {
        async = false,
        timeout_ms = 5000,
      },
      servers = {
        ["lua_ls"] = { "lua" },
        ["vtsls"] = { "javascript", "typescript" },
        ["ts_js"] = { "javascript", "typescript" },
      },
    })
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        if _G.DEUS_SETTINGS.autoformat == true then
          Lsp_zero.buffer_autoformat()                                           -- vim.lsp.buf.format()
        end
      end,
      group = "DeusIDE",
    })
  end
end

LspConfig.inlay_hint = function(client, bufnr)
  if
      vim.lsp.inlay_hint ~= nil
      and client.server_capabilities.inlayHintProvider
      and _G.DEUS_SETTINGS.inlayhint == true
  then
    -- vim.lsp.inlay_hint(bufnr, true)
    -- vim.lsp.inlay_hint.enable(bufnr, true)
    vim.lsp.inlay_hint.enable(true, { bufnr })
  end
end

LspConfig.get_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem["snippetSupport"] = true
  capabilities.textDocument.completion.completionItem["resolveSupport"] = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }
  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then capabilities = cmp_nvim_lsp.default_capabilities(capabilities) end
  capabilities.experimental = {
    workspaceWillRename = true,
  }
  local f_capabilities = vim.tbl_deep_extend("force", capabilities, {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
    },
  })
  return f_capabilities
end

LspConfig.keymaps = function(_, bufnr)
  local keymaps_lsp = require("configs.base.3-keymaps").keymaps_lsp
  funcs.keymaps("n", { buffer = bufnr, noremap = true, silent = true }, keymaps_lsp.normal)
  funcs.keymaps("x", { buffer = bufnr, noremap = true, silent = true }, keymaps_lsp.visual)
end

LspConfig.navic = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end
end

return LspConfig

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
--     underline = globals.lsp.config.underline,
--     virtual_text = get_vt(),
--     signs = globals.lsp.config.signs,
--     update_in_insert = globals.lsp.config.update_in_insert,
--   }
