require('spectre').setup({
  open_cmd = "noswapfile vnew" ,
  live_update = true,
  mapping = {
    ["change_replace_sed"] = {
      map = "<LocalLeader>trs",
      cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
      desc = "replace: Using sed",
    },
    ["change_replace_oxi"] = {
      map = "<LocalLeader>tro",
      cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
      desc = "replace: Using oxi",
    },
    ["toggle_live_update"] = {
      map = "<LocalLeader>tu",
      cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
      desc = "replace: update live changes",
    },
    -- only work if the find_engine following have that option
    ["toggle_ignore_case"] = {
      map = "<LocalLeader>ti",
      cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
      desc = "replace: toggle ignore case",
    },
    ["toggle_ignore_hidden"] = {
      map = "<LocalLeader>th",
      cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
      desc = "replace: toggle search hidden",
    },
  }
})

vim.keymap.set('n', '<Leader>so', function () require('spectre').open() end, { desc = 'replace: Open panel' })
vim.keymap.set('v', '<Leader>so', function () require('spectre').open_visual() end, { desc = 'replace: Open panel' })
vim.keymap.set('n', '<Leader>sw', function () require('spectre').open_visual { select_word = true } end, { desc = 'replace: Replace word under cursor' })
vim.keymap.set('n', '<Leader>sp', function () require('spectre').open_file_search() end, { desc = 'replace: Replace word under file search' })
