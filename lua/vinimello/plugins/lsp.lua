return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp",
		"folke/lazydev.nvim"
	},
	config = function()
		local blink_caps = require("blink.cmp").get_lsp_capabilities()

		local servers = {
			"lua_ls", "html", "pyright", "clangd"
		}

		for _, server in ipairs(servers) do
			vim.lsp.config[server] = {
				capabilities = blink_caps
			}

			vim.lsp.enable(server)
		end

		vim.diagnostic.config({
			update_in_insert=true
		})

	end,
	init = function()
		vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap=true, silent=true })
		vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap=true, silent=true })
	end
}
