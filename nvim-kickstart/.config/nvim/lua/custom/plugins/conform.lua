return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  -- Moved off <leader>f: that key was BOTH a standalone map and the prefix for
  -- <leader>fr / <leader>fi*, so it stalled for `timeoutlen` on every press. The
  -- old `mode = ''` also bound operator-pending, making `d<leader>f` format.
  keys = {
    {
      '<leader>cf',
      function() require('conform').format { async = true } end,
      mode = { 'n', 'v' },
      desc = 'Code: [f]ormat buffer/selection',
    },
  },
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = function()
    local lang = require 'custom.lang'
    -- Format-on-save for every filetype that declares a formatter in the
    -- registry — one derived list, nothing to maintain by hand.
    local format_on_save_fts = lang.format_on_save_fts()
    return {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if format_on_save_fts[vim.bo[bufnr].filetype] then
          return { timeout_ms = 500 }
        end
        return nil
      end,
      default_format_opts = {
        -- Use registry formatters when present, otherwise fall back to the LSP.
        lsp_format = 'fallback',
      },
      -- Formatters per filetype come straight from the language registry.
      formatters_by_ft = lang.formatters_by_ft(),
    }
  end,
}
