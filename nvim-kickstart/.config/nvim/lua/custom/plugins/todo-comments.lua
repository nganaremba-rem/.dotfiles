return {
  'folke/todo-comments.nvim',
  -- Was `VimEnter`, which loaded it during startup even for an empty session.
  -- It only ever acts on a real buffer, so trigger on one.
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  -- NOTE: no <leader>st here — `:TodoTelescope` died with telescope, and snacks
  -- has no todo picker. Trouble is the list; `<leader>sg` greps for the keywords.
  keys = {
    { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todo comments (Trouble)' },
    { ']t', function() require('todo-comments').jump_next() end, desc = 'Next todo comment' },
    { '[t', function() require('todo-comments').jump_prev() end, desc = 'Prev todo comment' },
  },
  ---@module 'todo-comments'
  ---@type TodoOptions
  ---@diagnostic disable-next-line: missing-fields
  opts = { signs = false },
}
