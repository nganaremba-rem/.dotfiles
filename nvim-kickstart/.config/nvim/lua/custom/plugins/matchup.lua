return { -- `%` matching for JSX/HTML tags (incl. self-closing) via treesitter
  'andymass/vim-matchup',
  event = 'VeryLazy',
  init = function()
    vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    -- treesitter-backed matching (needed for JSX tags, incl. self-closing)
    vim.g.matchup_matchparen_deferred = 1
    vim.g.matchup_surround_enabled = 1
  end,
}
