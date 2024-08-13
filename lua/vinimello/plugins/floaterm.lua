return {
	'voldikss/vim-floaterm',
		init = function()
			vim.g.floaterm_keymap_kill   = '<F10>'
			vim.g.floaterm_keymap_new    = '<F7>'
			vim.g.floaterm_keymap_toggle = '<F12>'
			vim.g.floaterm_position = 'topright'
			vim.cmd([[
			autocmd filetype c nnoremap <F4> :w <bar> :FloatermNew gcc % -o main.exe <CR>
			autocmd filetype cpp nnoremap <F4> :w <bar> :FloatermNew g++ % -o main.exe <CR>
			autocmd filetype python nnoremap <F4> :w <bar> :FloatermNew --autoclose=0 python3 % <CR>
			autocmd filetype fortran nnoremap <F4> :w <bar> :FloatermNew gfortran % -o main.exe <CR>
			]])
			end
}
