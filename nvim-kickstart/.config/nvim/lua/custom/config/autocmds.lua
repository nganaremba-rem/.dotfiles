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

-- Trim trailing whitespace on save (non-binary files).
-- markdown is exempt: two trailing spaces are a hard line break there, and
-- gitcommit/text can carry deliberate trailing whitespace too.
local no_trim_ft = { diff = true, markdown = true, gitcommit = true, text = true }

autocmd('BufWritePre', {
  desc = 'Trim trailing whitespace',
  group = augroup('trim-whitespace', { clear = true }),
  callback = function()
    if not vim.bo.binary and not no_trim_ft[vim.bo.filetype] then
      local view = vim.fn.winsaveview()
      vim.cmd [[keeppatterns %s/\s\+$//e]]
      vim.fn.winrestview(view)
    end
  end,
})

-- Make `autoread` reliable: check for external changes when refocusing nvim
-- or entering a buffer, so files reload instead of going stale.
-- CursorHold covers the case the focus events miss: an agent (Claude Code,
-- a formatter, git) rewrites the file while the cursor just sits in it.
local function checktime()
  -- The command-line window blocks almost every command; never touch it.
  if vim.fn.getcmdwintype() ~= '' then return end
  -- Check every loaded file buffer, not just the current one: the cursor is
  -- often parked in a terminal or picker while an agent rewrites a file.
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buftype == ''
      and vim.api.nvim_buf_get_name(buf) ~= ''
      -- checktime on a modified buffer pops a blocking prompt; skip those.
      and not vim.bo[buf].modified
    then
      vim.cmd(('checktime %d'):format(buf))
    end
  end
end

autocmd({
  'FocusGained',
  'BufEnter',
  'WinEnter',
  'CursorHold',
  'CursorHoldI',
  'TermClose',
  'TermLeave',
}, {
  desc = 'Reload files changed outside nvim',
  group = augroup('auto-checktime', { clear = true }),
  callback = checktime,
})

-- Belt and braces: poll every 2s so even a completely idle nvim (no cursor
-- movement, no focus change) picks up external writes.
local checktime_timer = vim.uv.new_timer()
checktime_timer:start(2000, 2000, function() vim.schedule(checktime) end)

-- `autoread` reloads silently, which is confusing mid-edit. Say what happened.
autocmd('FileChangedShellPost', {
  desc = 'Report buffers reloaded from disk',
  group = augroup('checktime-notify', { clear = true }),
  callback = function(ev)
    vim.notify(
      ('Reloaded from disk: %s'):format(vim.fn.fnamemodify(ev.file, ':t')),
      vim.log.levels.INFO
    )
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
