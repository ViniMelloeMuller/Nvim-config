return {
	'nvim-telescope/telescope.nvim',
	dependencies = { 'nvim-lua/plenary.nvim', { 'nvim-telescope/telescope-fzf-native.nvim', build='make' } },
	opts = {},
	init = function ()
		local builtin = require('telescope.builtin')
		vim.api.nvim_set_keymap('n', '<leader>g', ":Telescope live_grep <CR>", {noremap=true})
		vim.api.nvim_set_keymap('n', '<leader>F', ":Telescope find_files <CR>", {noremap=true})
		vim.api.nvim_set_keymap('n', '<leader>b', ":Telescope buffers <CR>", {noremap=true})
	end,
}
