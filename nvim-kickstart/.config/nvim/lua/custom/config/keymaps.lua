local map = vim.keymap.set
-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- UI toggles all live under <leader>u. <leader>b is the buffer group and must not
-- double as a prefix (see debug.lua: <leader>db is the breakpoint toggle).
map('n', '<Leader>uw', ':set wrap!<CR>', { noremap = true, silent = true, desc = 'Toggle soft-wrap' })
map('n', '<Leader>ui', ':set breakindent!<CR>', { noremap = true, silent = true, desc = 'Toggle breakindent' })

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

-- Diagnostics/quickfix all live under <leader>x — see trouble.lua
-- (<leader>xx all, <leader>xd buffer, <leader>xq quickfix, <leader>xL loclist)

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

map('n', '<C-s>', '<cmd>w<CR>', { desc = 'Save' })
map('i', '<C-s>', '<Esc><cmd>w<CR>', { desc = 'Save' })

-- <C-h/j/k/l> belong to window navigation; keep them inert in insert mode so a
-- stray chord never moves the cursor mid-word. NOTE: the AI completion provider
-- re-binds <C-j> (accept) and <C-l> (accept word) on InsertEnter — it loads after
-- this file, so it wins on purpose. See custom/plugins/ai/completion.lua.
map('i', '<C-h>', '<Nop>', { desc = 'Disabled (window nav key)' })
map('i', '<C-k>', '<Nop>', { desc = 'Disabled (window nav key)' })

-- dj/dk delete two lines by accident far more often than on purpose.
map('n', 'dj', '<Nop>', { desc = 'Disabled (use dd or 2dd)' })
map('n', 'dk', '<Nop>', { desc = 'Disabled (use dd or 2dd)' })

-- Window navigation that transparently crosses the nvim↔tmux pane boundary.
-- These replace the plain <C-w> variants; vim-tmux-navigator's own mappings are
-- suppressed so these are the single definition.
vim.g.tmux_navigator_no_mappings = 1

map('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>', { desc = 'Move focus left (nvim/tmux)' })
map('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>', { desc = 'Move focus down (nvim/tmux)' })
map('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>', { desc = 'Move focus up (nvim/tmux)' })
map('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>', { desc = 'Move focus right (nvim/tmux)' })

map('v', '>', '>gv', { desc = 'Indent right' })
map('v', '<', '<gv', { desc = 'Indent left' })

vim.keymap.set('n', 'vag', 'ggVG', { desc = 'Select all' })
vim.keymap.set('n', 'dag', 'ggdG', { desc = 'Delete all' })

vim.keymap.set('n', '<leader>uh', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
  vim.notify('inlay hints ' .. (not enabled and 'enabled' or 'disabled'))
end, { desc = 'Toggle inlay hints' })

-- Moved off the lone <leader>o prefix into the <leader>c code group.
vim.keymap.set(
  'n',
  '<leader>co',
  function()
    vim.lsp.buf.code_action {
      apply = true,
      context = {
        only = { 'source.fixAll.eslint' },
      },
    }
  end,
  { desc = 'Fix imports / [o]rganize (ESLint)' }
)

-- vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1, float = true } end)
-- vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1, float = true } end)
vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line [d]iagnostics (float)' })

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

-- Git file history is <leader>gf (current file) / <leader>gF (repo) — defined as
-- lazy `keys` in custom/plugins/diffview.lua so diffview only loads on demand.
