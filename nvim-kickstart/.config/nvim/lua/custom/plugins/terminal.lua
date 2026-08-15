-- ════════════════════════════════════════════════════════════════════════════
--  Terminals — VS Code-style, built on Snacks.terminal (replaces toggleterm).
--
--  Snacks derives a terminal's identity from cmd + cwd + env, so giving each slot
--  a distinct NVIM_TERM_SLOT gives five INDEPENDENT terminals that each keep their
--  own shell state across toggles.
--
--    <C-\>          toggle the last-used terminal        (works everywhere)
--    <C-`>          same — VS Code muscle memory         (see note below)
--    <leader>tt     float
--    <leader>th/tv  horizontal / vertical split
--    <leader>t1..5  numbered persistent slots
--    <leader>tf     terminal in the current FILE's directory
--    <leader>tk     kill the focused terminal
--    <leader>tg     lazygit (also <leader>gg)
--
--  <C-`> note: Ctrl+backtick is only distinguishable from plain ` when the
--  terminal speaks the Kitty keyboard protocol. foot does, and Neovim 0.12
--  negotiates it — but inside tmux it additionally needs `extended-keys on`.
--  <C-\> is the guaranteed path and is bound first for that reason.
-- ════════════════════════════════════════════════════════════════════════════

-- Shared window geometry per direction.
local WIN = {
  float = { style = 'terminal', position = 'float', width = 0.85, height = 0.8, border = 'rounded' },
  bottom = { style = 'terminal', position = 'bottom', height = 0.35 },
  right = { style = 'terminal', position = 'right', width = 0.4 },
}

-- One numbered slot. `env` is what makes each slot a distinct terminal.
local function slot(n, win)
  return function()
    Snacks.terminal.toggle(nil, {
      env = { NVIM_TERM_SLOT = tostring(n) },
      win = vim.tbl_extend('force', win or WIN.bottom, { title = ' Terminal ' .. n .. ' ' }),
    })
  end
end

local function term(win, opts)
  return function()
    Snacks.terminal.toggle(nil, vim.tbl_extend('force', { win = win }, opts or {}))
  end
end

return {
  'folke/snacks.nvim',
  -- Extends the main spec in custom/plugins/snacks.lua; lazy.nvim merges the
  -- `keys` of both entries for the same repo.
  optional = true,

  keys = {
    -- ── Primary toggle ────────────────────────────────────────────────────
    { '<C-\\>', function() Snacks.terminal.toggle() end, mode = { 'n', 't' }, desc = 'Toggle terminal' },
    { '<C-`>', function() Snacks.terminal.toggle() end, mode = { 'n', 't' }, desc = 'Toggle terminal (VS Code key)' },

    -- ── Directions ────────────────────────────────────────────────────────
    { '<leader>tt', term(WIN.float), desc = 'Terminal: floa[t]ing' },
    { '<leader>th', term(WIN.bottom), desc = 'Terminal: [h]orizontal split' },
    { '<leader>tv', term(WIN.right), desc = 'Terminal: [v]ertical split' },

    -- ── Numbered slots ────────────────────────────────────────────────────
    { '<leader>t1', slot(1), desc = 'Terminal 1' },
    { '<leader>t2', slot(2), desc = 'Terminal 2' },
    { '<leader>t3', slot(3), desc = 'Terminal 3' },
    { '<leader>t4', slot(4), desc = 'Terminal 4' },
    { '<leader>t5', slot(5), desc = 'Terminal 5' },

    -- ── Context / lifecycle ───────────────────────────────────────────────
    {
      '<leader>tf',
      function()
        local file = vim.api.nvim_buf_get_name(0)
        local dir = file ~= '' and vim.fs.dirname(file) or vim.uv.cwd()
        Snacks.terminal.toggle(nil, { cwd = dir, win = WIN.bottom })
      end,
      desc = "Terminal: in current [f]ile's directory",
    },
    {
      '<leader>tn',
      function()
        -- A fresh, never-reused terminal (unique env => unique id).
        Snacks.terminal.open(nil, {
          env = { NVIM_TERM_SLOT = 'adhoc-' .. tostring(vim.uv.hrtime()) },
          win = WIN.bottom,
        })
      end,
      desc = 'Terminal: [n]ew',
    },
    {
      '<leader>tk',
      function()
        if vim.bo.buftype == 'terminal' then
          vim.cmd 'bdelete!'
        else
          Snacks.notify.warn 'Not in a terminal buffer'
        end
      end,
      mode = { 'n', 't' },
      desc = 'Terminal: [k]ill focused',
    },
    { '<leader>tg', function() Snacks.lazygit() end, desc = 'Terminal: lazy[g]it' },
  },

  init = function()
    vim.api.nvim_create_autocmd('TermOpen', {
      group = vim.api.nvim_create_augroup('terminal-local-settings', { clear = true }),
      desc = 'Terminal-buffer local settings and window navigation',
      callback = function(ev)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = 'no'
        vim.opt_local.spell = false

        -- Move out of a terminal without leaving terminal mode first. These
        -- shadow the global TmuxNavigate maps, which are normal-mode only.
        local nav = { h = 'h', j = 'j', k = 'k', l = 'l' }
        for key, dir in pairs(nav) do
          vim.keymap.set('t', '<C-' .. key .. '>', function() vim.cmd.wincmd(dir) end, {
            buffer = ev.buf,
            desc = 'Move focus ' .. dir .. ' (from terminal)',
          })
        end

        -- `q` records macros everywhere else in this config; inside lazygit's
        -- terminal it would be swallowed by lazygit anyway, so leave it alone.
        vim.opt_local.buflisted = false
      end,
    })
  end,
}
