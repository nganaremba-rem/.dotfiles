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
      -- biome ignores .prettierrc/.editorconfig and formats with its own defaults
      -- (double quotes, semicolons, tabs). It sits first in the web/css/html/json
      -- formatter lists with stop_after_first, so it would silently outrank prettier
      -- in every prettier project. require_cwd makes it unavailable unless a
      -- biome.json/biome.jsonc root exists -> conform falls through to prettierd.
      formatters = {
        biome = { require_cwd = true },
      },
    }
  end,
}
