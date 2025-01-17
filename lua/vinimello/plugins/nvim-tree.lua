return {
	"nvim-tree/nvim-tree.lua",
	opts = {},
	dependencies = {"nvim-tree/nvim-web-devicons"},
	init = function()
		vim.api.nvim_set_keymap("n", "<leader>n", ":NvimTreeToggle<CR>", {noremap = true})
		vim.opt.termguicolors = true
	end
}
