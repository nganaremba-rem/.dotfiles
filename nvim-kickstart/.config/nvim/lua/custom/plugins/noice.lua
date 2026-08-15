return {
  -- lazy.nvim
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    -- Moved off <leader>dn so <leader>d is a clean debug group.
    keys = {
      { '<leader>un', '<cmd>NoiceDismiss<cr>', desc = 'Dismiss [n]otifications' },
      { '<leader>uN', '<cmd>Noice history<cr>', desc = '[N]otification history' },
    },
    opts = {
      -- Division of labour: noice owns the cmdline, messages and LSP UI;
      -- Snacks.notifier owns notifications. Both plugins want to replace
      -- `vim.notify`, and whichever loads last silently wins — so noice's
      -- notifier is turned off explicitly rather than left to load order.
      notify = { enabled = false },
      routes = {
        {
          filter = { event = 'notify', find = 'No information available' },
          opts = { skip = true },
        },
        {
          filter = { event = 'msg_show', kind = { 'shell_out', 'shell_err', 'shell_ret' } },
          view = 'split',
        },
      },
      lsp = {
        progress = {
          enabled = false,
        },
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = true, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      -- nvim-notify is deliberately absent: notifications go to Snacks.notifier
      -- (see `notify = { enabled = false }` above), so noice never needs a
      -- notification backend of its own.
      'MunifTanjim/nui.nvim',
    },
  },
}
