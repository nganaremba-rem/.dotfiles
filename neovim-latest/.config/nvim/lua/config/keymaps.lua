local map = vim.keymap.set

map("n", "<C-h>", "<C-w>h", { desc = "Go to the left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to the lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to the upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to the right window" })

map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save" })
map("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save" })
map("i", "<C-h>", "<Nop>", { desc = "" })
map("i", "<C-j>", "<Nop>", { desc = "" })
map("i", "<C-k>", "<Nop>", { desc = "" })
map("i", "<C-l>", "<Nop>", { desc = "" })
map("n", "dj", "<Nop>", { desc = "" })
map("n", "dk", "<Nop>", { desc = "" })

vim.g.tmux_navigator_no_mappings = 1

map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>")
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>")
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>")
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>")
map("n", "<Esc>", "<cmd>noh<cr>")
map("n", "<leader>tw", "<cmd>setlocal wrap!<cr>", { desc = "Toggle wrap" })



map('v', ">", ">gv", { desc = "Indent right" })
map('v', "<", "<gv", { desc = "Indent left" })

vim.keymap.set("n", "<leader>uh", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
  vim.notify("Inlay hints " .. (not enabled and "enabled" or "disabled"))
end, { desc = "Toggle Inlay Hints" })
