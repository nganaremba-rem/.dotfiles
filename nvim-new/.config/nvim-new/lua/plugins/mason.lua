return {
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "rust_analyzer", "tailwindcss", "html", "vtsls" },
      -- automatic_enable is now default in newer mason-lspconfig
    },
  },
  {
    "neovim/nvim-lspconfig",
    -- No `opts` with old-style setup anymore
    config = function()
      -- 1. Global inlay hints (recommended)
      vim.lsp.config("*", {
        inlay_hints = { enabled = true },
      })

      -- 2. Configure individual servers (this merges with nvim-lspconfig defaults)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            hint = { enable = true },
            -- your other lua settings if any
          },
        },
      })

      vim.lsp.config("vtsls", {
        settings = {
          typescript = {
            inlayHints = {
              parameterNames = { enabled = "all" },
              parameterTypes = { enabled = true },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              enumMemberValues = { enabled = true },
            },
          },
          javascript = {
            inlayHints = {
              parameterNames = { enabled = "all" },
              parameterTypes = { enabled = true },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              enumMemberValues = { enabled = true },
            },
          },
        },
      })

      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            inlayHints = {
              bindingModeHints = { enable = true },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true },
              closureReturnTypeHints = { enable = "always" },
              lifetimeElisionHints = { enable = "always" },
              parameterHints = { enable = true },
              reborrowHints = { enable = "always" },
              renderColons = true,
              typeHints = { enable = true },
            },
          },
        },
      })

      -- 3. Enable the servers you want (mason will install them automatically)
      vim.lsp.enable({
        "lua_ls",
        "rust_analyzer",
        "tailwindcss",
        "html",
        "vtsls",
      })

      require('lspsaga').setup({
        ui = {
          border = "rounded",
        },
        hover = {
          max_width = 0.6,
          open_link = "gx",
          open_browser = "!firefox",
        },
        lightbulb = {
          enable = false,
          sign = false,
        },
        scroll_preview = {
          scroll_down = "<C-f>",
          scroll_up = "<C-b>",
        },
        request_timeout = 2000,
        finder = {
          max_height = 0.5,
        },
      })
    end,
  },
}
