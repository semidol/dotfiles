-- Duplicates every mapping onto Cyrillic keys, which 'langmap' does not
-- cover. Loads before other plugins so their mappings get translated too.
local LOAD_BEFORE_OTHER_PLUGINS = 10000

return {
  'Wansmer/langmapper.nvim',
  lazy = false,
  priority = LOAD_BEFORE_OTHER_PLUGINS,
  config = function()
    local russian_layout = require 'config.russian_layout'

    require('langmapper').setup {
      default_layout = russian_layout.latin_upper .. russian_layout.latin_lower,
      layouts = {
        ru = {
          id = 'ru',
          layout = russian_layout.cyrillic_upper .. russian_layout.cyrillic_lower,
        },
      },
    }
  end,
}
