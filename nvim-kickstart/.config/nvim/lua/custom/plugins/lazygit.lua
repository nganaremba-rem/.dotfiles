-- lazygit hangs when EDITOR=nvim spawns a nested nvim inside the terminal, deadlocking
-- the outer nvim. Fix: pass NVIM_LISTEN_ADDRESS so lazygit uses nvim --remote instead
-- (editPreset: nvim-remote in ~/.config/lazygit/config.yml opens files in outer nvim).
local lazygit_term

return {
  'akinsho/toggleterm.nvim',
  optional = true,
  keys = {
    {
      '<leader>lg',
      function()
        if not lazygit_term then
          lazygit_term = require('toggleterm.terminal').Terminal:new {
            cmd = 'lazygit',
            hidden = true,
            direction = 'float',
            float_opts = { border = 'rounded' },
            close_on_exit = true,
            env = {
              NVIM_LISTEN_ADDRESS = vim.v.servername,
            },
            on_open = function(term)
              vim.schedule(function()
                vim.cmd 'startinsert!'
                vim.keymap.set('n', 'q', '<nop>', { buffer = term.bufnr })
              end)
            end,
            on_close = function()
              vim.cmd.checktime()
            end,
          }
        end
        lazygit_term:toggle()
      end,
      desc = 'LazyGit',
    },
  },
}
