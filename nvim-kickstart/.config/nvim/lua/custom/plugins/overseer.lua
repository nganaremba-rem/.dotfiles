-- ════════════════════════════════════════════════════════════════════════════
--  overseer.nvim — run / build / test / serve, driven by the language registry.
--
--  Commands are NOT listed here. They live in `custom.languages` under each
--  entry's `tasks` field, exactly like lsp / formatters / linters / treesitter do
--  — one place to edit, everything else derived. See `custom/lang/init.lua`.
--
--  Overseer's own template providers (npm scripts, cargo, make, .vscode/tasks.json)
--  stay enabled, so project-specific scripts show up under <leader>rc for free.
--
--    <leader>rr  run project        <leader>rl  live / dev server
--    <leader>rf  run THIS file      <leader>rc  pick any detected task
--    <leader>rb  build              <leader>ro  task list
--    <leader>rt  test               <leader>rq  quick action on last task
--                                   <leader>rw  watch: re-run on save
--
--  Build errors land in the quickfix list, so the existing [q / ]q maps
--  (custom/plugins/trouble.lua) navigate them with nothing new to learn.
-- ════════════════════════════════════════════════════════════════════════════

-- Task kinds whose whole point is "did it compile, and where did it break".
--
-- These run under the `jobstart` strategy rather than a terminal: a terminal is a
-- real PTY, so it hard-wraps long lines, which splits `path/file.c:12:5: error: …`
-- across rows and leaves the errorformat unable to extract a line number (every
-- quickfix entry lands on line 0). jobstart delivers whole lines, so quickfix and
-- diagnostics are accurate.
--
-- `run` and `serve` stay on the terminal — they are interactive and long-lived
-- (dev servers, REPLs, anything reading stdin), where a PTY is the point.
local PARSED = { build = true, test = true, file = true }

-- Look up one task kind for the current buffer and hand it to overseer.
local function run_kind(kind, label)
  return function()
    local lang = require 'custom.lang'
    local overseer = require 'overseer'

    local ft = vim.bo.filetype
    local tasks = lang.tasks_for_ft(ft)
    local cmd = tasks[kind]

    -- `run` falls back to `file` for languages that only make sense per-file
    -- (python, bash), and `serve` falls back to `run`.
    if not cmd and kind == 'run' then cmd = tasks.file end
    if not cmd and kind == 'serve' then cmd = tasks.run end
    if not cmd and kind == 'file' then cmd = tasks.run end

    if not cmd then
      Snacks.notify.warn(
        ('No `%s` task for filetype `%s`.\nAdd one under `tasks` in custom/languages.lua,\nor use <leader>rc to pick a detected task.'):format(kind, ft ~= '' and ft or '(none)'),
        { title = 'Overseer' }
      )
      return
    end

    -- Save first: running stale source is the single most confusing failure mode.
    if vim.bo.modifiable and vim.bo.modified then vim.cmd 'silent! write' end

    local name = ('%s: %s'):format(label, vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t'))
    local root = lang.project_root(0)

    local task
    if PARSED[kind] then
      task = overseer.new_task {
        name = name,
        cmd = cmd,
        cwd = root,
        strategy = 'jobstart',
        components = {
          'default',
          {
            'on_output_quickfix',
            open_on_match = true, -- jump to the list only when something failed
            items_only = true, -- drop chatter, keep real diagnostics
            set_diagnostics = true,
            relative_file_root = root,
          },
          'on_result_diagnostics',
        },
      }
    else
      task = overseer.new_task { name = name, cmd = cmd, cwd = root }
    end

    task:start()
    -- Interactive tasks get a visible split; parsed ones stay out of the way and
    -- speak through the quickfix list instead.
    if not PARSED[kind] then overseer.run_action(task, 'open hsplit') end
  end
end

return {
  'stevearc/overseer.nvim',
  cmd = {
    'OverseerRun',
    'OverseerToggle',
    'OverseerOpen',
    'OverseerRunCmd',
    'OverseerQuickAction',
    'OverseerTaskAction',
    'OverseerBuild',
    'OverseerInfo',
  },

  keys = {
    { '<leader>rr', run_kind('run', 'Run'), desc = 'Run: [r]un project' },
    { '<leader>rf', run_kind('file', 'Run file'), desc = 'Run: this [f]ile' },
    { '<leader>rb', run_kind('build', 'Build'), desc = 'Run: [b]uild' },
    { '<leader>rt', run_kind('test', 'Test'), desc = 'Run: [t]est' },
    { '<leader>rl', run_kind('serve', 'Serve'), desc = 'Run: [l]ive / dev server' },

    { '<leader>rc', '<cmd>OverseerRun<cr>', desc = 'Run: [c]hoose task (npm/cargo/make/tasks.json)' },
    { '<leader>ro', '<cmd>OverseerToggle<cr>', desc = 'Run: task list ([o]verseer)' },
    { '<leader>rq', '<cmd>OverseerQuickAction<cr>', desc = 'Run: [q]uick action on last task' },
    { '<leader>ra', '<cmd>OverseerTaskAction<cr>', desc = 'Run: [a]ction on a chosen task' },
    {
      '<leader>rw',
      function()
        local overseer = require 'overseer'
        local tasks = overseer.list_tasks { recent_first = true }
        if vim.tbl_isempty(tasks) then
          Snacks.notify.warn('No task to watch — run one first.', { title = 'Overseer' })
          return
        end
        overseer.run_action(tasks[1], 'watch')
      end,
      desc = 'Run: [w]atch last task (re-run on save)',
    },
  },

  opts = {
    -- Task output goes to a terminal buffer, same as any shell command.
    strategy = 'terminal',
    templates = { 'builtin' },
    task_list = {
      direction = 'bottom',
      min_height = 12,
      bindings = {
        -- Match this config's window navigation instead of overseer's defaults,
        -- which bind <C-h/j/k/l> to pane resizing.
        ['<C-h>'] = false,
        ['<C-j>'] = false,
        ['<C-k>'] = false,
        ['<C-l>'] = false,
        ['<Esc>'] = 'Close',
      },
    },
    form = { border = 'rounded' },
    confirm = { border = 'rounded' },
    task_win = { border = 'rounded' },
  },

  config = function(_, opts)
    require('overseer').setup(opts)

    -- Convenience command mirroring <leader>rr, for use from the cmdline.
    vim.api.nvim_create_user_command('Run', function(args)
      if args.args ~= '' then
        vim.cmd('OverseerRunCmd ' .. args.args)
      else
        run_kind('run', 'Run')()
      end
    end, { nargs = '*', desc = 'Run the project, or an arbitrary command' })
  end,
}
