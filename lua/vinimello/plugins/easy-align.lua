return {
	'junegunn/vim-easy-align',
	init = function()
		vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', {})
	end,
}

