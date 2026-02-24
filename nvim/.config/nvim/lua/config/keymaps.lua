-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz")
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz")
vim.keymap.set({ "n", "v" }, "<C-j>", "10j")
vim.keymap.set({ "n", "v" }, "<C-k>", "10k")

-- copy line / selection
vim.keymap.set("n", "<S-A-j>", "yyp", { desc = "Duplicate line down" })
vim.keymap.set("n", "<S-A-k>", "yyP", { desc = "Duplicate line up" })

vim.keymap.set("v", "<S-A-j>", "y`>p", { desc = "Duplicate selection down" })
vim.keymap.set("v", "<S-A-k>", "y`<P", { desc = "Duplicate selection up" })
