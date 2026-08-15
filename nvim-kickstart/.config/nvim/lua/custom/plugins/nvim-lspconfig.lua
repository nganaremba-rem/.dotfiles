-- LSP configuration.
--
-- Servers themselves are NOT listed here — they live in the language registry
-- (`custom.languages`) and are pulled in via `custom.lang`. This file owns only
-- the cross-cutting concerns: keymaps on attach, Mason installation (startup +
-- on-demand), and wiring the registry into Neovim's native LSP.
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    -- LSP progress UI (bottom-right spinner).
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    local lang = require 'custom.lang'

    -- Buffer-local setup that runs whenever any LSP attaches.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Previously supplied by lspsaga (now disabled). Native hover takes a
        -- border since 0.11; noice still owns the markdown styling.
        map('K', function() vim.lsp.buf.hover { border = 'rounded' } end, 'Hover documentation')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code [a]ction', { 'n', 'x' })
        map('<leader>cD', vim.lsp.buf.declaration, 'Code: goto [D]eclaration')
        -- Signature help is <C-k> in insert mode, owned by blink.cmp's super-tab
        -- preset — do not bind it here as well.

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- Highlight references of the symbol under the cursor on CursorHold.
        if client and client:supports_method('textDocument/documentHighlight', event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- Inlay hints are toggled by the global <leader>uh in custom/config/keymaps.lua.
        -- A buffer-local duplicate used to live on <leader>th; that prefix now belongs
        -- to the terminal group.
      end,
    })

    -- Install everything the registry asks for at startup...
    require('mason-tool-installer').setup { ensure_installed = lang.mason_ensure() }

    -- ...and lazily install anything missing the first time you open a filetype.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('lang-ensure-on-demand', { clear = true }),
      callback = function(event)
        lang.ensure_for_ft(event.match)
      end,
    })

    -- Register and enable every server defined in the registry.
    for name, settings in pairs(lang.servers()) do
      vim.lsp.config(name, settings)
      vim.lsp.enable(name)
    end
  end,
}
