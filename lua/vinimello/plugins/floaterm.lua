return {
	'voldikss/vim-floaterm',
	init = function()
		vim.g.floaterm_keymap_kill   = '<F10>'
		vim.g.floaterm_keymap_new    = '<F7>'
		vim.g.floaterm_keymap_toggle = '<F12>'
		vim.g.floaterm_position = 'center'
		local isWindows = (vim.fn.has('win32') == 1)
		local executableName = isWindows and "main.exe" or "main"
		local executableCommand = isWindows and "./main.exe" or "./main"
		vim.cmd([[
			autocmd filetype c nnoremap <F4> :w <bar> :FloatermNew gcc % -o ]] .. executableName .. [[ && ]] .. executableCommand .. [[ <CR> 
			autocmd filetype python nnoremap <F4> :w <bar> :FloatermNew --autoclose=0 python3 % <CR>
			]])
	end
}
