return {
	"lewis6991/gitsigns.nvim",
	opts = {},
	config = function ()
		require("gitsigns").setup()
		local gs = require('gitsigns')
		
		-- Pular para a PRÓXIMA mudança (next change)
		vim.keymap.set('n', ']]', function()
		  if vim.wo.diff then return ']]' end
		  vim.schedule(function() gs.nav_hunk('next') end)
		  return '<Ignore>'
		end, { expr = true, desc = "Próxima alteração Git" })

		-- Pular para a mudança ANTERIOR (prev change)
		vim.keymap.set('n', '[[', function()
		  if vim.wo.diff then return '[[' end
		  vim.schedule(function() gs.nav_hunk('prev') end)
		  return '<Ignore>'
		end, { expr = true, desc = "Alteração Git anterior" })
	end
}
