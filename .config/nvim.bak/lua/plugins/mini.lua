return {
	{ "echasnovski/mini.pairs", version = "*", opts = {} },
	{
		"echasnovski/mini.surround",
		version = "*",
		config = function()
			require("mini.surround").setup()
		end,
	},
	{
		"echasnovski/mini.ai",
		version = "*",
		config = function()
			require("mini.ai").setup()
		end,
	},
	{
		"echasnovski/mini.diff",
		version = "*",
		config = function()
			require("mini.diff").setup()
		end,
	},
}
