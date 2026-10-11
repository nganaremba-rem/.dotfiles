return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "dracula",
      },
      sections = {
        lualine_c = {
          {
            function()
              local reg = vim.fn.reg_recording()
              if reg ~= "" then
                return "🔴 REC @" .. reg
              end
              return ""
            end
          }
        }
      }
    },
  },
}
