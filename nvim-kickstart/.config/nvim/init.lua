vim.loader.enable() -- cache compiled Lua modules to ~/.cache/nvim/luac/

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mkdp_port = '8989'

vim.keymap.set('n', 'Z', function()
  Snacks.picker.zoxide {
    title = 'Zoxide',
    confirm = function(picker, item)
      picker:close()
      if item then vim.cmd('cd ' .. vim.fn.fnameescape(item.file)) end
    end,
  }
end, { desc = 'Zoxide' })

require 'custom.config.options'
require 'custom.config.keymaps'
require 'custom.config.lazy'
require 'custom.config.autocmds'
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--
