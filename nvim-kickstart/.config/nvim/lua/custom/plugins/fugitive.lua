return {
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Gwrite', 'Gread', 'GBrowse', 'Gdiffsplit', 'Gvdiffsplit', 'Gedit', 'GMove', 'GDelete', 'GRemove' },
    keys = {
      { '<leader>gs', '<cmd>Git<cr>',                       desc = 'Git status' },
      { '<leader>gb', '<cmd>Git blame<cr>',                 desc = 'Git blame' },
      { '<leader>gl', '<cmd>Git log --oneline --graph<cr>', desc = 'Git log' },
      { '<leader>gw', '<cmd>Gwrite<cr>',                    desc = 'Git stage file' },
      { '<leader>gr', '<cmd>Gread<cr>',                     desc = 'Git restore file' },
      { '<leader>gv', '<cmd>Gvdiffsplit<cr>',               desc = 'Git diff (vsplit)' },
      { '<leader>gC', '<cmd>Git commit<cr>',                desc = 'Git commit' },
      { '<leader>gp', '<cmd>Git push<cr>',                  desc = 'Git push' },
      { '<leader>gP', '<cmd>Git pull<cr>',                  desc = 'Git pull' },
      -- <leader>gB lives in snacks.lua (Snacks.gitbrowse, no vim-rhubarb needed).
      -- Binding :GBrowse here too made the winner depend on load order.
    },
  },
  -- GBrowse support for GitHub repos
  { 'tpope/vim-rhubarb', lazy = true },
}
