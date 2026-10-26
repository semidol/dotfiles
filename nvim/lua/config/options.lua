vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.linebreak = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'

vim.o.updatetime = 150
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.tabstop = 4 -- ideally to replace to 8, but current projects uses tabs
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.guicursor = ''
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.clipboard = 'unnamedplus'

-- Normal-mode commands work in the Russian layout: each Cyrillic letter
-- acts as the Latin key at the same position. Insert and command-line
-- modes still type whatever the OS layout produces. Mappings are
-- translated separately by langmapper.nvim.
local russian_layout = require 'config.russian_layout'

local function escape_langmap(chars)
  return (chars:gsub('[;,"\\]', '\\%0'))
end

local function langmap_pair(from, to)
  return escape_langmap(from) .. ';' .. escape_langmap(to)
end

vim.o.langmap = langmap_pair(russian_layout.cyrillic_upper, russian_layout.latin_upper)
  .. ','
  .. langmap_pair(russian_layout.cyrillic_lower, russian_layout.latin_lower)
