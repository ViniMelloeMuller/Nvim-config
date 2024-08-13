return {
	'voldikss/vim-floaterm',
		init = function()
			vim.g.floaterm_keymap_kill   = '<F10>'
			vim.g.floaterm_keymap_new    = '<F7>'
			vim.g.floaterm_keymap_toggle = '<F12>'
			vim.g.floaterm_position = 'topright'
			end
}
