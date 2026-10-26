-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.lazy'

-- Translate mappings created before langmapper was loaded (config.keymaps, built-ins)
require('langmapper').automapping { global = true, buffer = false }
