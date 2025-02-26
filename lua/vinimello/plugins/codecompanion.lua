return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("codecompanion").setup({
			adapters={
				deepseek = function ()
					return require("codecompanion.adapters").extend("deepseek", {
						env = {
							model = "deepseek-chat",
							api_key = os.getenv("DEEPSEEK_API_KEY"),
						}
					})
				end,
			},
			strategies = {
				chat   = {adapter = "deepseek", },
				inline = {adapter = "deepseek", },
				agent  = {adapter = "deepseek", },
			},
		})
	end
}
