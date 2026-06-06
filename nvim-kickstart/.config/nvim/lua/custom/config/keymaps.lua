local map = vim.keymap.set
-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

-- <leader>xx for full diagnostics (trouble), <leader>xd for buffer — see trouble.lua
vim.keymap.set('n', '<leader>q', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix list (Trouble)' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })
map('n', '<C-s>', '<cmd>w<CR>', { desc = 'Save' })
map('i', '<C-s>', '<Esc><cmd>w<CR>', { desc = 'Save' })
map('i', '<C-h>', '<Nop>', { desc = '' })
map('i', '<C-j>', '<Nop>', { desc = '' })
map('i', '<C-k>', '<Nop>', { desc = '' })
map('i', '<C-l>', '<Nop>', { desc = '' })
map('n', 'dj', '<Nop>', { desc = '' })
map('n', 'dk', '<Nop>', { desc = '' })

vim.g.tmux_navigator_no_mappings = 1

map('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>')
map('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>')
map('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>')
map('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>')

map('v', '>', '>gv', { desc = 'Indent right' })
map('v', '<', '<gv', { desc = 'Indent left' })

vim.keymap.set('n', 'vag', 'ggVG', { desc = 'Select all' })
vim.keymap.set('n', 'dag', 'ggdG', { desc = 'Delete all' })

vim.keymap.set('n', '<leader>uh', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
  vim.notify('inlay hints ' .. (not enabled and 'enabled' or 'disabled'))
end, { desc = 'toggle inlay hints' })

vim.keymap.set(
  'n',
  '<leader>oi',
  function()
    vim.lsp.buf.code_action {
      apply = true,
      context = {
        only = { 'source.fixAll.eslint' },
      },
    }
  end,
  { desc = 'Fix imports (ESLint)' }
)

-- vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1, float = true } end)
-- vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1, float = true } end)
vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float)

-- Organise import
-- vim.keymap.set(
--   'n',
--   '<leader>oi',
--   function()
--     vim.lsp.buf.code_action {
--       context = { only = { 'source.organizeImports' } },
--       apply = true,
--     }
--   end,
--   { desc = 'Organize Imports' }
-- )

vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', {
  desc = 'Git History (Current File)',
})

vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory<CR>', {
  desc = 'Git History (Repository)',
})
