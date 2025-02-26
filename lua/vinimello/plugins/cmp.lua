local codecompanion = require "vinimello.plugins.codecompanion"
return {
	'saghen/blink.cmp',
	dependencies = 'rafamadriz/friendly-snippets',
	version = '*',
	opts = {
		keymap = { preset = 'super-tab' },
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = 'mono',
		},
		sources = {
			default = { 'lsp', 'path', 'snippets', 'buffer', 'markdown' },
			providers = {
				markdown = {
					name = 'RenderMarkdown',
					module = 'render-markdown.integ.blink',
					fallbacks = { 'lsp' },
				},
			},
			per_filetype = {
				codecompanion = {"codecompanion"},
			},
		},
	},
	opts_extend = { "sources.default" }
}
