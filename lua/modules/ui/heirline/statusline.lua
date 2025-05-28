local C = require "modules.ui.heirline.common"
local conditions = require "base.utils"
local icons = require("base.utils").get_icons()
local funcs = require "core.funcs"

local S = {}

function S.DeusCountPlugins()
  return {
    provider = function()
      local count = require("base.utils.modules").count_plugins()
      return string.format(" %d %s ", count, icons.Packages)
    end,
    hl = { fg = C:get_current_color(), bold = true },
  }
end

function S.add_status_lsp()
  return {
    {
      provider = function()
        return string.format("%s ", icons.UI)
      end,
      hl = "DiagnosticOk",
    },
    -- LSP Servers
    {
      init = function(self)
        self.show = Global.settings ~= nil and true or false
        local current_ft = vim.bo.filetype
        self.lsps_by_ft = {}
        self.lsps_by_ft[current_ft] = {}
        -- Get unique client
        local seen = {}
        self.clients = vim.lsp.get_clients { bufnr = 0 }
        if current_ft ~= nil and vim.tbl_contains(Global.fts, current_ft) then
          for _, client in ipairs(self.clients) do
            if not seen[client.name] then
              seen[client.name] = true
              self.lsps_by_ft[current_ft] = self.lsps_by_ft[current_ft] or {}
              table.insert(self.lsps_by_ft[current_ft], client.name)
            end
          end
        end
      end,
      provider = function(self)
        if not self.show then
          return ""
        end

        local current_ft = vim.bo.filetype

        -- funcs.remove_duplicate(self.lsps_by_ft[current_ft])
        if self.lsps_by_ft[current_ft] then
          return table.concat(self.lsps_by_ft[current_ft], ", ")
        end
        return ""
      end,
      update = {
        "LspAttach",
        "LspDetach",
      },
      hl = "DiagnosticWarn",
    },
  }
end

function S.add_status_formatter()
  return {
    {
      provider = function()
        return string.format("%s ", icons.common.hack)
      end,
      hl = "DiagnosticOk",
    },
    -- Formatters
    {
      init = function(self)
        self.show = Global.settings ~= nil and true or false
        self.formatters_by_ft = {}
        local current_ft = vim.bo.filetype

        if current_ft ~= nil and current_ft ~= "" then
          local conform = funcs.safe_require "conform"
          local formatters = conform.formatters_by_ft[current_ft] or {}
          self.formatters_by_ft[current_ft] = {}

          for _, formatter in ipairs(formatters) do
            table.insert(self.formatters_by_ft[current_ft], formatter)
          end
        end
      end,
      provider = function(self)
        if not self.show then
          return ""
        end
        local current_ft = vim.bo.filetype
        if not Global.settings.statusline.show_lsp_names then
          funcs.remove_duplicate(self.formatters_by_ft[current_ft])
          return string.format("Formatters(%s)", #self.formatters_by_ft[current_ft])
        else
          -- funcs.remove_duplicate(self.formatters_by_ft[current_ft])
          if self.formatters_by_ft[current_ft] then
            return table.concat(self.formatters_by_ft[current_ft], ", ")
          end
        end
      end,
      update = {
        "LspAttach",
        "LspDetach",
      },
      hl = "DiagnosticError",
    },
  }
end

function S.add_status_linter()
  return {
    {
      provider = function()
        return string.format("%s ", icons.Debugger)
      end,
      hl = "DiagnosticOk",
    },
    {
      init = function(self)
        self.show = Global.settings ~= nil and true or false
        self.linters_by_ft = {}
        local current_ft = vim.bo[0].filetype

        if current_ft ~= nil and current_ft ~= "" then
          local lint = funcs.safe_require "lint"
          local linters = lint.linters_by_ft[current_ft] or {}

          local linters_by_ft = {}
          linters_by_ft[current_ft] = {}

          for _, curr_linter in ipairs(linters) do
            table.insert(linters_by_ft[current_ft], curr_linter)
          end
          self.linters_by_ft = vim.deepcopy(linters_by_ft)
        end
      end,
      provider = function(self)
        local current_ft = vim.bo[0].filetype

        if current_ft ~= nil and self.linters_by_ft ~= nil and self.linters_by_ft[current_ft] ~= nil then
          if not Global.settings.statusline.show_lsp_names then
            funcs.remove_duplicate(self.linters_by_ft[current_ft])
            return string.format("Linters(%s)", #self.linters_by_ft[current_ft])
          else
            funcs.remove_duplicate(self.linters_by_ft[current_ft])
            if self.linters_by_ft[current_ft] then
              return table.concat(self.linters_by_ft[current_ft], ",")
            end
          end
        end
      end,
      update = {
        "LspAttach",
        "LspDetach",
      },
      hl = "DiagnosticHint",
    },
  }
end

function S.Spell()
  return {
    condition = function()
      return vim.wo.spell
    end,
    provider = "SPELL ",
    hl = { bold = true, fg = "orange" },
  }
end

S.Diagnostics = function()
  return {

    init = function(self)
      self.error_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.ERROR]
      self.warn_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.WARN]
      self.info_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.INFO]
      self.hint_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.HINT]
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    {
      provider = function(self)
        return self.error_icon .. self.errors .. " "
      end,
      hl = "DiagnosticError",
    },
    {
      provider = "│ ",
      hl = { fg = "#ffffff" },
    },
    {
      provider = function(self)
        return self.warn_icon .. self.warnings .. " "
      end,
      hl = "DiagnosticWarning",
    },
    {
      provider = "│ ",
      hl = { fg = "#ffffff" },
    },
    {
      provider = function(self)
        return self.hint_icon .. self.hints .. " "
      end,
      hl = "DiagnosticHint",
    },
    {
      provider = "│ ",
      hl = { fg = "#ffffff" },
    },
    {
      provider = function(self)
        return self.info_icon .. self.info .. " "
      end,
      hl = "DiagnosticInfo",
    },
  }
