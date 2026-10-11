return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local c = require('tokyonight.colors').setup()

    -- ── transparent per-mode theme ────────────────────────────────────
    local theme = {
      normal = { a = { fg = c.black, bg = c.blue, gui = 'bold' }, b = { fg = c.blue, bg = 'NONE' }, c = { fg = c.fg, bg = 'NONE' } },
      insert = { a = { fg = c.black, bg = c.green, gui = 'bold' }, b = { fg = c.green, bg = 'NONE' }, c = { fg = c.fg, bg = 'NONE' } },
      visual = { a = { fg = c.black, bg = c.magenta, gui = 'bold' }, b = { fg = c.magenta, bg = 'NONE' }, c = { fg = c.fg, bg = 'NONE' } },
      replace = { a = { fg = c.black, bg = c.red, gui = 'bold' }, b = { fg = c.red, bg = 'NONE' }, c = { fg = c.fg, bg = 'NONE' } },
      command = { a = { fg = c.black, bg = c.yellow, gui = 'bold' }, b = { fg = c.yellow, bg = 'NONE' }, c = { fg = c.fg, bg = 'NONE' } },
      inactive = { a = { fg = c.comment, bg = 'NONE' }, b = { fg = c.comment, bg = 'NONE' }, c = { fg = c.comment, bg = 'NONE' } },
    }

    -- ── custom components ─────────────────────────────────────────────

    -- macro recording
    local function macro_recording()
      local reg = vim.fn.reg_recording()
      if reg == '' then return '' end
      return '󰑊 @' .. reg
    end

    -- search count  e.g. [3/10]
    local function search_count()
      if vim.v.hlsearch == 0 then return '' end
      local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 50 })
      if not ok or result.total == 0 then return '' end
      return ('󰍉 [%d/%d]'):format(result.current, result.total)
    end

    -- active LSP clients
    local function lsp_clients()
      local clients = vim.lsp.get_clients { bufnr = 0 }
      if #clients == 0 then return '' end
      local names = vim.tbl_map(function(cl) return cl.name end, clients)
      return '󰒋 ' .. table.concat(names, ' ')
    end

    -- LSP progress spinner
    -- local function lsp_progress()
    --   local spinners = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
    --   local ms = vim.uv.hrtime() / 1e6
    --   local frame = math.floor(ms / 80) % #spinners
    --   for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    --     if client.progress and not vim.tbl_isempty(client.progress) then return spinners[frame + 1] .. ' LSP' end
    --   end
    --   return ''
    -- end

    -- indent style indicator
    local function indent_info()
      if vim.bo.expandtab then
        return '󱁐 ' .. vim.bo.shiftwidth
      else
        return '󰌒 ' .. vim.bo.tabstop
      end
    end

    -- file size
    local function file_size()
      local size = vim.fn.getfsize(vim.fn.expand '%')
      if size <= 0 then return '' end
      local units = { 'B', 'KB', 'MB', 'GB' }
      local i = 1
      while size >= 1024 and i < #units do
        size = size / 1024
        i = i + 1
      end
      return ('󰉉 %.1f%s'):format(size, units[i])
    end

    -- lazy.nvim pending updates
    local function lazy_updates()
      local ok, lazy = pcall(require, 'lazy.status')
      if ok and lazy.has_updates() then return '󰚰 ' .. lazy.updates() end
      return ''
    end

    -- current time
    local function clock() return '󱑍 ' .. os.date '%H:%M' end

    -- ── setup ─────────────────────────────────────────────────────────
    require('lualine').setup {
      options = {
        theme = theme,
        icons_enabled = true,
        globalstatus = true,
        section_separators = { left = '', right = '' },
        component_separators = { left = '│', right = '│' },
        disabled_filetypes = {
          statusline = { 'neo-tree', 'alpha', 'dashboard', 'lazy' },
        },
      },

      sections = {
        lualine_a = { 'mode' },

        lualine_b = {
          { 'branch', icon = '' },
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
          },
        },

        lualine_c = {
          {
            'filename',
            path = 1, -- relative path
            symbols = { modified = '●', readonly = '', unnamed = '[No Name]', newfile = '[New]' },
          },
          {
            'diagnostics',
            sources = { 'nvim_lsp', 'nvim_diagnostic' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = '󰠠 ' },
            colored = true,
          },
          -- macro recording (shown in red when active)
          {
            macro_recording,
            color = { fg = c.red, gui = 'bold' },
          },
          -- search count
          {
            search_count,
            color = { fg = c.yellow },
          },
          -- lsp progress spinner
          -- {
          --   lsp_progress,
          --   color = { fg = c.blue },
          -- },
        },

        lualine_x = {
          -- lazy pending updates
          {
            lazy_updates,
            color = { fg = c.yellow },
          },
          -- lsp client names
          {
            lsp_clients,
            color = { fg = c.cyan },
          },
          -- indent info
          {
            indent_info,
            color = { fg = c.comment },
          },
          -- file size
          {
            file_size,
            color = { fg = c.comment },
          },
          { 'encoding' },
          {
            'fileformat',
            symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' },
          },
          { 'filetype' },
        },

        lualine_y = { 'progress' },

        lualine_z = {
          'location',
          { clock, color = { fg = c.black, bg = c.blue } },
        },
      },

      inactive_sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'location' },
      },

      extensions = { 'neo-tree', 'toggleterm', 'lazy', 'mason', 'trouble', 'quickfix' },
    }

    -- ── force refresh on macro record start/stop ──────────────────────
    vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
      callback = function() require('lualine').refresh() end,
    })
  end,
}
