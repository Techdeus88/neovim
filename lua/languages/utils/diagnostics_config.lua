local M = {}

M.shared_config = {
  padding = {
    pad_top = 1,
    pad_bottom = 1,
    pad_right = 3,
    pad_left = 3,
  },
  floating = {
    max_width = 130,
    border = 'rounded',
    style = 'minimal',
  },
  severity_highlights = {
    [vim.diagnostic.severity.ERROR] = 'DiagnosticError',
    [vim.diagnostic.severity.WARN] = 'DiagnosticWarn',
    [vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
    [vim.diagnostic.severity.HINT] = 'DiagnosticHint',
  }
}

return M