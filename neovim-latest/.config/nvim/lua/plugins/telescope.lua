return {
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- optional but recommended
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      -- symbols in current file
      { "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>",          desc = "Document symbols" },
      -- symbols across whole project
      { "<leader>sS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace symbols" },
      -- find files
      { "<leader>ff", "<cmd>Telescope find_files<cr>",                    desc = "Find files" },
      -- live grep (like ctrl+shift+f in vscode)
      { "<C-S-f>",    "<cmd>Telescope live_grep<cr>",                     desc = "Find in project" },
      -- grep word under cursor
      { "<leader>sw", "<cmd>Telescope grep_string<cr>",                   desc = "Search word under cursor" },
      -- recent files
      { "<leader>fo", "<cmd>Telescope oldfiles<cr>",                      desc = "Recent files" },
      -- open buffers
      { "<leader>fb", "<cmd>Telescope buffers<cr>",                       desc = "Buffers" },

      { "<leader>xx", "<cmd>Telescope diagnostics<cr>",                   desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Telescope diagnostics bufnr=0<cr>",           desc = "Buffer Diagnostics" },
      { "<leader>cl", "<cmd>Telescope lsp_references<cr>",                desc = "LSP References" },
      { "<leader>xl", "<cmd>Telescope loclist<cr>",                       desc = "Location List" },
      { "<leader>xq", "<cmd>Telescope quickfix<cr>",                      desc = "Quickfix List" },
    },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader><leader>", builtin.find_files, { desc = "Telescope find files" })
      vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "Telescope live grep" })
      vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Telescope buffers" })
      vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "Telescope help tags" })
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    opts = {
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({
            -- even more opts
          }),

          -- pseudo code / specification for writing custom displays, like the one
          -- for "codeactions"
          -- specific_opts = {
          --   [kind] = {
          --     make_indexed = function(items) -> indexed_items, width,
          --     make_displayer = function(widths) -> displayer
          --     make_display = function(displayer) -> function(e)
          --     make_ordinal = function(e) -> string
          --   },
          --   -- for example to disable the custom builtin "codeactions" display
          --      do the following
          --   codeactions = false,
          -- }
        },
      },
    },
    config = function()
      require("telescope").load_extension("ui-select")
    end,
  },
}
