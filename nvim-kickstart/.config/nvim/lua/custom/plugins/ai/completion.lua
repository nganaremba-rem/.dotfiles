-- ════════════════════════════════════════════════════════════════════════════
--  AI inline completion (Cursor-style ghost text).
--
--  Provider is swappable: change the single `PROVIDER` value below and restart.
--  Each provider returns a self-contained lazy.nvim spec, so only the active one
--  is ever loaded.
--
--  Accept key is <C-j> for every provider (NOT <Tab>) so it never fights with
--  blink.cmp's super-tab menu. blink's own ghost_text is disabled (see
--  custom/plugins/blink.lua) — the AI provider owns inline ghost text.
--
--    supermaven : free tier, very fast, zero-config           (default)
--    copilot    : best quality, needs `:Copilot auth` + sub
--    codeium    : free, needs `:Codeium Auth`
-- ════════════════════════════════════════════════════════════════════════════

local PROVIDER = 'supermaven'

local providers = {
  supermaven = {
    'supermaven-inc/supermaven-nvim',
    event = 'InsertEnter',
    -- Toggle inline ghost text on/off. <leader>a… is avante's namespace and <leader>t
    -- is the terminal group, so the AI-suggestion toggle lives under <leader>u (UI).
    keys = {
      {
        '<leader>ua',
        function()
          require('supermaven-nvim.api').toggle()
        end,
        desc = 'Toggle [a]I suggestions (ghost text)',
      },
    },
    opts = {
      keymaps = {
        accept_suggestion = '<C-j>',
        clear_suggestion = '<C-]>',
        accept_word = '<C-l>',
      },
      ignore_filetypes = { 'TelescopePrompt', 'snacks_picker_input' },
      color = { suggestion_color = '#6c7086', cterm = 244 },
      disable_inline_completion = false,
      disable_keymaps = false,
    },
  },

  copilot = {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    cmd = 'Copilot',
    opts = {
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = '<C-j>',
          dismiss = '<C-]>',
          accept_word = '<C-l>',
        },
      },
      panel = { enabled = false },
      -- Run `:Copilot auth` once after install.
    },
  },

  codeium = {
    'Exafunction/codeium.nvim',
    event = 'InsertEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('codeium').setup {
        enable_chat = false,
      }
      vim.keymap.set('i', '<C-j>', function()
        return vim.fn['codeium#Accept']()
      end, { expr = true, silent = true, desc = 'Codeium accept' })
      vim.keymap.set('i', '<C-]>', function()
        return vim.fn['codeium#Clear']()
      end, { expr = true, silent = true, desc = 'Codeium clear' })
      -- Run `:Codeium Auth` once after install.
    end,
  },
}

return providers[PROVIDER]
