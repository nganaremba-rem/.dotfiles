-- Disabled: using tokyonight instead.
return {
  'catppuccin/nvim',
  name = 'catppuccin',
  enabled = false,
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha',
      transparent_background = true,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = { enabled = false },
      styles = {
        comments = { 'italic' },
        conditionals = {},
        keywords = {},
        functions = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        types = {},
      },
      custom_highlights = function(c)
        return {
          CursorLine    = { bg = c.surface0 },
          CursorLineNr  = { fg = c.blue, bold = true },
          StatusLine    = { bg = 'NONE' },
          StatusLineNC  = { bg = 'NONE' },
        }
      end,
      integrations = {
        blink_cmp         = true,
        bufferline        = true,
        gitsigns          = true,
        harpoon           = true,
        indent_blankline  = { enabled = true },
        lspsaga           = true,
        mason             = true,
        mini              = { enabled = true },
        neo_tree          = true,
        noice             = true,
        notify            = true,
        telescope         = { enabled = true },
        treesitter        = true,
        which_key         = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors      = { 'underline' },
            hints       = { 'underline' },
            warnings    = { 'underline' },
            information = { 'underline' },
          },
        },
      },
    }
    vim.cmd.colorscheme 'catppuccin'
  end,
}
