-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'config.options'

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show [D]iagnostic' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Toggle quickfix list
vim.keymap.set('n', '<leader>tq', function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd 'cclose'
  else
    vim.cmd 'copen'
  end
end, { desc = '[T]oggle [Q]uickfix list' })

-- Toggle virtual text
vim.keymap.set('n', '<leader>tt', function()
  local config = vim.diagnostic.config()
  vim.diagnostic.config { virtual_text = not config.virtual_text }
end, { desc = '[T]oggle virtual [T]ext' })

vim.keymap.set('n', '<C-s>', ':w<CR>', { desc = 'Save file' })

vim.keymap.set('c', '<M-Right>', '<S-Right>')
vim.keymap.set('c', '<M-Left>', '<S-Left>')
vim.keymap.set('i', '<M-Right>', '<S-Right>')
vim.keymap.set('i', '<M-Left>', '<S-Left>')

local function current_file_path()
  local file_path = vim.fn.expand '%:p'
  local home = vim.loop.os_homedir()

  if home and file_path:sub(1, #home) == home then
    return '~' .. file_path:sub(#home + 1)
  end

  return file_path
end

-- Copy file path and line number to clipboard
vim.keymap.set('n', '<leader>C', function()
  local path_with_line = current_file_path() .. ':' .. vim.fn.line '.'
  vim.fn.setreg('+', path_with_line)
  print('Copied: ' .. path_with_line)
end, { desc = '[c]opy file path with line number' })

-- Copy file path to clipboard
vim.keymap.set('n', '<leader>c', function()
  local file_path = current_file_path()
  vim.fn.setreg('+', file_path)
  print('Copied: ' .. file_path)
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
