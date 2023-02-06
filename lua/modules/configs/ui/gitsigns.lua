return function()
  require("gitsigns").setup({
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,
      ["n <LocalLeader>]g"] = {
        expr = true,
        "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'",
      },
      ["n <LocalLeader>[g"] = {
        expr = true,
        "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'",
      },
      ["v <LocalLeader>shl"] = '<cmd>lua require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
      ["v <LocalLeader>rhl"] = '<cmd>lua require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
      ["n <LocalLeader>sh"] = '<cmd>lua require("gitsigns").stage_hunk()<CR>',
      ["n <LocalLeader>ush"] = '<cmd>lua require("gitsigns").undo_stage_hunk()<CR>',
      ["n <LocalLeader>rh"] = '<cmd>lua require("gitsigns").reset_hunk()<CR>',
      ["n <LocalLeader>rb"] = '<cmd>lua require("gitsigns").reset_buffer()<CR>',
      ["n <LocalLeader>ph"] = '<cmd>lua require("gitsigns").preview_hunk()<CR>',
      ["n <LocalLeader>bl"] = '<cmd>lua require("gitsigns").blame_line({full = true})<CR>',
      -- Text objects
      ["o ih"] = ':<C-U>lua require("gitsigns").text_object()<CR>',
      ["x ih"] = ':<C-U>lua require("gitsigns").text_object()<CR>',
    },
    numhl = true,
    word_diff = true,
    current_line_blame = true,
    current_line_blame_opts = { delay = 1000, virtual_text_pos = "eol" },
    diff_opts = { internal = true },
  })
end
