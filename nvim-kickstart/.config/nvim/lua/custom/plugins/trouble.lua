return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',                                       desc = 'Diagnostics' },
    { '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',                          desc = 'Buffer diagnostics' },
    -- Symbol outline is <leader>cs (aerial) — not duplicated here.
    { '<leader>xl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',               desc = 'LSP definitions / references' },
    { '<leader>xq', '<cmd>Trouble qflist toggle<cr>',                                            desc = 'Quickfix list' },
    { '<leader>xL', '<cmd>Trouble loclist toggle<cr>',                                           desc = 'Location list' },
    {
      '[q',
      function()
        if require('trouble').is_open() then
          require('trouble').prev { skip_groups = true, jump = true }
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then vim.notify(err, vim.log.levels.ERROR) end
        end
      end,
      desc = 'Prev trouble / quickfix item',
    },
    {
      ']q',
      function()
        if require('trouble').is_open() then
          require('trouble').next { skip_groups = true, jump = true }
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then vim.notify(err, vim.log.levels.ERROR) end
        end
      end,
      desc = 'Next trouble / quickfix item',
    },
  },
  opts = {
    modes = {
      lsp = { win = { position = 'right' } },
    },
  },
}
