-- Detect a file's real indentation and set shiftwidth/expandtab to match.
-- Only meaningful once a buffer exists.
return {
  'NMAC427/guess-indent.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {},
}
