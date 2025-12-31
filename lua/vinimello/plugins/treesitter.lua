return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		event = { "BufReadPre", "BufNewFile" },
	}
}
