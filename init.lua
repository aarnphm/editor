local present, impatient = pcall(require, "impatient")
local config = require("core.global").load_config()

if present and config.debug then
	impatient.enable_profile()
end
require("core").setup(config)
