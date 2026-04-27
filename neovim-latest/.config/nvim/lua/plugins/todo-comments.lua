-- plugins/todo-comments.lua
return {
  "folke/todo-comments.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim", -- add this
  },
  event = "VeryLazy",
  config = function()
    require("todo-comments").setup()
    require("telescope").load_extension("todo-comments") -- add this
  end,
  keys = {
    { "<leader>st", "<cmd>TodoTelescope<cr>",                               desc = "Todo current file" },
    { "<leader>sT", "<cmd>TodoTelescope cwd=" .. vim.fn.getcwd() .. "<cr>", desc = "Todo (project)" },
    { "<leader>xt", "<cmd>TodoTelescope<cr>",                               desc = "Todo (project)" },
    { "<leader>xT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",       desc = "Todo/Fix/Fixme (project)" },
    {
      "]t",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "Next todo",
    },
    {
      "[t",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "Prev todo",
    },
  },
}
