require("editor")

local exists, impatient = pcall(require, "impatient")

if exists and _G.__editor_config.debug then
  impatient.enable_profile()
end

require("core").setup()
