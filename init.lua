require("editor")
require("lazy")

local exists, impatient = pcall(require, "impatient")

if exists and __editor_config.debug then
  impatient.enable_profile()
end

require("core").setup()
