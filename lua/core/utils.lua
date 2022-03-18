local M = {}
local root_path = vim.fn.stdpath("config")

local function is_module_available(name)
  if package.loaded[name] then
    return true
  else
    for _, searcher in ipairs(package.searchers or package.loaders) do
      local loader = searcher(name)
      if type(loader) == "function" then
        package.preload[name] = loader
        return true
      end
    end
    return false
  end
end

function M.safe_require(pkg_name, cbk, opts)
  opts = opts or {}
  local pkg_names = {}
  if type(pkg_name) == "table" then
    pkg_names = pkg_name
  else
    pkg_names = { pkg_name }
  end

  local pkgs = {}
  for i, pkg_name_ in ipairs(pkg_names) do
    if is_module_available(pkg_name_) then
      pkgs[i] = require(pkg_name_)
    else
      if not opts.silent then
        print("WARNING: package " .. pkg_name_ .. " is not found")
      end
      return
    end
  end

  if #pkgs == #pkg_names then
    return cbk(unpack(pkgs))
  end
end

function M.edit_root()
  local telescope = require("telescope.builtin")
  telescope.git_files({ shorten_path = true, cwd = root_path })
end

function M.reload()
  require("core.pack").magic_compile()
  require("packer").sync()
  print("reloaded")
end

return M
