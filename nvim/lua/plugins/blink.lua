return { -- Autocompletion
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
}
