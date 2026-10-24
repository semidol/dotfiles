-- render-markdown
-- https://github.com/MeanderingProgrammer/render-markdown.nvim

return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown' },
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    restart_highlighter = true,
    render_modes = { 'n', 'c', 't' },
    heading = {
      backgrounds = {},
      signs = {},
    },
    pipe_table = {
      cell = 'trimmed',
    },
    -- LSP hover/signature floats are `nofile` buffers; hide the language
    -- label there while keeping it in real markdown files.
    overrides = {
      buftype = {
        nofile = {
          code = {
            language_name = false,
            language_icon = false,
            sign = false,
          },
        },
      },
    },
  },
}
