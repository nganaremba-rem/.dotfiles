-- ════════════════════════════════════════════════════════════════════════════
--  snacks.nvim — the QoL layer. Replaces, in one dependency:
--
--    telescope + telescope-fzf-native + telescope-ui-select  -> picker
--    dressing.nvim (archived Feb 2025)                       -> input + ui_select
--    nvim-notify                                             -> notifier
--    toggleterm.nvim                                         -> terminal (see terminal.lua)
--    indent-blankline.nvim                                   -> indent + scope
--
--  Every telescope keymap is ported here with its EXACT original lhs and desc,
--  so nothing you already know changes — only the engine behind it.
--
--  NOT enabled on purpose:
--    explorer — neo-tree owns file browsing
--    image    — foot speaks sixel, not the Kitty graphics protocol
--    scroll   — smooth scrolling fights terminal-native scrolling over ssh/tmux
-- ════════════════════════════════════════════════════════════════════════════

-- Directories that should never appear in a file/grep result.
local EXCLUDE = {
  '.git',
  'node_modules',
  '.next',
  'dist',
  'build',
  'target',
  '.venv',
  '__pycache__',
}

-- The search profile that makes `.env` findable.
--
-- `hidden` and `ignored` are SEPARATE filters and BOTH are required:
--   hidden  -> passes `--hidden`    ; without it dotfiles are skipped entirely
--   ignored -> passes `--no-ignore` ; without it `.gitignore` still wins, so
--              `.env` stays invisible even when `hidden = true`
--
-- Setting only `hidden` is the exact bug this config had under telescope: it made
-- `.env.local` appear while `.env` (gitignored) stayed hidden.
--
-- Caveat: snacks passes `--no-ignore`, not `--no-ignore-vcs`, so `.ignore` and
-- `.fdignore` files stop applying too. `exclude` below is what keeps the noise out.
local FIND = { hidden = true, ignored = true, exclude = EXCLUDE }

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,

  ---@type snacks.Config
  opts = {
    -- ── Silent quality-of-life ────────────────────────────────────────────
    bigfile = { enabled = true }, -- drop treesitter/LSP on huge files
    quickfile = { enabled = true }, -- paint the file before plugins finish loading

    -- ── UI ────────────────────────────────────────────────────────────────
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000, style = 'compact' },
    indent = { enabled = true, animate = { enabled = false } },
    scope = { enabled = true },
    words = { enabled = true },
    zen = { enabled = true },
    scratch = { enabled = true },

    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = ' ', key = 'f', desc = 'Find file', action = ':lua Snacks.picker.files()' },
          { icon = ' ', key = 'n', desc = 'New file', action = ':ene | startinsert' },
          { icon = ' ', key = 'g', desc = 'Grep text', action = ':lua Snacks.picker.grep()' },
          { icon = ' ', key = 'r', desc = 'Recent files', action = ':lua Snacks.picker.recent()' },
          { icon = ' ', key = 'e', desc = 'File tree', action = ':Neotree toggle' },
          { icon = ' ', key = 'c', desc = 'Config', action = ':lua Snacks.picker.files({ cwd = vim.fn.stdpath("config") })' },
          { icon = '󰊢 ', key = 'G', desc = 'Lazygit', action = ':lua Snacks.lazygit()' },
          { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy' },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'startup' },
      },
    },

    -- ── Picker ────────────────────────────────────────────────────────────
    picker = {
      ui_select = true, -- vim.ui.select goes through the picker (replaces dressing)
      sources = {
        files = FIND,
        grep = FIND,
        grep_word = FIND,
        grep_buffers = { hidden = true, ignored = true },
        smart = FIND,
      },
    },
  },

  keys = {
    -- ── Search (<leader>s…) — identical lhs + desc to the old telescope maps ──
    { '<leader>sh', function() Snacks.picker.help() end, desc = '[S]earch [H]elp' },
    { '<leader>sk', function() Snacks.picker.keymaps() end, desc = '[S]earch [K]eymaps' },
    { '<leader>sf', function() Snacks.picker.files() end, desc = '[S]earch [F]iles' },
    { '<leader>ss', function() Snacks.picker.pickers() end, desc = '[S]earch [S]elect picker' },
    { '<leader>sw', function() Snacks.picker.grep_word() end, mode = { 'n', 'x' }, desc = '[S]earch current [W]ord' },
    { '<leader>sg', function() Snacks.picker.grep() end, desc = '[S]earch by [G]rep' },
    { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', function() Snacks.picker.resume() end, desc = '[S]earch [R]esume' },
    { '<leader>s.', function() Snacks.picker.recent() end, desc = '[S]earch Recent Files ("." for repeat)' },
    { '<leader>sc', function() Snacks.picker.commands() end, desc = '[S]earch [C]ommands' },
    { '<leader>sb', function() Snacks.picker.buffers() end, desc = 'Find existing buffers' },
    { '<leader>s/', function() Snacks.picker.grep_buffers() end, desc = '[S]earch [/] in Open Files' },
    { '<leader>sn', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, desc = '[S]earch [N]eovim files' },
    { '<leader>su', function() Snacks.picker.undo() end, desc = '[S]earch [U]ndo history' },
    { '<leader>sm', function() Snacks.picker.marks() end, desc = '[S]earch [M]arks' },
    { '<leader>sq', function() Snacks.picker.qflist() end, desc = '[S]earch [Q]uickfix' },

    { '<leader><leader>', function() Snacks.picker.files() end, desc = 'Search Files' },
    { '<leader>/', function() Snacks.picker.lines() end, desc = '[/] Fuzzily search in current buffer' },

    -- ── Git ───────────────────────────────────────────────────────────────
    { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazygit' },
    { '<leader>lg', function() Snacks.lazygit() end, desc = 'Lazygit' },
    { '<leader>gL', function() Snacks.lazygit.log() end, desc = 'Lazygit [L]og' },
    { '<leader>gB', function() Snacks.gitbrowse() end, mode = { 'n', 'v' }, desc = 'Git browse (open in web)' },

    -- ── Buffers ───────────────────────────────────────────────────────────
    { '<leader>bd', function() Snacks.bufdelete() end, desc = '[d]elete buffer (keep layout)' },
    { '<leader>bo', function() Snacks.bufdelete.other() end, desc = 'Delete [o]ther buffers' },

    -- ── UI toggles / misc ─────────────────────────────────────────────────
    { '<leader>uz', function() Snacks.zen() end, desc = 'Toggle [z]en mode' },
    { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle scratch buffer' },
    { '<leader>S', function() Snacks.scratch.select() end, desc = 'Select scratch buffer' },
    { '<leader>cR', function() Snacks.rename.rename_file() end, desc = 'Code: [R]ename file (LSP-aware)' },

    -- ── LSP reference hopping (snacks.words) ──────────────────────────────
    { ']]', function() Snacks.words.jump(vim.v.count1) end, mode = { 'n', 't' }, desc = 'Next reference' },
    { '[[', function() Snacks.words.jump(-vim.v.count1) end, mode = { 'n', 't' }, desc = 'Prev reference' },
  },

  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Debug helpers on the global, as upstream recommends.
        _G.dd = function(...) Snacks.debug.inspect(...) end
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd

        -- LSP pickers, buffer-local on attach. These replace the identical block
        -- that used to live in custom/plugins/telescope.lua — same lhs, same desc.
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('snacks-lsp-attach', { clear = true }),
          callback = function(event)
            local map = function(keys, fn, desc)
              vim.keymap.set('n', keys, fn, { buffer = event.buf, desc = desc })
            end
            map('grr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
            map('gri', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
            map('grd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
            map('grt', function() Snacks.picker.lsp_type_definitions() end, '[G]oto [T]ype Definition')
            map('gO', function() Snacks.picker.lsp_symbols() end, 'Open Document Symbols')
            map('gW', function() Snacks.picker.lsp_workspace_symbols() end, 'Open Workspace Symbols')

            -- `gd` kept from the lspsaga era, now backed by the picker (previewed).
            map('gd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
          end,
        })
      end,
    })
  end,
}
