return {
	'mofiqul/dracula.nvim',
	priority = 1000,
	opts = {
		transparent_bg=true,
	},
	config = function(_, opts)
		require('dracula').setup(opts)
		vim.cmd[[colorscheme dracula]]

		-- Força o destaque de referências do LSP a mudar apenas o fundo,
		-- preservando a sintaxe do Treesitter no texto.
		vim.api.nvim_set_hl(0, 'LspReferenceText' , { bg = '#44475A', fg = 'NONE', default = false })
		vim.api.nvim_set_hl(0, 'LspReferenceRead' , { bg = '#44475A', fg = 'NONE', default = false })
		vim.api.nvim_set_hl(0, 'LspReferenceWrite', { bg = '#44475A', fg = 'NONE', default = false })
	end
}
