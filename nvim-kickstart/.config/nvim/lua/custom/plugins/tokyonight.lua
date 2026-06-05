return {
  'folke/tokyonight.nvim',
  priority = 1000,
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('tokyonight').setup {
      transparent = true,
      style = 'night', -- storm | night | moon | day
      styles = {
        comments = { italic = false }, -- Disable italics in comments
        sidebars = 'transparent',
        floats = 'transparent',
      },
      on_highlights = function(hl, c)
        -- Cursorline
        hl.CursorLine = { bg = c.bg_highlight }
        hl.CursorLineNr = { fg = c.blue, bold = true }

        -- Bufferline
        hl.BufferLineFill = { bg = 'NONE' }
        hl.BufferLineBackground = { bg = 'NONE' }
        hl.BufferLineBufferSelected = { bg = 'NONE', bold = true }
        hl.BufferLineBufferVisible = { bg = 'NONE' }
        hl.BufferLineSeparator = { bg = 'NONE', fg = 'NONE' }
        hl.BufferLineIndicatorSelected = { fg = c.blue }

        -- Lualine (statusline)
        hl.StatusLine = { bg = 'NONE' }
        hl.StatusLineNC = { bg = 'NONE' }
      end,
    }

    -- Load the colorscheme here.
    -- Like many other themes, this one has different styles, and you could load
    -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
    vim.cmd.colorscheme 'tokyonight-night'

    -- require('custom.config.transparent').apply()
  end,
}
