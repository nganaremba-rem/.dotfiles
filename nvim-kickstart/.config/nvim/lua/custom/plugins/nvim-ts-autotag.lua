-- Auto-close and auto-rename HTML/JSX tags. Only useful in markup buffers, so
-- don't load it at startup for every filetype.
return {
  'windwp/nvim-ts-autotag',
  ft = {
    'html',
    'xml',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'svelte',
    'vue',
    'markdown',
    'php',
  },
  opts = {},
}
