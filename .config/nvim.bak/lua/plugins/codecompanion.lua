return {
	"olimorris/codecompanion.nvim",
	opts = {
		strategies = {
			chat = {
				adapter = "gemini",
			},
			inline = {
				adapter = "gemini",
			},
			cmd = {
				adapter = "gemini",
			},
		},
		display = {
			diff = {
				provider = "mini_diff",
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
}
