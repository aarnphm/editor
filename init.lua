require("editor")
require("lazy")

local exists, impatient = pcall(require, "impatient")

if exists then
  impatient.enable_profile()
end

if not vim.g.vscode then
  require("core").setup()
end
