-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false

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

vim.keymap.set('n', '<leader>tm', function()
  require('render-markdown').toggle()
end, { desc = '[T]oggle [M]arkdown preview' })

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

require('lazy').setup({
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        graphql = { 'prettier' },
        json = { 'prettier' },
        solidity = { 'forge' },
      },
      formatters = {
        prettier = {
          prepend_args = { '--ignore-path', '.prettierignore' },
        },
        forge = {
          command = 'forge',
          args = { 'fmt', '$FILENAME' },
          stdin = false,
        },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load { include = { 'markdown' } }
            end,
          },
        },
        opts = {},
        config = function()
          local ls = require 'luasnip'
          local s = ls.snippet
          local t = ls.text_node
          local i = ls.insert_node

          -- Add custom snippets
          ls.add_snippets('javascript', {
            s('clog', {
              t 'console.log(',
              i(1),
              t ')',
            }),
            s('main', {
              t { 'async function main() {', '\t' },
              i(0),
              t { '', '}', '', 'void main()' },
            }),
            s('jsdoc', {
              t { '/**', ' * ' },
              i(1, 'Description'),
              t { '', ' * @param ' },
              i(2, 'name'),
              t ' ',
              i(3, 'parameter description'),
              t { '', ' * @returns ' },
              i(4, 'return description'),
              t { '', ' */' },
            }),
            s('save', {
              t { "const fs = await import('fs')", "fs.writeFileSync('data.json', JSON.stringify(" },
              i(0),
              t ', null, 4))',
            }),
            s('inspect', {
              t { "const { inspect } = await import('util')", 'console.log(inspect(' },
              i(0),
              t ', { depth: null, colors: true }))',
            }),
            s('nest app', {
              t {
                "import { Module } from '@nestjs/common'",
                "import { NestFactory } from '@nestjs/core'",
                '',
                '@Module({',
                '\timports: [],',
                '\tproviders: [],',
                '})',
              },
              t {
                '',
                'class AppModule {}',
                '',
                'async function main() {',
                '\tconst app = await NestFactory.createApplicationContext(AppModule)',
                '}',
                '',
                'void main()',
              },
            }),
            s('nest module', {
              t { "import { Module } from '@nestjs/common'", '', '@Module({', '\timports: [],', '\tproviders: [],', '\texports:[]', '})' },
              t { '', 'export class ' },
              i(1),
              t 'Module {}',
            }),
            s('nest injectable', {
              t { "import { Injectable } from '@nestjs/common';", '', '@Injectable()', 'export class ' },
              i(1, 'ClassName'),
              t { ' {', '  ' },
              i(0),
              t { '', '}' },
            }),
          })

          ls.add_snippets('typescript', {
            s('clog', {
              t 'console.log(',
              i(1),
              t ')',
            }),
            s('main', {
              t { 'async function main() {', '\t' },
              i(0),
              t { '', '}', '', 'void main()' },
            }),
            s('jsdoc', {
              t { '/**', ' * ' },
              i(1, 'Description'),
              t { '', ' * @param ' },
              i(2, 'name'),
              t ' ',
              i(3, 'parameter description'),
              t { '', ' * @returns ' },
              i(4, 'return description'),
              t { '', ' */' },
            }),
            s('save', {
              t { "const fs = await import('fs')", "fs.writeFileSync('data.json', JSON.stringify(" },
              i(0),
              t ', null, 4))',
            }),
            s('inspect', {
              t { "const { inspect } = await import('util')", 'console.log(inspect(' },
              i(0),
              t ', { depth: null, colors: true }))',
            }),
            s('nest app', {
              t {
                "import { Module } from '@nestjs/common'",
                "import { NestFactory } from '@nestjs/core'",
                '',
                '@Module({',
                '\timports: [],',
                '\tproviders: [],',
                '})',
              },
              t {
                '',
                'class AppModule {}',
                '',
                'async function main() {',
                '\tconst app = await NestFactory.createApplicationContext(AppModule)',
                '}',
                '',
                'void main()',
              },
            }),
            s('nest module', {
              t { "import { Module } from '@nestjs/common'", '', '@Module({', '\timports: [],', '\tproviders: [],', '\texports:[]', '})' },
              t { '', 'export class ' },
              i(1),
              t 'Module {}',
            }),
            s('nest injectable', {
              t { "import { Injectable } from '@nestjs/common';", '', '@Injectable()', 'export class ' },
              i(1, 'ClassName'),
              t { ' {', '  ' },
              i(0),
              t { '', '}' },
            }),
          })
        end,
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'enter',
        -- Scroll documentation window
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'lua' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },

  -- { -- You can easily change to a different colorscheme.
  --   -- Change the name of the colorscheme plugin below, and then
  --   -- change the command in the config to whatever the name of that colorscheme is.
  --   --
  --   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  --   'folke/tokyonight.nvim',
  --   priority = 1000, -- Make sure to load this before all the other start plugins.
  --   config = function()
  --     ---@diagnostic disable-next-line: missing-fields
  --     require('tokyonight').setup {
  --       styles = {
  --         comments = { italic = false }, -- Disable italics in comments
  --       },
  --     }
  --
  --     -- Load the colorscheme here.
  --     -- Like many other themes, this one has different styles, and you could load
  --     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
  --     vim.cmd.colorscheme 'tokyonight-night'
  --   end,
  -- },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'dockerfile', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'mermaid', 'query', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        disable = { 'mermaid', 'dockerfile' },
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)

      -- Neovim 0.12 fix: nvim-treesitter's `#set-lang-from-info-string!` directive
      -- is broken and never spawns the fenced-code child parser, so code blocks
      -- (and LSP hover signatures) fall back to @markup.raw.block (green).
      -- Override the markdown injections query to read the language node directly.
      local markdown_injections = [[
        (fenced_code_block
          (info_string
            (language) @injection.language)
          (code_fence_content) @injection.content)

        ((html_block) @injection.content
          (#set! injection.language "html")
          (#set! injection.combined)
          (#set! injection.include-children))

        ((minus_metadata) @injection.content
          (#set! injection.language "yaml")
          (#offset! @injection.content 1 0 -1 0)
          (#set! injection.include-children))

        ((plus_metadata) @injection.content
          (#set! injection.language "toml")
          (#offset! @injection.content 1 0 -1 0)
          (#set! injection.include-children))

        ([
          (inline)
          (pipe_table_cell)
        ] @injection.content
          (#set! injection.language "markdown_inline"))
      ]]

      vim.treesitter.query.set('markdown', 'injections', markdown_injections)
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',

  { import = 'plugins' },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
    config = function()
      local hooks = require 'ibl.hooks'
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'IblScope', { fg = '#7d7d8c' })
      end)
      require('ibl').setup {
        indent = { char = '▏', tab_char = '▏' },
        scope = {
          show_end = false,
          show_start = false,
          include = { node_type = { ['*'] = { '*' } } },
        },
      }
    end,
  },

  {
    'Aasim-A/scrollEOF.nvim',
    event = { 'CursorMoved', 'WinScrolled' },
    opts = {},
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    -- nvim 0.12 bug: stale TSNode userdata crashes set-lang-from-info-string!.
    -- patched in: nvim-treesitter/lua/nvim-treesitter/query_predicates.lua:135
    --   guard get_node_text in pcall; do NOT skip on `not node.range`
    --   (that drops injection.language and turns LSP hover code green).
    -- reapply after `nvim-treesitter` updates.
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      restart_highlighter = true,
      render_modes = { 'n', 'c', 't' },
      heading = {
        backgrounds = {},
        signs = {},
      },
      pipe_table = {
        cell = 'trimmed',
      },
      -- LSP hover/signature floats are `nofile` buffers; hide the language
      -- label there while keeping it in real markdown files.
      overrides = {
        buftype = {
          nofile = {
            code = {
              language_name = false,
              language_icon = false,
              sign = false,
            },
          },
        },
      },
    },
  },

  -- {
  --   'mracos/mermaid.vim',
  --   ft = { 'mermaid' },
  -- },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
