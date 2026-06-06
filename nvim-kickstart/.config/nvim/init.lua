vim.loader.enable() -- cache compiled Lua modules to ~/.cache/nvim/luac/

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mkdp_port = '8989'

require 'custom.config.options'
require 'custom.config.keymaps'
require 'custom.config.lazy'
require 'custom.config.autocmds'
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
