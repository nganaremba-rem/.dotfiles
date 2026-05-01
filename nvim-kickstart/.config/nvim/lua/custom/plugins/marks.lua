return {
  'chentoast/marks.nvim',

  -- modern lazy.nvim trigger
  event = 'BufReadPost',

  opts = {
    -- ❌ disable default mappings (they override built-ins)
    default_mappings = false,

    -- ✅ show important built-in marks too
    builtin_marks = { '.', '<', '>', '^' },

    cyclic = true,

    -- 🔥 performance + smooth updates
    refresh_interval = 100,

    sign_priority = {
      lower = 10,
      upper = 15,
      builtin = 8,
      bookmark = 20,
    },
  },

  config = function(_, opts)
    local marks = require 'marks'
    marks.setup(opts)

    -- ✅ ALWAYS show sign column (modern recommended)
    vim.opt.signcolumn = 'yes:1'

    -- 🎯 MODERN highlight (transparent + clean)
    local hl = vim.api.nvim_set_hl

    -- lowercase marks (a, b, c)
    hl(0, 'MarkSignHL', { fg = '#a6e3a1', bg = 'none' })
    hl(0, 'MarkSignNumHL', { fg = '#a6e3a1', bg = 'none' })

    -- uppercase marks (A, B, C)
    hl(0, 'MarkSignHLUpper', { fg = '#f9e2af', bg = 'none' })
    hl(0, 'MarkSignNumHLUpper', { fg = '#f9e2af', bg = 'none' })

    -- built-in marks (., ^, etc.)
    hl(0, 'MarkSignHLBuiltin', { fg = '#89b4fa', bg = 'none' })
    hl(0, 'MarkSignNumHLBuiltin', { fg = '#89b4fa', bg = 'none' })

    -- 🔥 FULL transparency (important for you)
    hl(0, 'SignColumn', { bg = 'none' })
    hl(0, 'LineNr', { bg = 'none' })
    hl(0, 'CursorLineNr', { bg = 'none' })
  end,
}
