return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = true,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false,                    -- neo-tree will lazily load itself
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle NeoTree" },
    },
    opts = {
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
      },
    },
  },
}
