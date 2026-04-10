return {
  "hrsh7th/nvim-cmp",
  enabled = false,
  opts = function(_, opts)
    local cmp = require("cmp")

    -- disable auto popup
    opts.completion = {
      autocomplete = false,
    }

    -- no auto select
    opts.preselect = cmp.PreselectMode.None

    -- clean sources
    opts.sources = {
      { name = "nvim_lsp" },
    }

    -- better mappings
    opts.mapping["<C-Space>"] = cmp.mapping.complete()
    opts.mapping["<Esc>"] = cmp.mapping.abort()
    opts.cmdline = {}

    opts.performance = {
      debounce = 60,
      throttle = 30,
    }
    return opts
  end,
}
