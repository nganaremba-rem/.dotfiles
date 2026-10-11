return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 300,
    win = {
      border = "rounded",
      padding = { 1, 2 },
      title = true,
      title_pos = "center",
    },
    spec = {
      -- -- Groups
      -- { "<leader>b", group = "Buffer", icon = "󰓩 " },
      -- { "<leader>c", group = "Code", icon = " " },
      -- { "<leader>f", group = "Find/File", icon = " " },
      -- { "<leader>g", group = "Git", icon = " " },
      -- { "<leader>s", group = "Search", icon = " " },
      -- { "<leader>w", group = "Window", icon = " " },
      -- -- LSP (buffer-local, registered on attach)
      -- { "g", group = "Goto", icon = " " },
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer Keymaps",
    },
  },
}
