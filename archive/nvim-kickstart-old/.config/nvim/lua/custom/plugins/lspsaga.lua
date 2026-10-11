return {
  {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach', -- or "BufRead"
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      {
        'K',
        '<cmd>Lspsaga hover_doc<CR>',
        desc = 'Hover docs',
      },
      {
        '<leader>ca',
        vim.lsp.buf.code_action,
        desc = 'Code Actions',
      },
      {
        'gd',
        '<cmd>Lspsaga goto_definition<CR>',
        desc = 'Goto definition',
      },
      {
        'gp',
        '<cmd>Lspsaga peek_definition<CR>',
        desc = 'Peek definition',
      },
      {
        'gt',
        '<cmd>Lspsaga peek_type_definition<CR>',
        desc = 'Peek type definition',
      },
    },
    opts = {
      lightbulb = {
        enable = false,
      },
    },
  },
}
