local exists = false

_G.__lazy = require("lazy")
_G.__editor = require("editor")
exists, _ = pcall(require, "impatient")

local setup = _G.__lazy.require_on_exported_call("core").setup

if exists and _G.__editor_config.debug then
  _G.__luacache.enable_profile()
end

setup()
