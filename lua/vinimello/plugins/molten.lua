return {
	"benlubas/molten-nvim",
	version = "^1.0.0",
	dependencies = {"3rd/image.nvim"},
	init = function()
		vim.g.molten_output_win_max_height = 12
		vim.api.nvim_set_keymap('n', '<leader>mi', ":MoltenInit<CR>", {silent=true, desc="Initialize the plugin"})
		vim.api.nvim_set_keymap('n', '<leader>r', ":MoltenEvaluateLine<CR>", {silent=true, desc="Evaluate Line"})
		vim.api.nvim_set_keymap('v', '<leader>r', ":<C-u>MoltenEvaluateVisual<CR>gv", {silent=true, desc="Evaluate Visual Selection"})
	end
}
