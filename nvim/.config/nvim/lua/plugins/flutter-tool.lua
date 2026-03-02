return {
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = { "dart" },

    keys = {
      { "<leader>fir", "<cmd>FlutterRun<CR>", desc = "Flutter Run" },
      { "<leader>fiq", "<cmd>FlutterQuit<CR>", desc = "Flutter Quit" },
      { "<leader>fis", "<cmd>FlutterRestart<CR>", desc = "Flutter Restart (hot reload)" },
      { "<leader>fie", "<cmd>FlutterEmulators<CR>", desc = "Flutter Emulators" },
      { "<leader>fil", "<cmd>FlutterLogToggle<CR>", desc = "Flutter Log Toggle" },
    },

    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
  },
}
