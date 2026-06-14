-- ════════════════════════════════════════════════════════════════════════════
--  custom.lang — reads `custom.languages` (the registry) and produces exactly
--  what each plugin needs. Plugins depend on THIS api, never on the raw data
--  (Open/Closed): adding a language touches only the registry.
--
--  Public API:
--    servers()            -> { server = settings }      (vim.lsp.config/enable)
--    formatters_by_ft()   -> { ft = {...} }             (conform.nvim)
--    linters_by_ft()      -> { ft = {...} }             (nvim-lint)
--    treesitter_ensure()  -> { 'parser', ... }          (nvim-treesitter install)
--    format_on_save_fts() -> { ft = true }              (conform format-on-save)
--    mason_ensure()       -> { 'pkg', ... }             (mason-tool-installer)
--    ensure_for_ft(ft)    -> installs missing Mason pkgs for a filetype, once
-- ════════════════════════════════════════════════════════════════════════════

local registry = require 'custom.languages'

local M = {}

-- ── Tool → Mason package translation ─────────────────────────────────────────
-- Formatters/linters whose conform/lint name differs from the Mason package, or
-- that we deliberately DO want Mason to manage. Tools that ship with their own
-- toolchain (rustfmt, gofmt, dart_format) are absent on purpose -> never installed.
local FORMATTER_TO_MASON = {
  stylua = 'stylua',
  prettier = 'prettier',
  prettierd = 'prettierd',
  biome = 'biome',
  black = 'black',
  isort = 'isort',
  ruff_format = 'ruff',
  clang_format = 'clang-format',
  shfmt = 'shfmt',
}

local LINTER_TO_MASON = {
  markdownlint = 'markdownlint',
  eslint_d = 'eslint_d',
  shellcheck = 'shellcheck',
  hadolint = 'hadolint',
}

-- ── Helpers ──────────────────────────────────────────────────────────────────

