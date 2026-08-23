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
--      mason_exclude = { 'tool' },     -- never Mason-install these (the toolchain
--                                      -- provides them: rustup, go, dart, …)
--      tasks      = {                  -- overseer templates (<leader>r…)
--        run   = 'cargo run',          --   <leader>rr  run the project
--        build = 'cargo build',        --   <leader>rb  build
--        test  = 'cargo test',         --   <leader>rt  test
--        file  = 'go run $FILE',       --   <leader>rf  run just this file
--        serve = 'npm run dev',        --   <leader>rl  dev / live server
--      },
--    }
--
--  Task placeholders, expanded when the task is built:
--    $FILE  absolute path of the current file      $DIR   its directory
--    $STEM  basename without extension             $ROOT  detected project root
--    $TMP   a scratch directory                    $PM    npm | pnpm | yarn | bun
--    $OUT   pre-joined build output path — use this for compiler -o targets
--    $NAME  identifier-safe stem (rustc --crate-name, javac class name, …)
--  All except $PM are shell-quoted, so never wrap them in quotes yourself.
--
--  Tool→Mason package name translation lives in `custom.lang`; tools that ship
--  with their own toolchain (rustfmt, dart_format, gofmt) are intentionally not
--  Mason-installed.
-- ════════════════════════════════════════════════════════════════════════════

-- rust-analyzer, preferring the rustup COMPONENT over the Mason package.
--
-- Both can be installed at once, and `cmd = { 'rust-analyzer' }` (nvim-lspconfig's
-- default) just takes whatever PATH resolves first — which is Mason's, because
-- mason.nvim prepends its bin dir. The rustup component is the better choice
-- here: it is built against the exact toolchain that compiles your code, so the
-- proc-macro server ABI always matches (a mismatch shows up as "proc macro
-- server crashed" on serde/derive-heavy crates), and the shim honours a
-- project's `rust-toolchain.toml` override automatically.
--
-- Falls back to a bare 'rust-analyzer' (i.e. PATH, i.e. Mason) on a machine with
-- no rustup, so this config still works there.
local function rust_analyzer_cmd()
  local cargo_home = vim.env.CARGO_HOME or (vim.env.HOME .. '/.cargo')
  local shim = cargo_home .. '/bin/rust-analyzer'
  if vim.fn.executable(shim) == 1 then return { shim } end
  return { 'rust-analyzer' }
end

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
    tasks = {
      file = 'nvim -l $FILE',
      test = 'busted',
    },
  },

  python = {
    filetypes = { 'python' },
    lsp = { pyright = {} },
    formatters = { 'ruff_format', 'isort', 'black', stop_after_first = true },
    treesitter = { 'python' },
    tasks = {
      run = 'python3 $FILE',
      file = 'python3 $FILE',
      test = 'pytest',
    },
  },

  rust = {
    filetypes = { 'rust' },
    -- Single-file .rs buffers (no Cargo.toml) get no completions from
    -- rust-analyzer until they are registered as a standalone `linkedProjects`
    -- entry. That happens in the LspAttach handler in
    -- custom/plugins/nvim-lspconfig.lua — it cannot live here, because
    -- nvim-lspconfig already owns `on_attach` for this server.
    lsp = { rust_analyzer = { cmd = rust_analyzer_cmd() } },
    -- ...and with the toolchain's own binary pinned above, the Mason package
    -- would be a second copy that is downloaded, updated, and never run.
    mason_exclude = { 'rust_analyzer' },
    formatters = { 'rustfmt' }, -- ships with the rust toolchain (rustup component)
    treesitter = { 'rust' },
    tasks = {
      run = 'cargo run',
      build = 'cargo build',
      test = 'cargo test',
      -- Single-file: compile into the cache dir so the project stays clean.
      -- --crate-name: rustc derives it from the filename, and rejects spaces.
      file = 'rustc $FILE --crate-name $NAME -o $OUT && $OUT',
    },
  },

  go = {
    filetypes = { 'go' },
    lsp = { gopls = {} },
    formatters = { 'gofmt' }, -- ships with the Go toolchain
    treesitter = { 'go', 'gomod', 'gosum' },
    tasks = {
      run = 'go run .',
      build = 'go build ./...',
      test = 'go test ./...',
      file = 'go run $FILE',
    },
  },

  c = {
    filetypes = { 'c', 'cpp' },
    lsp = { clangd = {} },
    formatters = { 'clang_format' },
    treesitter = { 'c', 'cpp' },
    tasks = {
      run = 'make run',
      build = 'make',
      test = 'make test',
      file = 'cc $FILE -Wall -o $OUT && $OUT',
    },
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
      -- Emmet abbreviations (`div` -> <div></div>, `ul>li*3`, `.card`). Declared
      -- here, once, for EVERY markup filetype including html — `M.servers()` keys
      -- by server name, so a second emmet entry elsewhere would just overwrite
      -- this one. jsx/tsx get className instead of class automatically.
      emmet_language_server = {
        filetypes = { 'html', 'css', 'scss', 'less', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'svelte' },
      },
    },
    formatters = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
    treesitter = { 'javascript', 'typescript', 'tsx' },
    -- $PM resolves to bun / pnpm / npm from the project's lockfile.
    tasks = {
      run = '$PM run dev',
      build = '$PM run build',
      test = '$PM test',
      file = 'node $FILE',
      serve = '$PM run dev',
    },
  },

  css = {
    filetypes = { 'css', 'scss', 'less' },
    lsp = { cssls = {} },
    formatters = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
    treesitter = { 'css' },
    tasks = {
      serve = 'live-server $ROOT',
    },
  },

  html = {
    filetypes = { 'html' },
    -- LSP: emmet_language_server is declared in the `web` entry above and already
    -- covers html; vscode-html-language-server is not used here.
    lsp = {},
    formatters = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
    treesitter = { 'html' },
    tasks = {
      -- Plain static page: serve the file's own directory so relative assets work.
      run = 'live-server $DIR',
      serve = 'live-server $DIR',
    },
  },

  dart = {
    filetypes = { 'dart' },
    -- LSP/format for Dart is owned by flutter-tools.nvim, not Mason.
    formatters = { 'dart_format' },
    treesitter = { 'dart' },
    -- NOTE: <leader>fi… (flutter-tools) is preferred for app work — it does hot
    -- reload, which a one-shot task cannot.
    tasks = {
      run = 'flutter run',
      build = 'flutter build apk --debug',
      test = 'flutter test',
      file = 'dart run $FILE',
    },
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
    tasks = {
      run = 'bash $FILE',
      file = 'bash $FILE',
    },
  },

  docker = {
    filetypes = { 'dockerfile' },
    lsp = { dockerls = {} },
    treesitter = { 'dockerfile' },
  },
}
