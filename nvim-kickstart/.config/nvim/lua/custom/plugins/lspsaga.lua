-- Disabled: Neovim 0.12's native LSP plus snacks.picker cover everything this was
-- used for, and lspsaga shadowed four built-in keys to do it.
--
-- The `gt` shadow was the costly one: custom/config/autocmds.lua points $EDITOR at
-- `nvim --remote-tab-wait-silent`, so lazygit/git/etc. open files as new TABS —
-- which `gt` could no longer cycle.
--
--   K   -> vim.lsp.buf.hover { border = 'rounded' }   (custom/config/keymaps.lua)
--   gd  -> Snacks.picker.lsp_definitions()            (custom/plugins/snacks.lua)
--   gp  -> freed; built-in "put and leave cursor after" restored
--   gt  -> freed; built-in "go to next tab" restored
--
-- Peek-style previews now come from the picker's own preview pane.
-- Re-enable by flipping `enabled` if you miss the floating UI.
return {
  'nvimdev/lspsaga.nvim',
  enabled = false,
  event = 'LspAttach',
  opts = {
    lightbulb = { enable = false },
  },
}
