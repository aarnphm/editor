local present, impatient = pcall(require, "impatient")

if not vim.g.vscode then
	if present then
				impatient.enable_profile()
		end
	require("core").setup()
end
