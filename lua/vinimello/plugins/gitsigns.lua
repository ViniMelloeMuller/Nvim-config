return {
	"lewis6991/gitsigns.nvim",
	opts = {},
	config = function()
		require("gitsigns").setup()
		local gs = require('gitsigns')

		-- Pular para a PRÓXIMA mudança (})
		-- Se não houver hunks ou estiver em diff mode, age como '}' (próximo parágrafo)
		vim.keymap.set('n', '}', function()
			if vim.wo.diff then return '}' end
			
			-- Verifica se existem hunks no buffer atual
			local hunks = gs.get_hunks()
			if not hunks or #hunks == 0 then
				return '}'
			end

			vim.schedule(function() gs.nav_hunk('next') end)
			return '<Ignore>'
		end, { expr = true, desc = "Próxima alteração Git ou Parágrafo" })

		-- Pular para a mudança ANTERIOR ({)
		-- Se não houver hunks ou estiver em diff mode, age como '{' (parágrafo anterior)
		vim.keymap.set('n', '{', function()
			if vim.wo.diff then return '{' end
			
			local hunks = gs.get_hunks()
			if not hunks or #hunks == 0 then
				return '{'
			end

			vim.schedule(function() gs.nav_hunk('prev') end)
			return '<Ignore>'
		end, { expr = true, desc = "Alteração Git anterior ou Parágrafo" })
	end
}
