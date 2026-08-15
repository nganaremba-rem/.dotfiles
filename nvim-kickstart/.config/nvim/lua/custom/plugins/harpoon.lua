-- Harpoon lives under <leader>m ("mark"). It used to squat <leader>ha / <leader>hh,
-- which is the gitsigns "Git Hunk" namespace — an unrelated action inside a labelled
-- group. <leader>1-4 stay as the fast direct jumps.
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>ma', function() require('harpoon'):list():add() end, desc = 'Harpoon: [a]dd file' },
    { '<leader>mm', function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end, desc = 'Harpoon: [m]enu' },
    { '<leader>mn', function() require('harpoon'):list():next() end, desc = 'Harpoon: [n]ext file' },
    { '<leader>mp', function() require('harpoon'):list():prev() end, desc = 'Harpoon: [p]revious file' },
    { '<leader>m1', function() require('harpoon'):list():select(1) end, desc = 'Harpoon: file 1' },
    { '<leader>m2', function() require('harpoon'):list():select(2) end, desc = 'Harpoon: file 2' },
    { '<leader>m3', function() require('harpoon'):list():select(3) end, desc = 'Harpoon: file 3' },
    { '<leader>m4', function() require('harpoon'):list():select(4) end, desc = 'Harpoon: file 4' },
    { '<leader>1', function() require('harpoon'):list():select(1) end, desc = 'Harpoon: file 1' },
    { '<leader>2', function() require('harpoon'):list():select(2) end, desc = 'Harpoon: file 2' },
    { '<leader>3', function() require('harpoon'):list():select(3) end, desc = 'Harpoon: file 3' },
    { '<leader>4', function() require('harpoon'):list():select(4) end, desc = 'Harpoon: file 4' },
  },
  opts = {},
}
