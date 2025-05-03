return {
	'catppuccin/nvim',
	name="catppuccin",
	priority = 1000,
	opts = {
		transparent_background=true,
	},
	init = function()
		vim.cmd[[colorscheme catppuccin-latte]]
	end
}
