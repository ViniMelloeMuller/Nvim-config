return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.8',
	branch = '0.1.x',
	dependencies = { 'nvim-lua/plenary.nvim' },
	opts = {},
	init = function ()
		local builtin = require('telescope.builtin')
		vim.api.nvim_set_keymap('n', '<leader>g', ":Telescope live_grep <CR>", {noremap=true})
		vim.api.nvim_set_keymap('n', '<leader>F', ":Telescope find_files <CR>", {noremap=true})
		vim.api.nvim_set_keymap('n', '<leader>b', ":Telescope buffers <CR>", {noremap=true})
	end,
}