end

S.DeusFileSize = function()
  return {
    provider = function()
      local suffix = { "b", "k", "M", "G", "T", "P", "E" }
      local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))

      fsize = (fsize < 0 and 0) or fsize
      if fsize < 1024 then
        return string.format(" %s %s ", icons.kind.Unit, fsize .. suffix[1])
      end

      local i = math.floor((math.log(fsize) / math.log(1024)))
      local aSize = string.format("%.2g%s  ", fsize / math.pow(1024, i), suffix[i + 1])

      return string.format(" %s %s ", icons.kind.Unit, aSize)
    end,
    hl = { fg = C:get_current_color(), bg = "#101010", bold = true },
  }
end

S.DeusGitdiff = function()
  return {
    init = function(self)
      local icons = require "base.ui.icons"
      self.status_dict = vim.b.gitsigns_status_dict or {}
      self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
      self.icons = { deleted = icons.GitDelete, changed = icons.GitChange, added = icons.GitAdd }
    end,
    {
      provider = function(self)
        local count = self.status_dict.added or 0
        return (self.icons.added .. count)
      end,
      hl = "GitSignsAdd",
    },
    { provider = " │ ", hl = { fg = "#ffffff" } },
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return (self.icons.deleted .. count)
      end,
      hl = "GitSignsDelete",
    },
    { provider = " │ ", hl = { fg = "#ffffff" } },
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return (self.icons.changed .. count)
      end,
      hl = "GitSignsChange",
    },
  }
end

S.get_statusline = function()
  local lib = require "heirline-components.all"
  return {
    condition = function()
      return conditions.is_active()
    end,
    C.DeusMode "left",
    S.DeusFileSize(),
    C.Space(5),
    S.DeusGitdiff(),
    lib.component.fill(),
    S.add_status_lsp(),
    C.Space(1),
    S.add_status_formatter(),
    C.Space(1),
    S.add_status_linter(),
    C.Space(1),
    lib.component.fill(),
    S.Diagnostics(),
    C.Space(5),
    {
      C.Space(1),
      lib.component.file_info {
        filetype = {},
        filename = false,
        file_icon = false,
        file_modified = false,
        surround = { color = "#101010" },
      },
      lib.component.file_info {
        file_icon = {},
        filetype = false,
        filename = false,
        file_modified = false,
        surround = { color = "#101010" },
      },
      hl = { bg = "#101010", fg = "" },
    },
    S.DeusCountPlugins(),
  }
end

return S

--End-of-file--
