require("editor")
require("lazy")

local exists, impatient = pcall(require, "impatient")

if exists then
  impatient.enable_profile()
end

require("core").setup()