-- Filetypes a registry entry applies to (defaults to the entry's key).
local function entry_filetypes(name, entry)
  return entry.filetypes or { name }
end

-- conform/nvim-lint tables carry a `stop_after_first` boolean key mixed in with
-- the list — strip it when we only want the actual tool names.
local function tool_names(list)
  local names = {}
  for k, v in pairs(list) do
    if type(k) == 'number' then
      names[#names + 1] = v
    end
  end
  return names
end

-- Translate one LSP server name to its Mason package, preferring mason-lspconfig's
-- authoritative mapping and falling back to the server name itself.
local function server_to_mason(server)
  local ok, mlsp = pcall(require, 'mason-lspconfig')
  if ok and mlsp.get_mappings then
    local map = mlsp.get_mappings().lspconfig_to_package
    if map and map[server] then
      return map[server]
    end
  end
  return server
end

-- Build deduped lists once; cheap enough to recompute, but memoised for clarity.
local function dedupe(list)
  local seen, out = {}, {}
  for _, v in ipairs(list) do
    if not seen[v] then
      seen[v] = true
      out[#out + 1] = v
    end
  end
  return out
end

-- ── Public API ───────────────────────────────────────────────────────────────

function M.servers()
  local servers = {}
  for _, entry in pairs(registry) do
    for name, settings in pairs(entry.lsp or {}) do
      servers[name] = settings
    end
  end
  return servers
end

function M.formatters_by_ft()
  local by_ft = {}
  for name, entry in pairs(registry) do
    if entry.formatters then
      for _, ft in ipairs(entry_filetypes(name, entry)) do
        by_ft[ft] = entry.formatters
      end
    end
  end
  return by_ft
end

function M.linters_by_ft()
  local by_ft = {}
  for name, entry in pairs(registry) do
    if entry.linters then
      for _, ft in ipairs(entry_filetypes(name, entry)) do
        by_ft[ft] = entry.linters
      end
    end
  end
  return by_ft
end

-- Any filetype that has a formatter is eligible for format-on-save — one list,
-- derived, never maintained by hand.
function M.format_on_save_fts()
  local fts = {}
  for ft in pairs(M.formatters_by_ft()) do
    fts[ft] = true
  end
  return fts
end

-- Parser names come only from explicit `treesitter` fields — filetypes are NOT
-- assumed to be valid parser names (jsonc/sh/scss/... are not). Anything missed
-- here is still auto-installed on demand by the treesitter FileType autocmd.
function M.treesitter_ensure()
  local parsers = {}
  for _, entry in pairs(registry) do
    for _, p in ipairs(entry.treesitter or {}) do
      parsers[#parsers + 1] = p
    end
  end
  return dedupe(parsers)
end

-- Mason packages for mason-tool-installer (startup). LSP server names are passed
-- through verbatim: mason-tool-installer translates them via mason-lspconfig.
function M.mason_ensure()
  local pkgs = {}
  for _, entry in pairs(registry) do
    for server in pairs(entry.lsp or {}) do
      pkgs[#pkgs + 1] = server
    end
    for _, fmt in ipairs(tool_names(entry.formatters or {})) do
      if FORMATTER_TO_MASON[fmt] then
        pkgs[#pkgs + 1] = FORMATTER_TO_MASON[fmt]
      end
    end
    for _, lnt in ipairs(tool_names(entry.linters or {})) do
      if LINTER_TO_MASON[lnt] then
        pkgs[#pkgs + 1] = LINTER_TO_MASON[lnt]
      end
    end
    for _, extra in ipairs(entry.mason or {}) do
      pkgs[#pkgs + 1] = extra
    end
  end
  return dedupe(pkgs)
end

-- ── On-demand install ────────────────────────────────────────────────────────
-- Resolve the actual Mason package names a filetype needs (translated, ready to
-- query mason-registry).
local function mason_pkgs_for_ft(ft)
  local pkgs = {}
  for name, entry in pairs(registry) do
    local applies = vim.tbl_contains(entry_filetypes(name, entry), ft)
    -- A server may declare its own broader filetypes (e.g. tailwindcss on html).
    if not applies then
      for _, settings in pairs(entry.lsp or {}) do
        if type(settings) == 'table' and settings.filetypes and vim.tbl_contains(settings.filetypes, ft) then
          applies = true
          break
        end
      end
    end
    if applies then
      for server in pairs(entry.lsp or {}) do
        pkgs[#pkgs + 1] = server_to_mason(server)
      end
      for _, fmt in ipairs(tool_names(entry.formatters or {})) do
        if FORMATTER_TO_MASON[fmt] then
          pkgs[#pkgs + 1] = FORMATTER_TO_MASON[fmt]
        end
      end
      for _, lnt in ipairs(tool_names(entry.linters or {})) do
        if LINTER_TO_MASON[lnt] then
          pkgs[#pkgs + 1] = LINTER_TO_MASON[lnt]
        end
      end
      for _, extra in ipairs(entry.mason or {}) do
        pkgs[#pkgs + 1] = extra
      end
    end
  end
  return dedupe(pkgs)
end

local seen_fts = {}

-- Install any missing Mason packages for `ft`. Runs at most once per filetype
-- per session and only acts when something is actually missing.
function M.ensure_for_ft(ft)
  if ft == '' or seen_fts[ft] then
    return
  end
  seen_fts[ft] = true

  local ok, mr = pcall(require, 'mason-registry')
  if not ok then
    return
  end

  local function install_missing()
    for _, name in ipairs(mason_pkgs_for_ft(ft)) do
      if mr.has_package(name) then
        local pkg = mr.get_package(name)
        if not pkg:is_installed() then
          vim.notify(('[mason] installing %s for %s'):format(name, ft), vim.log.levels.INFO)
          pkg:install()
        end
      end
    end
  end

  -- mason-registry may still be refreshing its package list on a cold start.
  if mr.refresh then
    mr.refresh(install_missing)
  else
    install_missing()
  end
end

return M
