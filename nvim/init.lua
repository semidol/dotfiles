-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'config.options'

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Toggle quickfix list
vim.keymap.set('n', '<leader>tq', function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd 'cclose'
  else
    vim.cmd 'copen'
  end
end, { desc = '[T]oggle [Q]uickfix list' })

local saved_virtual_text

vim.keymap.set('n', '<leader>tt', function()
  local current = vim.diagnostic.config().virtual_text

  if current then
    saved_virtual_text = current
    vim.diagnostic.config { virtual_text = false }
  else
    vim.diagnostic.config { virtual_text = saved_virtual_text or true }
  end
end, { desc = '[T]oggle virtual [T]ext' })

vim.keymap.set('n', '<C-s>', ':w<CR>', { desc = 'Save file' })

vim.keymap.set('c', '<M-Right>', '<S-Right>')
vim.keymap.set('c', '<M-Left>', '<S-Left>')
vim.keymap.set('i', '<M-Right>', '<S-Right>')
vim.keymap.set('i', '<M-Left>', '<S-Left>')

local function copy_file_path(with_line)
  local file_path = vim.fn.expand '%:p:~'

  if file_path == '' then
    vim.notify('Buffer has no file', vim.log.levels.WARN)
    return
  end

  if with_line then
    file_path = file_path .. ':' .. vim.fn.line '.'
  end

  vim.fn.setreg('+', file_path)
  print('Copied: ' .. file_path)
end

vim.keymap.set('n', '<leader>C', function()
  copy_file_path(true)
end, { desc = '[c]opy file path with line number' })

vim.keymap.set('n', '<leader>c', function()
  copy_file_path(false)
end, { desc = '[c]opy file path' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup {
  { import = 'plugins' },
}
