-- Live markdown preview in the browser. Port is set in init.lua (vim.g.mkdp_port).
--
-- `build` uses the plugin's own installer rather than `cd app && npm install`:
-- the shell form runs in the wrong cwd under some lazy.nvim setups and silently
-- leaves the preview server unbuilt.
return {
  'iamcco/markdown-preview.nvim',
  ft = { 'markdown' },
  cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
  build = function() vim.fn['mkdp#util#install']() end,
  keys = {
    { '<leader>rm', '<cmd>MarkdownPreviewToggle<cr>', ft = 'markdown', desc = 'Run: [m]arkdown preview' },
  },
}
