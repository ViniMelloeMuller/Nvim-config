return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		branch = 'main',
		cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
		opts_extend = { "ensure_installed" },
		config = function(_, opts)
			require("nvim-treesitter").setup(opts)
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"toml",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},
		},
	},
	{
	  "nvim-treesitter/nvim-treesitter-context",
	  opts = function()
		local tsc = require("treesitter-context")
		Snacks.toggle({
		  name = "Treesitter Context",
		  get = tsc.enabled,
		  set = function(state)
			if state then
			  tsc.enable()
			else
			  tsc.disable()
			end
		  end,
		}):map("<leader>ut")
		return { mode = "cursor", max_lines = 3 }
	  end,
	}
}
