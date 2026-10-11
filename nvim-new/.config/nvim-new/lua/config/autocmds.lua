vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- -- Put this somewhere in your config (outside plugin specs)
-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args)
--     if vim.lsp.get_client_by_id(args.data.client_id):supports_method("textDocument/inlayHint") then
--       vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
--       vim.defer_fn(function()
--         vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
--       end, 100)
--     end
--   end,
-- })
