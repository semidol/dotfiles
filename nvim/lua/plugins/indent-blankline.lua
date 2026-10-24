-- indent-blankline
-- https://github.com/lukas-reineke/indent-blankline.nvim

local INDENT_CHAR = '▏'

return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    indent = { char = INDENT_CHAR, tab_char = INDENT_CHAR },
    scope = {
      show_end = false,
      show_start = false,
      include = { node_type = { ['*'] = { '*' } } },
    },
  },
}
