-- Preserve inode on write so file-watchers (Vite HMR, etc.) keep working
vim.opt.backupcopy = 'yes'

-- Encoding detection order. utf-8 MUST come before the Japanese encodings:
-- euc-jp/cp932/sjis accept almost any byte sequence, so listing them first
-- makes nvim misdetect plain UTF-8 (e.g. .env) as euc-jp and write it back
-- [converted], which desyncs the buffer and triggers the spurious
-- "file changed since reading it!!!" prompt. utf-8-first fixes that; the
-- Japanese encodings stay as fallbacks for genuinely non-UTF-8 files.
vim.opt.fileencodings = {
  'ucs-bom', -- UTF files with BOM
  'utf-8', -- normal UTF-8 (try first; valid UTF-8 is unambiguous)
  'cp932', -- common Japanese Windows encoding
  'euc-jp', -- older Japanese encoding
  'sjis', -- Shift-JIS
  'latin1', -- last-resort fallback
}

-- Keep write-backup files OUT of the project dir (no more .env.local~ clutter
-- in neo-tree). Backups go to a central state dir; with backup=off (default)
-- they're deleted after a successful write anyway.
vim.opt.backupdir = vim.fn.stdpath 'state' .. '/backup//'
vim.fn.mkdir(vim.fn.stdpath 'state' .. '/backup', 'p')

-- Auto-reload files changed on disk (and surface true external edits) instead
-- of silently going stale.
vim.opt.autoread = true

vim.opt.swapfile = false
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
-- vim.o.mouse = 'a'
vim.o.mouse = ''

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Enable break indent
vim.o.breakindent = true

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- How long before CursorHold fires and before swap is written (ms)
vim.o.updatetime = 200
-- How long to wait for a mapped key sequence to complete
vim.o.timeoutlen = 300
-- How long to wait for a terminal key code sequence (Esc, arrow keys).
-- 0 = instant Escape response in insert/visual mode — no perceptible lag.
vim.o.ttimeoutlen = 0

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
-- vim.o.list = true
vim.opt.listchars = { tab = '| ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Don't wrap long lines (toggle per-buffer in prose files via autocmd)
vim.o.wrap = false

-- Keep context lines visible around folds
vim.o.foldlevel = 99

-- Stop syntax/treesitter highlighting past this column — huge win on long lines
-- (anything past 300 chars is rarely visible anyway)
vim.o.synmaxcol = 300

-- Keep context visible during horizontal scrolling
vim.o.sidescrolloff = 8

-- Show matching brackets briefly
vim.o.showmatch = true

-- Allow cursor to move past end of line in visual block mode
vim.o.virtualedit = 'block'

-- Use ripgrep for :grep if available
if vim.fn.executable 'rg' == 1 then
  vim.o.grepprg = 'rg --vimgrep --smart-case'
  vim.o.grepformat = '%f:%l:%c:%m'
end
