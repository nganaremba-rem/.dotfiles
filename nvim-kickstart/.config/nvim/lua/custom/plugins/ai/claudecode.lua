-- Claude Code, integrated. Uses the same WebSocket protocol as the official
-- VS Code / JetBrains extensions.
--
-- NOTE: default keymaps are <leader>a… which collides head-on with avante.
-- These are remapped to <leader>k… ("klaude") so both can coexist.
return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = {},
  keys = {
    { '<leader>k', nil, desc = 'Claude Code' },
    { '<leader>kc', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude Code' },
    { '<leader>kf', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude Code' },
    { '<leader>kr', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume session' },
    { '<leader>kC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue conversation' },
    { '<leader>km', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select model' },
    { '<leader>kb', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
    { '<leader>ks', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send selection' },
    { '<leader>ka', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
    { '<leader>kd', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Reject diff' },
  },
}
