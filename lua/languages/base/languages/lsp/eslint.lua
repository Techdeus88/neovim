local config = {}

local file_exists = function(file)
  local f = io.open(file, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

config.eslint = function()
  return {
    on_init = function(client)
      client.config.settings.workingDirectory = { directory = client.config.root_dir }
      client.formatting.eslint_d.with {
        extra_args = function(params)
          local root_file
          local file_types = { "js", "cjs", "yaml", "yml", "json", "ts" }
          for _, file_type in pairs(file_types) do
            local p_root_file = params.root .. '/.eslintrc.' .. file_type
            if file_exists(p_root_file) then
              root_file = p_root_file
              return {}
            end
          end
  
          return {
            "--config",
            vim.fn.expand(root_file)
          }
        end,
      }
    end,
    settings = {
      cmd = { "vscode-eslint-language-server", "--stdio" },
      filetypes = {
        "javascript",
        "typescript",
        "vue",
        "astro",
        "svelte",
        "typescript.tsx",
        "javascript.jsx",
        "typescriptreact",
        "javascriptreact",
      },
      root_dir = function(fname)
        local root_file_options = {
          ".eslintrc",
          ".eslintrc.js",
          ".eslintrc.cjs",
          ".eslintrc.yaml",
          ".eslintrc.yml",
          ".eslintrc.json",
          "eslint.config.js",
          "eslint.config.mjs",
          "eslint.config.cjs",
          "eslint.config.ts",
          "eslint.config.mts",
          "eslint.config.cts",
        }
        local lspconfig = require("lspconfig")
        local root_file = lspconfig.util.insert_package_json(root_file_options, "eslintConfig", fname)
        return lspconfig.util.root_pattern(unpack(root_file))(fname)
      end,
      workingDirectories = { mode = "auto" },
    },
  }
end
  -- setup = function()
  --   local function get_client(buf) return LazyVim.lsp.get_clients({ name = "eslint", bufnr = buf })[1] end
  --   local formatter = LazyVim.lsp.formatter({
  --     name = "eslint: lsp",
  --     primary = false,
  --     priority = 200,
  --     filter = "eslint",
  --   })
  --   if not pcall(require, "vim.lsp._dynamic") then
  --     formatter.name = "eslint: EslintFixAll"
  --     formatter.sources = function(buf)
  --       local client = get_client(buf)
  --       return client and { "eslint" } or {}
  --     end
  --     formatter.format = function(buf)
  --       local client = get_client(buf)
  --       if client then
  --         local diag = vim.diagnostic.get(buf, { namespace = vim.lsp.diagnostic.get_namespace(client.id) })
  --         if #diag > 0 then vim.cmd("EslintFixAll") end
  --       end
  --     end
  --   end
  --   LazyVim.format.register(formatter)
  -- end,
-- }

return config
