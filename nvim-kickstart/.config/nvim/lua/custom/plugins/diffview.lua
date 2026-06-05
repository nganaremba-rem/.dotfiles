return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>',            desc = 'Diff view open' },
    { '<leader>gf', '<cmd>DiffviewFileHistory %<cr>',   desc = 'File history (current file)' },
    { '<leader>gF', '<cmd>DiffviewFileHistory<cr>',     desc = 'File history (repo)' },
    { '<leader>gc', '<cmd>DiffviewClose<cr>',           desc = 'Diff view close' },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default    = { layout = 'diff2_horizontal', winbar_info = true },
      merge_tool = { layout = 'diff3_horizontal', disable_diagnostics = true },
      file_history = { layout = 'diff2_horizontal', winbar_info = true },
    },
    file_panel = {
      listing_style    = 'tree',
      tree_options     = { flatten_dirs = true, folder_statuses = 'only_folded' },
      win_config       = { position = 'left', width = 35 },
    },
    hooks = {
      -- close diffview with Esc from any panel (not q — q = macro record)
      diff_buf_win_enter = function()
        vim.keymap.set('n', '<Esc>', '<cmd>DiffviewClose<cr>', { buffer = true, silent = true })
      end,
    },
  },
}
