-- Languages often embedded in other files, so FileType auto-install won't catch them
local ENSURE_INSTALLED = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }

local function try_attach(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  if not vim.treesitter.language.add(lang) then
    return
  end

  vim.treesitter.start(buf, lang)

  if vim.treesitter.query.get(lang, 'indents') then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local ts = require 'nvim-treesitter'

    ts.install(ENSURE_INSTALLED)

    local available = ts.get_available()

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
          return
        end

        local installed = vim.list_contains(ts.get_installed 'parsers', lang)
        if not installed and vim.list_contains(available, lang) then
          ts.install(lang):await(function()
            try_attach(args.buf, lang)
          end)
          return
        end

        try_attach(args.buf, lang)
      end,
    })
  end,
}
