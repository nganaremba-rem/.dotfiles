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
    lsp = { rust_analyzer = {} },
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
    lsp = { emmet_ls = {} },
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
