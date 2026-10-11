return {
  "akinsho/bufferline.nvim",
  event = "BufReadPre",
  dependencies = "nvim-tree/nvim-web-devicons",
  keys = {
    { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "<S-l>",      "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<leader>bd", "<cmd>bdelete<cr>",             desc = "Delete buffer" },
  },
  opts = {
    options = {
      mode = "buffers",
      separator_style = "none",
      show_buffer_close_icons = true,
      show_close_icon = false,
      color_icons = true,
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and " " or " "
        return icon .. count
      end,
      custom_filter = function(buf_number)
        if vim.fn.bufname(buf_number) == "" then
          return false
        end
        return true
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "File Explorer",
          highlight = "Directory",
          separator = true,
        },
      },
    },

    highlights = {
      buffer_selected = {
        bg = "none",
        fg = "#7aa2f7", -- tokyonight blue
        bold = true,
        italic = true,
      },
      indicator_selected = {
        fg = "#7aa2f7",
        bg = "none",
      },
    },
    -- highlights
    -- highlights = {
    --   fill = { bg = "none" },
    --   background = { bg = "none" },
    --   tab = { bg = "none" },
    --   tab_selected = { bg = "none" },
    --   tab_separator = { bg = "none" },
    --   tab_separator_selected = { bg = "none" },
    --   buffer_selected = { bg = "none" },
    --   buffer_visible = { bg = "none" },
    --   close_button = { bg = "none" },
    --   close_button_visible = { bg = "none" },
    --   close_button_selected = { bg = "none" },
    --   indicator_selected = { bg = "none" },
    --   modified = { bg = "none" },
    --   modified_visible = { bg = "none" },
    --   modified_selected = { bg = "none" },
    --   separator = { bg = "none" },
    --   separator_selected = { bg = "none" },
    --   separator_visible = { bg = "none" },
    --   offset_separator = { bg = "none" },
    --   trunc_marker = { bg = "none" },
    -- },
  },
}
