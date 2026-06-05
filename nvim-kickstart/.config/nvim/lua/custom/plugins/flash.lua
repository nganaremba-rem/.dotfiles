-- Disabled: use default f/t/s motions.
return {
  'folke/flash.nvim',
  enabled = false,
  event = 'VeryLazy',
  ---@type Flash.Config
  opts = {
    -- highlight matched chars + jump labels
    highlight = { backdrop = true },
    -- jump config
    jump = { autojump = false },
    label = {
      uppercase = false,
      -- exclude easy-to-confuse chars
      exclude = 'hjkliardc',
    },
    modes = {
      -- f/F/t/T enhancements: show labels when there are multiple matches
      char = {
        enabled    = true,
        jump_labels = true,
        -- multi-line f/t search
        multi_line = false,
      },
      -- / and ? search: <C-s> to toggle labels during search
      search = { enabled = true },
    },
  },
  keys = {
    -- s: jump to any 2-char match on screen (replaces vim's s = cl)
    { 's',     function() require('flash').jump() end,              mode = { 'n', 'x', 'o' }, desc = 'Flash jump' },
    -- S: select a treesitter node visually
    { 'S',     function() require('flash').treesitter() end,        mode = { 'n', 'x', 'o' }, desc = 'Flash treesitter' },
    -- r (operator-pending): remote flash — apply operator to distant text without moving cursor
    { 'r',     function() require('flash').remote() end,            mode = 'o',               desc = 'Flash remote' },
    -- R (operator-pending / visual): treesitter search
    { 'R',     function() require('flash').treesitter_search() end, mode = { 'o', 'x' },      desc = 'Flash treesitter search' },
    -- <C-s> in / or ? search: toggle flash labels on current search
    { '<c-s>', function() require('flash').toggle() end,            mode = 'c',               desc = 'Toggle flash search' },
  },
}
