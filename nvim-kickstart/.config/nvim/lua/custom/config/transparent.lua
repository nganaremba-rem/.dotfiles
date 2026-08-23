-- ════════════════════════════════════════════════════════════════════════════
--  Force-transparent backgrounds — an ESCAPE HATCH, not part of the startup path.
--
--  Nothing calls this today: tokyonight is configured with `transparent = true`
--  plus an `on_highlights` block (custom/plugins/tokyonight.lua), which is the
--  correct way to do it — the colorscheme applies it itself, and it survives a
--  `:colorscheme` reload. Keep this module for a theme that has no transparency
--  option of its own; call `require('custom.config.transparent').apply()` from
--  that theme's `config`.
--
--  Two traps this file used to fall into, both fixed below:
--
--    1. `nvim_set_hl(0, group, { bg = 'none' })` REPLACES the whole highlight.
--       Passing only `bg` therefore throws away `fg`, `bold`, `link`, … — which
--       is why the statusline lost its colours. Read the existing definition and
--       merge instead.
--    2. Highlights are wiped by every `:colorscheme` command, so applying once at
--       startup silently stops working the moment anything reloads the theme.
--       `apply()` therefore also installs a ColorScheme autocmd.
-- ════════════════════════════════════════════════════════════════════════════

local M = {}

-- Groups whose background should be cleared. Telescope is intentionally absent:
-- this config uses Snacks.picker (see custom/plugins/snacks.lua).
local GROUPS = {
  'Normal',
  'NormalNC',
  'EndOfBuffer',
  'SignColumn',
  'NormalFloat',
  'FloatBorder',

  -- Snacks (picker / notifier / input)
  'SnacksNormal',
  'SnacksNormalNC',
  'SnacksPickerNormal',

  -- Neo-tree
  'NeoTreeNormal',
  'NeoTreeNormalNC',

  -- Bufferline
  'BufferLineFill',
  'BufferLineBackground',

  -- Statusline
  'StatusLine',
  'StatusLineNC',
}

local function clear_backgrounds()
  for _, group in ipairs(GROUPS) do
    -- `link = false` resolves a linked group to its real attributes; without it
    -- a linked group returns `{ link = 'Other' }` and the merge below is a no-op.
    local ok, current = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok then
      current.bg = nil
      current.ctermbg = nil
      vim.api.nvim_set_hl(0, group, current)
    end
  end
end

function M.apply()
  clear_backgrounds()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('custom-transparent', { clear = true }),
    desc = 'Re-apply transparent backgrounds after a colorscheme change',
    callback = clear_backgrounds,
  })
end

return M
