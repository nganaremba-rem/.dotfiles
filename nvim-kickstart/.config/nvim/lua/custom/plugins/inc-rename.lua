-- Live-preview LSP rename. Moved off <leader>rn (that prefix is now the run group)
-- into the <leader>c code group, next to ca / cd / cf / co / cs.
return {
  'smjonas/inc-rename.nvim',
  cmd = 'IncRename',
  keys = {
    {
      '<leader>cr',
      function() return ':IncRename ' .. vim.fn.expand '<cword>' end,
      expr = true,
      desc = 'Code: [r]ename symbol (live preview)',
    },
  },
  opts = {},
}
