return {
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend = "kitty", -- or "wezterm", "ueberzug"
      integrations = {
        markdown = { enabled = true },
      },
    },
  },
}
