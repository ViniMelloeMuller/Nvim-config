-- Set vim defaults

vim.cmd([[
	:set autoindent
	:set autoread
	:set clipboard=unnamed
	:set encoding=UTF-8
	:set mouse=a
	:set noundofile
	:set nobackup
	:set number
	:set relativenumber
	:set shiftwidth=4
	:set smartindent
	:set smarttab
	:set softtabstop=4
	:set syntax=on
	:set tabstop=4
	:set updatetime=300
	:filetype plugin on
	let mapleader = "\<SPACE>"
	nnoremap <SPACE> <NOP>
	nnoremap <leader>f /
	map <silent> <leader><cr> :noh<cr>
	nmap <leader>w :w!<cr>
	nnoremap <silent> <C-j> :bn<CR>
	nnoremap <silent> <C-k> :bN<CR>
	map 0 ^
	:set updatetime=300
]])

require("vinimello.plugins")
require("vinimello.lazy")
