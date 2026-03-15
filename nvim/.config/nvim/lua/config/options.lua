-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.opt.spell = true
-- vim.opt.spelllang = { "en_us" }
--
-- vim.api.nvim_set_hl(0, "@spell", {})
-- vim.api.nvim_set_hl(0, "@spell.typescript", {})

-- vim.api.nvim_create_autocmd("ColorScheme", {
--   callback = function()
--     vim.api.nvim_set_hl(0, "SpellBad", {
--       undercurl = true,
--       fg = "#E5C07B",
--     })
--   end,
-- })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "dotenv",
  callback = function()
    vim.diagnostic.disable(0)
  end,
})

vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
