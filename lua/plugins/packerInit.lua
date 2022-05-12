vim.cmd("packadd packer.nvim")

local packer_path = __editor_global.packer.opt_dir .. "packer.nvim"
local present, packer = pcall(require, "packer")

if not present then
  print("Cloning packer..")
  -- remove the dir before cloning
  vim.fn.delete(packer_path, "rf")
  vim.fn.system({
    "git",
    "clone",
    "https://github.com/wbthomason/packer.nvim",
    "--depth",
    "20",
    packer_path,
  })

  vim.cmd("packadd packer.nvim")
  present, packer = pcall(require, "packer")

  if present then
    print("Packer cloned successfully.")
  else
    error("Couldn't clone packer !\nPacker path: " .. packer_path .. "\n" .. packer)
  end
end

local packer_config = {
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "single" })
    end,
    prompt_border = "single",
  },
  git = { clone_timeout = 500, default_url_format = "git@github.com:%s" },
  auto_clean = true,
  compile_on_sync = true,
}

if __editor_global.is_mac then
  packer_config.max_jobs = 50
end

packer.init(packer_config)

return packer
