return {
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPre",
	opts = {
		options = {
			-- Configurações de parsing (o que o plugin vai ler)
			parsers = {
				css = true,
				hex = true
			},
			-- Configurações de exibição (como a cor vai aparecer)
			display = {
				mode = "virtualtext", -- Pode ser "background", "foreground" ou "virtualtext"
				virtualtext = {
					position = "after" -- Exibe o bloco de cor ao lado do texto
				},
			},
		},
	},
}
