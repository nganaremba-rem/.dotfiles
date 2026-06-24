-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '<leader>e', ':Neotree toggle<CR>', desc = 'NeoTree toggle', silent = true },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    window = {
      width = 28,
    },
    filesystem = {
      use_libuv_file_watcher = true,
      follow_current_file = {
        enabled = true,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
  config = function(_, opts)
    require('neo-tree').setup(opts)

    local function resize_neotree(delta)
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
        if ft == 'neo-tree' then
          local w = vim.api.nvim_win_get_width(win)
          vim.api.nvim_win_set_width(win, math.max(10, w + delta))
          break
        end
      end
    end

    vim.keymap.set('n', '<C-A-->', function() resize_neotree(-5) end, { desc = 'NeoTree shrink', silent = true })
    vim.keymap.set('n', '<C-A-=>', function() resize_neotree(5) end, { desc = 'NeoTree grow', silent = true })

    -- Refresh git status whenever the index or HEAD changes (stage, commit, checkout, etc.)
    local refresh = vim.schedule_wrap(function()
      local ok, manager = pcall(require, 'neo-tree.sources.manager')
      if ok then
        manager.refresh 'filesystem'
        manager.refresh 'git_status'
      end
    end)

    local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ';')
    if git_dir ~= '' then
      local abs_git = vim.fn.fnamemodify(git_dir, ':p')
      local watch_paths = { abs_git .. 'index', abs_git .. 'HEAD', abs_git .. 'refs' }
      for _, path in ipairs(watch_paths) do
        local w = vim.uv.new_fs_event()
        if w then w:start(path, {}, function(err)
          if not err then refresh() end
        end) end
      end
    end

    -- Also refresh on BufWritePost so edits show up immediately
    vim.api.nvim_create_autocmd('BufWritePost', {
      callback = refresh,
    })
  end,
}
