-- Teaches lua_ls about the Neovim runtime, lazy.nvim plugin sources, and any
-- library only required at runtime — so editing THIS config gets real completion,
-- go-to-definition and signature help instead of "undefined global vim".
--
-- Only loads for Lua buffers; costs nothing elsewhere.
return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
      -- Load luvit types when the `vim.uv` word is found.
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      -- Type definitions for the plugins configured here.
      { path = 'snacks.nvim', words = { 'Snacks' } },
      { path = 'lazy.nvim', words = { 'LazySpec' } },
    },
  },
}
