return { -- Collection of various small independent plugins/modules
  'nvim-mini/mini.nvim',
  -- NOT lazy: mini.icons must finish mocking nvim-web-devicons before any
  -- consumer (neo-tree, bufferline, lualine, aerial, trouble) first requires it.
  lazy = false,
  priority = 900,
  config = function()
    -- Icon provider. mini.icons is faster than nvim-web-devicons and caches by
    -- filetype; `mock_nvim_web_devicons` makes every plugin that hard-requires
    -- 'nvim-web-devicons' transparently use it, so the old plugin can go away.
    require('mini.icons').setup()
    MiniIcons.mock_nvim_web_devicons()

    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup {
      -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
      mappings = {
        around_next = 'aa',
        inside_next = 'ii',
      },
      n_lines = 500,
    }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Toggle a single-line argument list to multi-line and back with `gS`.
    -- Part of mini.nvim already — no separate plugin needed.
    require('mini.splitjoin').setup()

    -- mini.statusline intentionally NOT set up here — lualine is used instead.
    -- Check out: https://github.com/nvim-mini/mini.nvim
  end,
}
