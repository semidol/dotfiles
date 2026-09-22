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

-- Cyrillic input lives inside Vim, so the OS layout can stay English
-- and normal-mode motions keep working. Toggle with <C-^> in insert mode.
local IM_DISABLED = 0
local IM_FOLLOWS_INSERT = -1

vim.o.keymap = 'russian-jcukenwin'
vim.o.iminsert = IM_DISABLED
vim.o.imsearch = IM_FOLLOWS_INSERT
