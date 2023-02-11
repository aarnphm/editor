return {
	settings = {
		yaml = {
			schemaStore = {
				enable = true,
			},
			schemas = {
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
			},
		},
	},
}
