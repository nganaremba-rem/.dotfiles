return {
  {
    'MagicDuck/grug-far.nvim',
    -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
    -- additional lazy config to defer loading is not really needed...
    keys = {
      -- NOTE: `desc` must be a field on this entry. Passing `{ desc = ... }` as a
      -- third positional element makes lazy.nvim drop it silently.
      {
        '<leader>fr',
        function() require('grug-far').open() end,
        desc = 'Find and [r]eplace (project-wide)',
      },
      {
        '<leader>fw',
        function() require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } } end,
        desc = 'Find and replace current [w]ord',
      },
    },
    config = function()
      -- optional setup call to override plugin options
      -- alternatively you can set options with vim.g.grug_far = { ... }
      require('grug-far').setup {
        -- options, see Configuration section below
        -- there are no required options atm
      }
    end,
  },
}
