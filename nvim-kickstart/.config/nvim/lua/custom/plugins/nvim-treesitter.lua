return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  branch = 'main',
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
  config = function()
    -- `#same-line?` — true when two captures start on the same row. Neovim ships
    -- no such predicate and nvim-treesitter only adds `kind-eq?`, so the indent
    -- queries in after/queries/{tsx,typescript,javascript} register it here.
    --
    -- Register the POSITIVE form only: Neovim resolves a leading `not-` by
    -- looking up the rest of the name and inverting it, so `#not-same-line?` in
    -- a query works for free. Registering `not-same-line?` directly instead
    -- fails at match time with "No handler for not-same-line?".
    --
    -- Must run before any indents query is compiled — hence the top of `config`.
    vim.treesitter.query.add_predicate('same-line?', function(match, _, _, pred)
      local a, b = match[pred[2]], match[pred[3]]
      if not a or not b or #a == 0 or #b == 0 then return false end
      return a[1]:start() == b[1]:start()
    end, { force = true, all = true })

    -- Editor-essential parsers (not tied to any one language) + every parser the
    -- language registry asks for. New languages add parsers via the registry only.
    local parsers = { 'diff', 'query', 'vim', 'vimdoc', 'regex' }
    vim.list_extend(parsers, require('custom.lang').treesitter_ensure())
    require('nvim-treesitter').install(parsers)

    ---@param buf integer
    ---@param language string
    local function treesitter_try_attach(buf, language)
      -- check if parser exists and load it
      if not vim.treesitter.language.add(language) then return end
      -- enables syntax highlighting and other treesitter features
      vim.treesitter.start(buf, language)

      -- enables treesitter based folds
      -- for more info on folds see `:help folds`
      -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      -- vim.wo.foldmethod = 'expr'

      -- check if treesitter indentation is available for this language, and if so enable it
      -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
      local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

      -- enables treesitter based indentation.
      --
      -- `vim.bo[buf]`, NOT `vim.bo`: this function also runs from the async
      -- `install():await(...)` callback below, which fires whenever the parser
      -- download finishes — by then the current buffer is very often a different
      -- one. Writing to `vim.bo` would set indentexpr on whatever buffer you had
      -- switched to and leave the buffer that actually needs it without any,
      -- which shows up as "`o`/<CR> stopped indenting in this one file".
      if has_indent_query then vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
    end

    local available_parsers = require('nvim-treesitter').get_available()
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        local buf, filetype = args.buf, args.match

        local language = vim.treesitter.language.get_lang(filetype)
        if not language then return end

        local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

        if vim.tbl_contains(installed_parsers, language) then
          -- enable the parser if it is installed
          treesitter_try_attach(buf, language)
        elseif vim.tbl_contains(available_parsers, language) then
          -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
          require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
        else
          -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
          treesitter_try_attach(buf, language)
        end
      end,
    })
  end,
}
