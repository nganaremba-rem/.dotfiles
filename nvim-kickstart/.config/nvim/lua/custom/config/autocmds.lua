local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- When any child process (terminal, lazygit, git, file managers) calls $EDITOR,
-- redirect it into this running nvim via --remote instead of spawning a nested nvim.
-- --remote-tab-wait-silent: opens in a new tab, blocks until closed, silent on error.
autocmd('VimEnter', {
  desc = 'Redirect $EDITOR to outer nvim via --remote for all child processes',
  group = augroup('nvim-remote-editor', { clear = true }),
  callback = function()
    local server = vim.v.servername
    if server == '' then return end
    local editor = ('nvim --server %s --remote-tab-wait-silent'):format(server)
    vim.env.EDITOR = editor
    vim.env.VISUAL = editor
    vim.env.GIT_EDITOR = editor
    vim.env.NVIM_LISTEN_ADDRESS = server -- for tools that use the legacy var (lazygit editPreset)
  end,
})

-- Highlight yanked text
autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Restore cursor to last known position
autocmd('BufReadPost', {
  desc = 'Restore cursor position',
  group = augroup('restore-cursor', { clear = true }),
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- Trim trailing whitespace on save (non-binary files)
autocmd('BufWritePre', {
  desc = 'Trim trailing whitespace',
  group = augroup('trim-whitespace', { clear = true }),
  callback = function()
    if not vim.bo.binary and vim.bo.filetype ~= 'diff' then
      local view = vim.fn.winsaveview()
      vim.cmd [[keeppatterns %s/\s\+$//e]]
      vim.fn.winrestview(view)
    end
  end,
})

-- Make `autoread` reliable: check for external changes when refocusing nvim
-- or entering a buffer, so files reload instead of going stale.
autocmd({ 'FocusGained', 'BufEnter', 'TermClose', 'TermLeave' }, {
  desc = 'Reload files changed outside nvim',
  group = augroup('auto-checktime', { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == '' then vim.cmd 'checktime' end
  end,
})

-- Auto-resize splits when terminal is resized
autocmd('VimResized', {
  desc = 'Auto-resize splits',
  group = augroup('auto-resize', { clear = true }),
  callback = function() vim.cmd 'tabdo wincmd =' end,
})

-- Close utility windows with Esc (not q — q = macro record)
autocmd('FileType', {
  desc = 'Close utility windows with Esc',
  group = augroup('close-with-esc', { clear = true }),
  pattern = { 'qf', 'help', 'man', 'notify', 'lspinfo', 'startuptime', 'checkhealth' },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = ev.buf, silent = true })
  end,
})

-- Wrap and spell in text/markdown files
autocmd('FileType', {
  desc = 'Enable wrap and spell in prose filetypes',
  group = augroup('prose-settings', { clear = true }),
  pattern = { 'markdown', 'text', 'gitcommit' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
