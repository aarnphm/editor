local present, impatient = pcall(require, "impatient")

if present then
       impatient.enable_profile()
   end

if not vim.g.vscode then require("core").setup() end
