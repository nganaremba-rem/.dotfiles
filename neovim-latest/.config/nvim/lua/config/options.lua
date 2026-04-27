vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
-- Number of spaces that a <Tab> counts for
vim.opt.tabstop = 2
-- number of spaces to use for each step of (auto)indent
vim.opt.shiftwidth = 2
-- use spaces instead of tabs
vim.opt.expandtab = true

vim.opt.smartindent = true
-- number of spaces that a <tab> counts for while performing editing operations
vim.opt.softtabstop = 2

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.confirm = true

vim.diagnostic.config({
  virtual_text = {
    prefix = "●", -- or "■", "▶", "✘"
    spacing = 4,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
  underline = true,
  update_in_insert = false, -- don't show errors while typing
  severity_sort = true,
  float = {
    border = "rounded",
    source = true, -- show which LSP is reporting
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
    end

    -- map("gd", function()
    --   require("telescope.builtin").lsp_definitions({ reuse_win = true })
    -- end, "Goto definition")
    -- map("gd", vim.lsp.buf.definition, "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("gr", function()
      require("telescope.builtin").lsp_references({ reuse_win = true })
    end, "Goto references")
    map("gi", function()
      require("telescope.builtin").lsp_implementations({ reuse_win = true })
    end, "Goto implementation")
    -- map("gt", function()
    --   require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
    -- end, "Goto type definition")
    -- map("gp", "<cmd>Telescope lsp_definitions<cr>")
    map("<leader>cd", vim.diagnostic.open_float, "Show diagnostic")
    -- map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    -- map("<leader>rn", vim.lsp.buf.rename, "Rename")
    -- map("<leader>sr", vim.lsp.buf.declaration, "Goto declaration")
    map("<leader>fr", function()
      local word = vim.fn.expand("<cword>")
      require("telescope.builtin").grep_string({
        search = word,
        on_complete = {
          function()
            vim.cmd("cdo s/" .. word .. "//gc | update")
          end,
        },
      })
    end, "Find & replace in project")

    -- find and replace word under cursor in current file
    map("<leader>fs", ":%s/<C-r><C-w>//g<Left><Left>", "Find & replace word")
  end,
})


vim.filetype.add({
  extension = {
    conf = "dosini"
  }
})


vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.virtualedit = "onemore"
