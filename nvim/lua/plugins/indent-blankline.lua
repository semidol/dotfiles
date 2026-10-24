-- indent-blankline
-- https://github.com/lukas-reineke/indent-blankline.nvim

local SCOPE_FG = '#7d7d8c'
local INDENT_CHAR = '▏'

return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  ---@module "ibl"
  ---@type ibl.config
  opts = {},
  config = function()
    local hooks = require 'ibl.hooks'
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, 'IblScope', { fg = SCOPE_FG })
    end)

    require('ibl').setup {
      indent = { char = INDENT_CHAR, tab_char = INDENT_CHAR },
      scope = {
        show_end = false,
        show_start = false,
        include = { node_type = { ['*'] = { '*' } } },
      },
    }
  end,
}
