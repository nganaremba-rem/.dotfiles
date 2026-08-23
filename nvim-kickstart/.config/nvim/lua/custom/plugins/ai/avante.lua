-- ════════════════════════════════════════════════════════════════════════════
--  avante.nvim — Cursor-style AI in Neovim: sidebar chat, @-mentions, and AI
--  edits applied as in-buffer diffs you accept/reject.
--
--  SETUP (one-time):
--    export ANTHROPIC_API_KEY=sk-ant-...   (in ~/.zshrc; avante reads it at start)
--
--  MODEL: defaults to Claude Opus 5 (current flagship: 1M context, $5/$25 per
--  MTok). To trade capability for speed/cost, set MODEL = 'claude-sonnet-5'.
--
--  ⚠️ Opus 5 / 4.8 / 4.7 and Sonnet 5 reject sampling params (`temperature`,
--  `top_p`, `top_k`) with HTTP 400 — they were removed with adaptive thinking.
--  That is why no temperature is sent below. Only pre-4.6 models accept them.
--
--  Keymaps live under <leader>a… (avante's default). Aerial was moved off
--  <leader>a to <leader>cs to avoid the collision (see custom/plugins/aerial.lua).
-- ════════════════════════════════════════════════════════════════════════════

local MODEL = 'claude-opus-5'

return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false, -- avante is a rolling release; pin to latest main, never '*'
  build = 'make',
  opts = {
    provider = 'claude',
    providers = {
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = MODEL,
        extra_request_body = {
          -- No `temperature`: Opus 5/4.8/4.7 reject sampling params (400).
          max_tokens = 32000,
        },
      },
    },
    behaviour = {
      auto_suggestions = false, -- inline suggestions are owned by Supermaven
      auto_set_keymaps = true,
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    {
      -- Pretty markdown rendering inside the avante chat window.
      'MeanderingProgrammer/render-markdown.nvim',
      opts = { file_types = { 'markdown', 'Avante' } },
      ft = { 'markdown', 'Avante' },
    },
  },
}
