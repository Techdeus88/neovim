local home = os.getenv("HOME")
local os_name = vim.loop.os_uname().sysname

local globals = {}

function globals:load_variables()
  self.event = {
    augroup = function(name) return vim.api.nvim_create_augroup("TechdeusNvim" .. name, { clear = true }) end,
    autocmd = vim.api.nvim_create_autocmd,
  }
  self.showtype = "totals"
  self.statusline = {
    show = "lsp", -- "lsp" | "stats"
    ruler = "totals" -- "totals" | "current"
  }
  self.path_package = vim.fn.stdpath("data") .. "/site/"
  self.deus_path = home .. "/.config/nvim"
  self.cache_path = home .. "/.cache/nvim"
  self.packer_path = home .. "/.local/share/nvim/site"
  self.snapshot_path = self.deus_path .. "/.snapshots"
  self.modules_path = self.deus_path .. "/lua/modules"
  self.global_config = self.deus_path .. "/lua/core/globals"
  self.custom_config = self.deus_path .. "/lua/configs/base/custom"
  self.home = home
  self.mason_path = home .. "/.local/share/nvim/mason"
  self.plugins = vim.defer_fn(function()
    local plugs = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/deps/opt", "*", 0, 1)[1]
    return plugs
  end, 5000)
  self.palette = {}
  self.languages = {}
  self.install_process = false
  self.tm_augroup = vim.api.nvim_create_augroup("ClueStatus", { clear = true })
  self.loaded = {}
  self.os = ({
    Darwin = "mac",
    Linux = "linux",
    Windows = "unsupported",
  })[os_name] or "other"
  self.lsp = {
    languages = {},
    config = {
      autoformat = true,
      inlayhint = true,
      virtualdiagnostic = true,
      virtual_text = true,
      floatheight = 0.4,
      keyshelper = true,
      keyshelperdelay = 200,
      underline = true,
      signs = true,
      update_in_insert = false,
    },
    keys = {
      goto_decl = { "gD", vim.lsp.buf.declaration, "Goto declaration" },
      goto_def = { "gd", vim.lsp.buf.definition, "Goto definition" },
      hover = { "K", vim.lsp.buf.hover, "Display hover information" },
      goto_impl = { "gi", vim.lsp.buf.implementation, "Goto implementation" },
      sign_help = { "<C-k>", vim.lsp.buf.signature_help, "Display signature information" },
      add_folder = { "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder" },
      del_folder = { "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder" },
      -- list_folders = {
      --   "<leader>wl",
      --   function() vim.print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
      --   "List workspace folder",
      -- },
      type_def = { "<leader>D", vim.lsp.buf.type_definition, "Goto type definition" },
      rename = { "<leader>rn", vim.lsp.buf.rename, "Rename symbol" },
      code_action = { "<leader>ca", vim.lsp.buf.code_action, "Code action" },
      codelens = { "<leader>cl", vim.lsp.codelens.run, "Code action" },
      list_ref = { "gr", vim.lsp.buf.references, "List references" },
      format = { "<leader>bf", vim.lsp.buf.format, "Format buffer" },
      inlay_hint = {
        "<leader>lh",
        function()
          local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
          vim.lsp.inlay_hint.enable(not enabled)
        end,
        "Toogle in[l]ay [h]int",
      },
      on_attach_hooks = {
        -- set buffer keymapping
        function(_, bufnr)
          for _, mapper in pairs(globals.lsp.keys) do
            vim.keymap.set("n", mapper[1], mapper[2], { desc = mapper[3], buffer = bufnr })
          end
        end,
      },
      cap_makers = {
        -- neovim default capabilities
        function(_) return vim.lsp.protocol.make_client_capabilities() end,
      },
      setup = function(_) end,
      make_config = function(_) return {} end,
    },
  }
end

globals:load_variables()
_G.globals = globals

return globals
