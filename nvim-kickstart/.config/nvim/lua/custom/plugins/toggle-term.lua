return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      --[[ things you want to change go here]]
    },
    keys = {
      {
        '<C-\\>',
        '<cmd>ToggleTerm<cr>',
        mode = {
          'n',
          't',
        },
        desc = 'Toggle Terminal',
      },
    },
    config = function()
      require('toggleterm').setup {
        shade_terminals = false,
      }
    end,
  },
}
