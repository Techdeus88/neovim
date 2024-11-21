local config = {}


config.rust = function()
  return {
    add = { source = 'mrcjkb/rustaceanvim', depends = {}, checkout = "version '^5'" },
    require = "",
    type = "no-setup",
    mason = function() return { config = require("lsp-zero").noop } end,
    load = 'now',
    s_load = 'later',
    setup_opts = function() -- no setup
    end,
    on_attach = function(event)
      vim.keymap.set(
        "n",
        "<leader>a",
        function()
          vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
          -- or vim.lsp.buf.codeAction() if you don't want grouping.
        end,
        { silent = true, buffer = event.bufnr }
      )
      vim.keymap.set(
        "n",
        "K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
        function()
          vim.cmd.RustLsp({ 'hover', 'actions' })
        end,
        { silent = true, buffer = event.bufnr }
      )
    end,
  }
end

return config
