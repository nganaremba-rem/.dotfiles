return {
  'akinsho/bufferline.nvim',
  event = 'BufReadPre',
  keys = {
    { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev buffer' },
    { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
    { '<leader>bd', '<cmd>bdelete<cr>', desc = 'Delete buffer' },
  },
  opts = {
    options = {
      mode = 'buffers',
      separator_style = 'none',
      show_buffer_close_icons = true,
      show_close_icon = false,
      color_icons = true,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(count, level)
        local icon = level:match 'error' and ' ' or ' '
        return icon .. count
      end,
      custom_filter = function(buf_number)
        if vim.fn.bufname(buf_number) == '' then return false end
        return true
      end,
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'File Explorer',
          highlight = 'Directory',
          separator = true,
        },
      },
    },

    highlights = {
      fill = { bg = 'none' },
      background = { bg = 'none' },
      buffer_selected = {
        bg = 'none',
        fg = '#7aa2f7', -- tokyonight blue
        bold = true,
        italic = true,
      },
      indicator_selected = {
        fg = '#7aa2f7',
        bg = 'none',
      },
    },
  },
}
