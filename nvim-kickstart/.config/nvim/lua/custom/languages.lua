-- ════════════════════════════════════════════════════════════════════════════
--  Language registry — the SINGLE SOURCE OF TRUTH for per-language tooling.
--
--  Adding support for a new language = add ONE entry here. Everything else
--  (LSP, formatting, linting, treesitter, Mason install at startup AND on-demand
--  when you first open the filetype) is derived automatically by `custom.lang`.
--  You never hand-edit the lsp / conform / lint / treesitter plugin files again.
--
--  Entry shape (every field is optional — omit what you don't need):
--    <name> = {
--      filetypes  = { 'ft1', 'ft2' },  -- defaults to { <name> } if omitted
--      lsp        = { server_name = <settings table> },  -- settings: {} = defaults
--      formatters = { 'fmt1', 'fmt2', stop_after_first = true },  -- conform syntax
--      linters    = { 'linter1' },     -- nvim-lint syntax
--      treesitter = { 'parser1' },     -- extra parsers (filetype is added anyway)
--      mason      = { 'extra-pkg' },   -- escape hatch: extra Mason packages to install
--    }
--
--  Tool→Mason package name translation lives in `custom.lang`; tools that ship
--  with their own toolchain (rustfmt, dart_format, gofmt) are intentionally not
--  Mason-installed.
-- ════════════════════════════════════════════════════════════════════════════

return {
  lua = {
    filetypes = { 'lua' },
    lsp = {
      -- Special Lua config recommended by the Neovim docs: teach lua_ls about
      -- the Neovim runtime and let stylua own formatting.
      lua_ls = {
        on_init = function(client)
          client.server_capabilities.documentFormattingProvider = false
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
              return
            end
          end
          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
              path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            workspace = {
              checkThirdParty = false,
              library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                '${3rd}/luv/library',
                '${3rd}/busted/library',
              }),
            },
          })
        end,
        settings = {
          Lua = {
            format = { enable = false }, -- stylua handles formatting
          },
        },
      },
    },
    formatters = { 'stylua' },
    treesitter = { 'lua', 'luadoc' },
  },

  python = {
    filetypes = { 'python' },
    lsp = { pyright = {} },
    formatters = { 'ruff_format', 'isort', 'black', stop_after_first = true },
    treesitter = { 'python' },
  },

  rust = {
    filetypes = { 'rust' },
    lsp = { rust_analyzer = {} },
    formatters = { 'rustfmt' }, -- ships with the rust toolchain (rustup component)
    treesitter = { 'rust' },
  },

  go = {
    filetypes = { 'go' },
    lsp = { gopls = {} },
    formatters = { 'gofmt' }, -- ships with the Go toolchain
    treesitter = { 'go', 'gomod', 'gosum' },
  },

  c = {
    filetypes = { 'c', 'cpp' },
    lsp = { clangd = {} },
    formatters = { 'clang_format' },
    treesitter = { 'c', 'cpp' },
  },

  -- Web stack: one entry owns JS/TS + the servers that span those filetypes.
  web = {
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    lsp = {
      vtsls = {
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
      },
      eslint = {
        settings = {
          codeActionOnSave = { enable = true, mode = 'all' },
        },
      },
      tailwindcss = {
        filetypes = { 'html', 'css', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'svelte' },
      },
    },
    formatters = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
    treesitter = { 'javascript', 'typescript', 'tsx' },
  },

  css = {
    filetypes = { 'css', 'scss', 'less' },
    lsp = { cssls = {} },
    formatters = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
    treesitter = { 'css' },
  },

  html = {
    filetypes = { 'html' },
    lsp = { emmet_ls = {} },
    formatters = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
    treesitter = { 'html' },
  },

  dart = {
    filetypes = { 'dart' },
    -- LSP/format for Dart is owned by flutter-tools.nvim, not Mason.
    formatters = { 'dart_format' },
    treesitter = { 'dart' },
  },

  json = {
    filetypes = { 'json', 'jsonc' },
    lsp = { jsonls = {} },
    formatters = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
    treesitter = { 'json' }, -- the `json` parser also handles jsonc
  },

  yaml = {
    filetypes = { 'yaml' },
    lsp = { yamlls = {} },
    formatters = { 'prettierd', 'prettier', stop_after_first = true },
    treesitter = { 'yaml' },
  },

  toml = {
    filetypes = { 'toml' },
    lsp = { taplo = {} },
    treesitter = { 'toml' },
  },

  markdown = {
    filetypes = { 'markdown' },
    lsp = { marksman = {} },
    linters = { 'markdownlint' },
    treesitter = { 'markdown', 'markdown_inline' },
  },

  bash = {
    filetypes = { 'sh', 'bash', 'zsh' },
    lsp = { bashls = {} },
    formatters = { 'shfmt' },
    treesitter = { 'bash' },
  },

  docker = {
    filetypes = { 'dockerfile' },
    lsp = { dockerls = {} },
    treesitter = { 'dockerfile' },
  },
}
