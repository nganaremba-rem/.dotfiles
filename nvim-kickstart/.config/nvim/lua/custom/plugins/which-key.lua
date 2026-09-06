return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VeryLazy',
  ---@module 'which-key'
  ---@type wk.Opts
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    -- delay between pressing a key and opening which-key (milliseconds)
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },

    -- Never pop up over a terminal buffer (lazygit included). The popup is a
    -- floating window of its own; opening it while focus sits in another
    -- float (lazygit) and then dismissing it with <Esc> does not reliably
    -- hand focus back to that float — it drops behind the code window
    -- instead. Terminals forward <leader> straight to the program anyway.
    disable = { bt = { 'terminal' } },

    -- Every prefix that owns keys is registered, so nothing shows up unlabelled.
    -- Invariant worth keeping: a prefix is EITHER a group OR a standalone map,
    -- never both — otherwise the standalone one stalls for `timeoutlen` (300ms).
    spec = {
      { '<leader>b', group = '[B]uffer' },
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]ebug' },
      { '<leader>f', group = '[F]ind / Replace' },
      { '<leader>fi', group = 'Flutter' },
      { '<leader>g', group = '[G]it' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { '<leader>m', group = 'Har[m]poon (marks)' },
      { '<leader>r', group = '[R]un / Build' },
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]erminal' },
      { '<leader>k', group = 'Claude Code' },
      { '<leader>u', group = '[U]I / Toggle' },
      { '<leader>x', group = 'Diagnostics' },
      { '<leader>a', group = '[A]I (avante)', mode = { 'n', 'v' } },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
    },
  },
}
