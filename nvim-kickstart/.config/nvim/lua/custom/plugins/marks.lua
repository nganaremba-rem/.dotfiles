-- Mark signs in the gutter. This plugin owns ONLY the MarkSign* highlights —
-- `signcolumn` is set in custom/config/options.lua and the global SignColumn /
-- LineNr / CursorLineNr transparency comes from tokyonight's `on_highlights`
-- (custom/plugins/tokyonight.lua). Setting those here fought the colorscheme and
-- broke on any theme switch.
return {
  'chentoast/marks.nvim',
  event = 'BufReadPost',

  opts = {
    -- Default mappings shadow built-in mark motions — leave them off.
    default_mappings = false,

    -- Also sign the useful built-in marks.
    builtin_marks = { '.', '<', '>', '^' },

    cyclic = true,
    refresh_interval = 100,

    sign_priority = {
      lower = 10,
      upper = 15,
      builtin = 8,
      bookmark = 20,
    },
  },

  config = function(_, opts)
    require('marks').setup(opts)

    -- Colours come from the active colorscheme, not hardcoded hexes.
    local ok, colors = pcall(function() return require('tokyonight.colors').setup() end)
    if not ok then return end

    local hl = vim.api.nvim_set_hl
    local groups = {
      -- lowercase marks (a, b, c)
      MarkSignHL = colors.green,
      MarkSignNumHL = colors.green,
      -- uppercase marks (A, B, C)
      MarkSignHLUpper = colors.yellow,
      MarkSignNumHLUpper = colors.yellow,
      -- built-in marks (., ^, <, >)
      MarkSignHLBuiltin = colors.blue,
      MarkSignNumHLBuiltin = colors.blue,
    }
    for group, fg in pairs(groups) do
      hl(0, group, { fg = fg, bg = 'none' })
    end
  end,
}
