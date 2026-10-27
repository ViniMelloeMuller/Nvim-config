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
		completion = {
			trigger = {
				show_on_x_blocked_trigger_characters = function()
					local ft = vim.bo.filetype
					if ft == 'tex' or ft == 'plaintex' or ft == 'bib' then
						return { "'", '"', '(', '[' }
					end
					return { "'", '"', '(', '{', '[' }
				end,
			},
		},
		sources = {
			default = { 'lsp', 'path', 'snippets', 'buffer', 'markdown' },
			per_filetype = {
				tex = { 'lsp', 'snippets', 'path', 'buffer' },
				plaintex = { 'lsp', 'snippets', 'path', 'buffer' },
				bib = { 'lsp', 'path', 'buffer' },
			},
			providers = {
				markdown = {
					name = 'RenderMarkdown',
					module = 'render-markdown.integ.blink',
					fallbacks = { 'lsp' },
				},
				buffer = {
					min_keyword_length = function(ctx)
						local bufnr = ctx and ctx.bufnr or 0
						local ft = bufnr > 0 and vim.bo[bufnr].filetype or vim.bo.filetype
						return (ft == 'tex' or ft == 'plaintex') and 4 or 0
					end,
				},
			},
		},
	},
	opts_extend = { "sources.default" }
}
