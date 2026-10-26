vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

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

vim.keymap.set({ 'c', 'i' }, '<M-Right>', '<S-Right>', { desc = 'Move word right' })
vim.keymap.set({ 'c', 'i' }, '<M-Left>', '<S-Left>', { desc = 'Move word left' })

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
end, { desc = '[C]opy file path with line number' })

vim.keymap.set('n', '<leader>c', function()
  copy_file_path(false)
end, { desc = '[C]opy file path' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
