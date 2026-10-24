local LOAD_BEFORE_OTHER_PLUGINS_PRIORITY = 1000

return {
  'navarasu/onedark.nvim',
  priority = LOAD_BEFORE_OTHER_PLUGINS_PRIORITY,
  config = function()
    require('onedark').setup {
      style = 'dark',

      code_style = {
        comments = 'none',
      },

      colors = {
        fg = '#ABB2BF',
        light_grey = '#a7aab0',
        bg0 = '#1E1E1E', -- main editor background
      },

      highlights = {
        IblScope = { fg = '#7d7d8c' },
      },
    }

    require('onedark').load()
  end,
}
