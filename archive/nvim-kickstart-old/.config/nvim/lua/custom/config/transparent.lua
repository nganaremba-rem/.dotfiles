local M = {}

function M.apply()
  local groups = {
    'Normal',
    'NormalNC',
    'EndOfBuffer',
    'SignColumn',
    'NormalFloat',
    'FloatBorder',

    -- Telescope
    'TelescopeNormal',
    'TelescopeBorder',
    'TelescopePromptNormal',
    'TelescopeResultsNormal',
    'TelescopePreviewNormal',

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

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = 'none' })
  end
end

return M
