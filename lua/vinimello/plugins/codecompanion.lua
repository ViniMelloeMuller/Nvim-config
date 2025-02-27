return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("codecompanion").setup({
			adapters={
				opts = {show_defaults=false,},
				deepseek = function ()
					return require("codecompanion.adapters").extend("deepseek", {
						env = {
							model = "deepseek-chat",
							api_key = os.getenv("DEEPSEEK_API_KEY"),
						}
					})
				end,
				ollama = function()
					return require("codecompanion.adapters").extend("ollama", {
						env = {
							model = "qwen2.5-coder:3b",
							url = os.getenv("OLLAMA_HOST") or "http://localhost:11343",
						}
					})
				end,
			},
			strategies = {
				chat   = {adapter = "deepseek",},
				inline = {adapter = "deepseek",},
				agent  = {adapter = "deepseek",},
			},
		})
	end
}
