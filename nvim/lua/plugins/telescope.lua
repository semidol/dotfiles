-- Fuzzy Finder (files, lsp, etc)
return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      defaults = {
        path_display = { 'smart' },
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', function()
      builtin.live_grep {
        additional_args = { '--hidden' },
        attach_mappings = function(prompt_bufnr, map)
          map('i', '<C-f>', function()
            local search_dir = vim.fn.input 'Filter directory: '
            if search_dir ~= '' then
              local current_query = require('telescope.actions.state').get_current_picker(prompt_bufnr):_get_prompt()
              require('telescope.actions').close(prompt_bufnr)
              builtin.live_grep { search_dirs = { search_dir }, default_text = current_query }
            end
          end)
          return true
        end,
      }
    end, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>sc', builtin.git_status, { desc = '[S]earch [C]hanges (git status)' })
    vim.keymap.set('n', '<leader>sq', builtin.quickfix, { desc = '[S]earch [Q]uickfix list' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    vim.keymap.set('n', '<leader>p', function()
      builtin.find_files { file_ignore_patterns = { '%.git/', 'lib/' }, hidden = true }
    end, { desc = 'Find files' })

    vim.keymap.set('n', '<leader>sp', function()
      builtin.find_files {
        hidden = true,
        no_ignore = true,
        attach_mappings = function(prompt_bufnr, map)
          map('i', '<C-f>', function()
            local action_state = require 'telescope.actions.state'
            local finders = require 'telescope.finders'
            local search_dir = vim.fn.input 'Filter directory: '
            if search_dir ~= '' then
              local picker = action_state.get_current_picker(prompt_bufnr)
              picker:refresh(
                finders.new_oneshot_job(
                  { 'fd', '--type', 'f', '--hidden', '--no-ignore', '.', search_dir },
                  { entry_maker = require('telescope.make_entry').gen_from_file() }
                )
              )
            end
          end)
          return true
        end,
      }
    end, { desc = 'Find all files' })
  end,
}
