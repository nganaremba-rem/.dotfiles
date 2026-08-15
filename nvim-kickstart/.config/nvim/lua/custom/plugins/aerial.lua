return {
  'stevearc/aerial.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  keys = {
    -- Moved off <leader>a to avoid colliding with avante.nvim's <leader>a… group.
    { '<leader>cs', '<cmd>AerialToggle!<cr>', desc = 'Toggle code [s]ymbols outline (Aerial)' },
    { '[[',         '<cmd>AerialPrev<cr>',    desc = 'Prev symbol' },
    { ']]',         '<cmd>AerialNext<cr>',    desc = 'Next symbol' },
    { '[A',         '<cmd>AerialPrevUp<cr>',  desc = 'Prev symbol (up a level)' },
    { ']A',         '<cmd>AerialNextUp<cr>',  desc = 'Next symbol (up a level)' },
  },
  opts = {
    backends = { 'treesitter', 'lsp', 'markdown', 'man' },
    layout = {
      max_width  = { 40, 0.2 },
      min_width  = 24,
      default_direction = 'prefer_right',
      placement  = 'window',
    },
    attach_mode = 'window',
    filter_kind = {
      'Class', 'Constructor', 'Enum', 'Function',
      'Interface', 'Module', 'Method', 'Struct',
    },
    show_guides = true,
    guides = {
      mid_item   = '├─',
      last_item  = '└─',
      nested_top = '│ ',
      whitespace = '  ',
    },
    -- open aerial when navigating to a symbol via LSP
    open_automatic = false,
  },
}
