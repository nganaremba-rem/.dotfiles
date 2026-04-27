return {
  "saghen/blink.cmp",
  -- optional: provides snippets for the snippet source
  dependencies = { "rafamadriz/friendly-snippets", "dmitmel/cmp-digraphs" },

  -- use a release tag to download pre-built binaries
  version = "1.*",
  -- AND/OR build from source
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap

    keymap = {
      preset = "super-tab",
      ["<CR>"] = { "select_and_accept", "fallback" },
    },

    opts = {
      completion = {
        ghost_text = { enabled = true }
      }
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = false } },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        -- create provider
        digraphs = {
          -- IMPORTANT: use the same name as you would for nvim-cmp
          name = "digraphs",
          module = "blink.compat.source",

          -- all blink.cmp source config options work as normal:
          score_offset = -3,

          -- this table is passed directly to the proxied completion source
          -- as the `option` field in nvim-cmp's source config
          --
          -- this is NOT the same as the opts in a plugin's lazy.nvim spec
          opts = {
            -- this is an option from cmp-digraphs
            cache_digraphs_on_start = true,

            -- If you'd like to use a `name` that does not exactly match nvim-cmp,
            -- set `cmp_name` to the name you would use for nvim-cmp, for instance:
            -- cmp_name = "digraphs"
            -- then, you can set the source's `name` to whatever you like.
          },
        },
      },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
