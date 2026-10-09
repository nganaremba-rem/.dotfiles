-- 🧭 vimb popup editor — a noice-style floating nvim for vimb's Ctrl-T.
--
-- Started as NVIM_APPNAME=nvim-vimb (this file only), so it opens instantly with no
-- plugins, LSP or mason; it just borrows tokyonight from the main config's lazy dir.
-- niri floats + blurs the window (rules/windows.kdl, app-ids vimb-cmdedit / vimb-editor).
--
--   VIMB_POPUP=cmdline  vimb command line (vimb-cmdedit): starts in insert,
--                       <CR> runs it, <Esc><Esc> or q cancels
--   VIMB_POPUP=field    form-field text (vimb editor-command): opens at the end of
--                       the text, <C-s> saves back to the page, q cancels
local kind = vim.env.VIMB_POPUP == 'cmdline' and 'cmdline' or 'field'

-- 🎨 Same look as the main nvim: tokyonight-night, transparent over niri's blur.
local theme = vim.fn.expand '~/.local/share/nvim/lazy/tokyonight.nvim'
if vim.uv.fs_stat(theme) then
  vim.opt.rtp:prepend(theme)
  require('tokyonight').setup { style = 'night', transparent = true, styles = { floats = 'transparent', sidebars = 'transparent' } }
  vim.cmd.colorscheme 'tokyonight-night'
end
-- Title bar floats on the blur too (theme paints WinBar with a solid band).
for _, g in ipairs { 'WinBar', 'WinBarNC' } do
  vim.api.nvim_set_hl(0, g, { bg = 'NONE' })
end

-- 🧹 Bare UI: just the text and a title bar.
local o = vim.opt
o.number, o.relativenumber, o.signcolumn = false, false, 'no'
o.laststatus, o.showtabline, o.cmdheight = 0, 0, 0
o.ruler, o.showmode = false, false
o.wrap, o.linebreak = true, true
o.fillchars = { eob = ' ' }
o.clipboard = 'unnamedplus'
o.mouse = 'a'
o.swapfile = false
-- The popup has no command-line row (cmdheight=0) and is only a few lines tall, so any
-- message (e.g. "written" on save) would stop at a -- More -- prompt instead of exiting.
o.more = false
o.shortmess:append 'WFI'

local map = vim.keymap.set
local save, cancel = '<cmd>silent wq<CR>', '<cmd>q!<CR>'
map('n', 'q', cancel, { desc = 'Cancel (quit without saving)' })

if kind == 'cmdline' then
  o.winbar = '%#Title#  vimb ❯ %#Normal#command   %#Comment#<CR> run · <Esc><Esc>/q cancel'
  map({ 'n', 'i' }, '<CR>', save, { desc = 'Run the command in vimb' })
  map('n', '<Esc>', cancel, { desc = 'Cancel (2nd Esc, from normal mode)' })
  map({ 'n', 'i' }, '<C-c>', cancel, { desc = 'Cancel' })
  vim.api.nvim_create_autocmd('VimEnter', { command = 'startinsert!' })
else
  o.winbar = '%#Title# 󰏫 vimb ❯ %#Normal#edit field   %#Comment#<C-s> save · q cancel'
  map({ 'n', 'i' }, '<C-s>', save, { desc = 'Save back to the page' })
  vim.api.nvim_create_autocmd('VimEnter', { command = 'normal! G$' })
end
