local FORMAT_ON_SAVE_TIMEOUT_MS = 500

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = {
      timeout_ms = FORMAT_ON_SAVE_TIMEOUT_MS,
      lsp_format = 'fallback',
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'prettier' },
      typescript = { 'prettier' },
      graphql = { 'prettier' },
      json = { 'prettier' },
      solidity = { 'forge' },
      -- rustfmt comes from the rustup toolchain, not mason
      rust = { 'rustfmt' },
    },
    formatters = {
      prettier = {
        prepend_args = { '--ignore-path', '.prettierignore' },
      },
      forge = {
        command = 'forge',
        args = { 'fmt', '$FILENAME' },
        stdin = false,
      },
    },
  },
}
