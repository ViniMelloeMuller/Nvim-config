return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},
	config = function()
		vim.lsp.enable("lua_ls")
		vim.lsp.enable("html")
		vim.lsp.enable("pyright")
		-- vim.lsp.enable("ty")
		vim.lsp.enable("clangd")
		vim.lsp.enable("texlab")
		vim.lsp.enable("gopls")
		vim.lsp.enable("gdscript")
		vim.lsp.enable("hls")
	end,
	init = function()
		vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap=true, silent=true })
		vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap=true, silent=true })
	end
}

