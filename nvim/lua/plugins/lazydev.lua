return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
      -- load luv (libuv) type definitions bundled with lua_ls when `vim.uv` is used
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  },
}
