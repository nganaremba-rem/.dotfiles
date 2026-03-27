-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Force tmux-navigator to win EVERYWHERE

local keymap = vim.keymap.set

vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz")
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz")
-- vim.keymap.set({ "n", "v" }, "<C-j>", "10j")
-- vim.keymap.set({ "n", "v" }, "<C-k>", "10k")

-- copy line / selection
vim.keymap.set("n", "<S-A-j>", "yyp", { desc = "Duplicate line down" })
vim.keymap.set("n", "<S-A-k>", "yyP", { desc = "Duplicate line up" })

vim.keymap.set("v", "<S-A-j>", "y`>p", { desc = "Duplicate selection down" })
vim.keymap.set("v", "<S-A-k>", "y`<P", { desc = "Duplicate selection up" })

-- vim.keymap.set("n", "<C-k>", ":wincmd k<CR>")
-- vim.keymap.set("n", "<C-j>", ":wincmd j<CR>")
-- vim.keymap.set("n", "<C-h>", ":wincmd h<CR>")
-- vim.keymap.set("n", "<C-l>", ":wincmd l<CR>")
--
vim.g.tmux_navigator_no_mappings = 1

vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>")
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>")
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>")
-- vim.api.nvim_create_autocmd("BufEnter", {
--   callback = function()
--     vim.schedule(function()
--       keymap("n", "<C-h>", ":TmuxNavigateLeft<CR>", { buffer = true, noremap = true, silent = true })
--       keymap("n", "<C-j>", ":TmuxNavigateDown<CR>", { buffer = true, noremap = true, silent = true })
--       keymap("n", "<C-k>", ":TmuxNavigateUp<CR>", { buffer = true, noremap = true, silent = true })
--       keymap("n", "<C-l>", ":TmuxNavigateRight<CR>", { buffer = true, noremap = true, silent = true })
--     end)
--   end,
-- })

-- Neovim windows get leader keys instead
keymap("n", "<leader>wh", "<C-w>h", { desc = "Left window" })
keymap("n", "<leader>wj", "<C-w>j", { desc = "Down window" })
keymap("n", "<leader>wk", "<C-w>k", { desc = "Up window" })
keymap("n", "<leader>wl", "<C-w>l", { desc = "Right window" })
