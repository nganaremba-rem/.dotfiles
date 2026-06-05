return {
  'mbbill/undotree',
  keys = {
    { '<leader>uu', '<cmd>UndotreeToggle<cr>', desc = 'Toggle undo tree' },
  },
  config = function()
    vim.g.undotree_WindowLayout       = 2  -- diff at bottom, tree on left
    vim.g.undotree_SetFocusWhenToggle = 1  -- auto-focus tree when opened
    vim.g.undotree_ShortIndicators    = 1  -- compact time indicators
    vim.g.undotree_HelpLine           = 0  -- hide help line (press ? for help)
    vim.g.undotree_SplitWidth         = 30
  end,
}
