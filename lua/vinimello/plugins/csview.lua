return {
	'hat0uma/csvview.nvim',
	config = function()
		require('csvview').setup()

		local group = vim.api.nvim_create_augroup("CsvViewGroup", {clear=true})

		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = "csv",
			callback = function()
				vim.cmd('CsvViewEnable')
			end,
		})
	end
}
