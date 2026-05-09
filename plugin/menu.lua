vim.cmd [[
  silent! aunmenu PopUp
  anoremenu PopUp.Inspect                 <Cmd>Inspect<CR>
  amenu     PopUp.-1-                     <Nop>
  anoremenu PopUp.Go\ to\ definition      <Cmd>lua vim.lsp.buf.definition()<CR>
  anoremenu PopUp.References              <Cmd>lua vim.lsp.buf.references()<CR>
  anoremenu PopUp.Show\ Diagnostics       <Cmd>lua vim.diagnostic.open_float()<CR>
  anoremenu PopUp.Show\ All\ Diagnostics  <Cmd>lua vim.diagnostic.setqflist()<CR>
  anoremenu PopUp.Configure\ Diagnostics  <Cmd>help vim.diagnostic.config()<CR>
  nnoremenu PopUp.Back                    <C-t>
  amenu     PopUp.Open\ in\ web\ browser  gx
]]

local nvim_popupmenu_augroup = vim.api.nvim_create_augroup("nvim.popupmenu", { clear = true })
vim.api.nvim_create_autocmd("MenuPopup", {
  pattern = "*",
  group = nvim_popupmenu_augroup,
  desc = "simple: custom menu setup",
  callback = function()
    vim.cmd [[
      " Urls
      silent! amenu disable PopUp.Open\ in\ web\ browser

      " LSP
      silent! amenu disable PopUp.Go\ to\ definition
      silent! amenu disable PopUp.References
      silent! amenu disable PopUp.Show\ Diagnostics
      silent! amenu disable PopUp.Show\ All\ Diagnostics
      silent! amenu disable PopUp.Configure\ Diagnostics
    ]]

    local url = Util.url_under_cursor()
    if url and vim.startswith(url, "http") then vim.cmd [[amenu enable PopUp.Open\ in\ web\ browser]] end

    if vim.lsp.get_clients({ bufnr = 0 })[1] then
      vim.cmd [[anoremenu enable PopUp.Go\ to\ definition]]
      vim.cmd [[anoremenu enable PopUp.References]]
    end

    local lnum = vim.fn.getcurpos()[2] - 1
    local has_diagnostic = next(vim.diagnostic.get(0, { lnum = lnum })) ~= nil
    if has_diagnostic then vim.cmd [[anoremenu enable PopUp.Show\ Diagnostics]] end
    if has_diagnostic or next(vim.diagnostic.count(0)) ~= nil then
      vim.cmd [[
        anoremenu enable PopUp.Show\ All\ Diagnostics
        anoremenu enable PopUp.Configure\ Diagnostics
      ]]
    end
  end,
})
