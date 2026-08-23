-- ════════════════════════════════════════════════════════════════════════════
--  `:checkhealth custom` — invariants THIS config depends on.
--
--  Every check here exists because the invariant it guards was broken at least
--  once, silently, and cost an evening to find. They are cheap and read-only:
--  run this after adding a plugin, a keymap, or a language-registry entry.
--
--    1. keymap shadowing   two specs on one lhs → the winner is load order
--    2. prefix stalls      a map that is also a prefix waits `timeoutlen`
--    3. registry collisions two entries claiming one server/filetype
--    4. tool translation   a formatter/linter Mason will never install
--    5. external binaries  the things Mason cannot provide
--
--  See doc/CONFIG_GUIDE.md § "Invariants" for why each one matters.
-- ════════════════════════════════════════════════════════════════════════════

local M = {}

local ok_h, health = pcall(require, 'vim.health')
local start = (ok_h and health.start) or vim.health.start
local info = (ok_h and health.info) or vim.health.info
local report_ok = (ok_h and health.ok) or vim.health.ok
local warn = (ok_h and health.warn) or vim.health.warn
local err = (ok_h and health.error) or vim.health.error

local MODES = { 'n', 'i', 'v', 'x', 'o', 't', 'c' }

-- ── 1 + 2. Keymaps ───────────────────────────────────────────────────────────
-- Both checks read the LIVE keymap table, so they see what actually got mapped
-- after every plugin loaded — not what the specs claim.
local function check_keymaps()
  start 'Keymaps'

  -- A mapping whose lhs is a strict prefix of another mapping in the same mode
  -- cannot fire until `timeoutlen` (300ms here) has elapsed, because Neovim must
  -- first rule out the longer sequence. It feels like lag, never like a bug.
  local stalls, upstream, checked = {}, {}, 0
  local leader = vim.api.nvim_replace_termcodes(vim.g.mapleader == ' ' and '<Space>' or vim.g.mapleader, true, true, true)

  for _, mode in ipairs(MODES) do
    local lhs = {}
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      lhs[#lhs + 1] = vim.api.nvim_replace_termcodes(map.lhs, true, true, true)
    end
    checked = checked + #lhs

    local set = {}
    for _, k in ipairs(lhs) do
      set[k] = true
    end

    for _, k in ipairs(lhs) do
      -- Single-key maps are prefixes of everything and are not the problem;
      -- only look at sequences of two keys or more.
      if #k >= 2 then
        for _, other in ipairs(lhs) do
          if other ~= k and vim.startswith(other, k) then
            local line = ('mode %s: %s stalls %sms (also the prefix of %s)'):format(mode, k, vim.o.timeoutlen, other)
            -- Only maps THIS config owns are actionable. Upstream ships stalls
            -- on purpose — `gc`/`gcc` (built-in comment) and mini.surround's
            -- `sf`/`sfn` next/prev suffixes are the two that always show up —
            -- and rebinding them would cost more than the 300ms.
            if vim.startswith(k, leader) or k:match '^[%[%]]' then
              stalls[#stalls + 1] = line
            else
              upstream[#upstream + 1] = line
            end
            break
          end
        end
      end
    end
  end

  if #stalls == 0 then
    report_ok(('No prefix stalls among this config\'s own maps (%d global mappings checked)'):format(checked))
  else
    for _, s in ipairs(stalls) do
      warn(s)
    end
    info 'Fix: move the standalone map under the group prefix (e.g. <leader>b -> <leader>bb).'
  end

  if #upstream > 0 then
    info(('%d prefix stalls come from plugin/built-in defaults (gc/gcc, mini.surround s-suffixes) — expected'):format(#upstream))
  end

  -- Buffer-local maps legitimately shadow global ones (that is how LSP keymaps
  -- work), so only global duplicates are reported.
  local seen, dupes = {}, {}
  for _, mode in ipairs(MODES) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      local key = mode .. ' ' .. vim.api.nvim_replace_termcodes(map.lhs, true, true, true)
      if seen[key] then
        dupes[#dupes + 1] = key
      end
      seen[key] = true
    end
  end
  if #dupes == 0 then
    report_ok 'No duplicated global mappings'
  else
    for _, d in ipairs(dupes) do
      warn('duplicate mapping: ' .. d)
    end
  end
end

-- ── 3 + 4. Language registry ─────────────────────────────────────────────────
local function check_registry()
  start 'Language registry (custom.languages)'

  local ok, registry = pcall(require, 'custom.languages')
  if not ok then
    err('cannot load custom.languages: ' .. tostring(registry))
    return
  end
  local lang = require 'custom.lang'

  -- `M.servers()` is keyed by server name, so declaring one server in two
  -- entries means the second silently overwrites the first — including its
  -- `filetypes` list. This is how emmet used to lose its jsx filetypes.
  local server_owner, server_dupes = {}, 0
  local ft_owner, ft_dupes = {}, 0

  for name, entry in pairs(registry) do
    for server in pairs(entry.lsp or {}) do
      if server_owner[server] then
        err(('LSP server "%s" declared in BOTH `%s` and `%s` — the later one wins and the other settings are dropped'):format(server, server_owner[server], name))
        server_dupes = server_dupes + 1
      end
      server_owner[server] = name
    end

    -- formatters_by_ft / linters_by_ft are also last-write-wins per filetype.
    for _, ft in ipairs(entry.filetypes or { name }) do
      if ft_owner[ft] then
        err(('filetype "%s" claimed by BOTH `%s` and `%s` — formatters/linters of one are discarded'):format(ft, ft_owner[ft], name))
        ft_dupes = ft_dupes + 1
      end
      ft_owner[ft] = name
    end
  end

  if server_dupes == 0 then
    report_ok(('%d LSP servers, each declared once'):format(vim.tbl_count(server_owner)))
  end
  if ft_dupes == 0 then
    report_ok(('%d filetypes, each owned by one entry'):format(vim.tbl_count(ft_owner)))
  end

  -- A server whose `cmd` is pinned to an absolute path (rust_analyzer is pinned
  -- to the rustup component) fails to start with a bare "spawn failed" if that
  -- path ever moves — e.g. after `rustup component remove`. Check it here rather
  -- than discovering it mid-edit.
  local pinned_bad = 0
  for server, settings in pairs(lang.servers()) do
    local cmd = type(settings) == 'table' and settings.cmd
    if type(cmd) == 'table' and type(cmd[1]) == 'string' and cmd[1]:sub(1, 1) == '/' then
      if vim.fn.executable(cmd[1]) == 1 then
        report_ok(('%s pinned to %s'):format(server, cmd[1]))
      else
        pinned_bad = pinned_bad + 1
        err(('%s is pinned to %s, which is not executable'):format(server, cmd[1]))
      end
    end
  end
  if pinned_bad > 0 then
    info 'Fix: reinstall the tool (e.g. `rustup component add rust-analyzer`) or drop the `cmd` pin from the registry entry.'
  end

  -- A formatter/linter with no Mason translation is never installed, so conform
  -- silently formats nothing. Tools that ship with their own toolchain
  -- (rustfmt, gofmt, dart_format) are expected here and are not an error.
  local SELF_PROVIDED = {
    rustfmt = true,
    gofmt = true,
    goimports = true,
    dart_format = true,
    ['clang-format'] = true,
  }

  local missing = {}
  for ft, tools in pairs(lang.formatters_by_ft()) do
    for _, tool in ipairs(tools) do
      -- Compare on the MASON PACKAGE name: conform calls it `clang_format`,
      -- Mason ships it as `clang-format`. Comparing the raw tool name reports
      -- every renamed tool as missing.
      local pkg = lang.mason_pkg_for_tool(tool)
      if type(tool) == 'string' and not SELF_PROVIDED[tool] and vim.fn.executable(tool) == 0 then
        if not (pkg and vim.tbl_contains(lang.mason_ensure(), pkg)) then
          missing[#missing + 1] = ('%s (formatter for %s)'):format(tool, ft)
        end
      end
    end
  end
  if #missing == 0 then
    report_ok 'Every registry formatter is either installed or Mason-managed'
  else
    for _, m in ipairs(missing) do
      warn('not installed and not in mason_ensure(): ' .. m)
    end
    info 'Fix: add the tool to FORMATTER_TO_MASON / LINTER_TO_MASON in lua/custom/lang/init.lua.'
  end
end

-- ── 5. External binaries ─────────────────────────────────────────────────────
local function check_binaries()
  start 'External tools'

  -- required = the config degrades visibly without it.
  local required = {
    git = 'plugin installs, gitsigns, diffview',
    rg = 'Snacks.picker files/grep (and :grep)',
    node = 'vtsls, eslint, emmet, markdown-preview',
  }
  local optional = {
    lazygit = '<leader>gg',
    fd = 'faster file finding',
    make = 'building LuaSnip jsregexp and avante',
    unzip = 'Mason package extraction',
    ['live-server'] = '<leader>rl for plain html projects',
    cargo = 'rust-analyzer analysis + <leader>r… rust tasks',
  }

  for exe, why in pairs(required) do
    if vim.fn.executable(exe) == 1 then
      report_ok(('%s — %s'):format(exe, why))
    else
      err(('%s MISSING — needed for %s'):format(exe, why))
    end
  end
  for exe, why in pairs(optional) do
    if vim.fn.executable(exe) == 1 then
      report_ok(('%s — %s'):format(exe, why))
    else
      warn(('%s not found — %s will not work'):format(exe, why))
    end
  end
end

-- ── 6. Single-owner invariants ───────────────────────────────────────────────
-- Several plugins here want to own the same global. Whichever loads last wins,
-- so the config picks a winner explicitly; this verifies the pick held.
local function check_ownership()
  start 'Single-owner globals'

  local noice_ok = pcall(require, 'noice')
  local snacks_ok = _G.Snacks ~= nil
  if noice_ok and snacks_ok then
    -- noice sets notify.enabled = false in its opts, so Snacks must own notify.
    local notify_src = debug.getinfo(vim.notify, 'S').source or ''
    if notify_src:find 'snacks' then
      report_ok 'vim.notify is owned by Snacks.notifier (noice notify disabled)'
    elseif notify_src:find 'noice' then
      warn 'vim.notify is owned by noice — custom/plugins/noice.lua sets notify.enabled = false, so this is unexpected'
    else
      info('vim.notify source: ' .. notify_src)
    end
  end

  -- Two ghost-text providers on screen at once render on top of each other.
  -- blink is lazy (InsertEnter). Before it loads, `blink.cmp.config` still
  -- answers with upstream DEFAULTS, not this config — checking then reports a
  -- ghost-text conflict that does not exist. Only ask once it is really loaded.
  local lazy_ok, lazy_cfg = pcall(require, 'lazy.core.config')
  local blink_loaded = lazy_ok and lazy_cfg.plugins['blink.cmp'] and lazy_cfg.plugins['blink.cmp']._.loaded
  local blink_ok, blink_cfg = pcall(require, 'blink.cmp.config')
  if not blink_loaded then
    info 'blink.cmp not loaded yet (it loads on InsertEnter) — enter insert mode and re-run to check ghost-text ownership'
  elseif blink_ok and blink_cfg.completion and blink_cfg.completion.ghost_text then
    if blink_cfg.completion.ghost_text.enabled then
      warn 'blink.cmp ghost_text is ENABLED and so is the AI provider — they will overlap. Disable one (custom/plugins/blink.lua).'
    else
      report_ok 'Ghost text has exactly one owner (the AI completion provider)'
    end
  end
end

M.check = function()
  check_keymaps()
  check_registry()
  check_binaries()
  check_ownership()
end

return M
