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

    -- Tokyonight palette (matches the active colorscheme)
    -- lowercase marks (a, b, c) — green
    hl(0, 'MarkSignHL', { fg = '#9ece6a', bg = 'none' })
    hl(0, 'MarkSignNumHL', { fg = '#9ece6a', bg = 'none' })

    -- uppercase marks (A, B, C) — yellow/orange
    hl(0, 'MarkSignHLUpper', { fg = '#e0af68', bg = 'none' })
    hl(0, 'MarkSignNumHLUpper', { fg = '#e0af68', bg = 'none' })

    -- built-in marks (., ^, etc.) — blue
    hl(0, 'MarkSignHLBuiltin', { fg = '#7aa2f7', bg = 'none' })
    hl(0, 'MarkSignNumHLBuiltin', { fg = '#7aa2f7', bg = 'none' })

    -- 🔥 FULL transparency (important for you)
    hl(0, 'SignColumn', { bg = 'none' })
    hl(0, 'LineNr', { bg = 'none' })
    hl(0, 'CursorLineNr', { bg = 'none' })
  end,
}
