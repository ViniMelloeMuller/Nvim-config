-- lazy.nvim
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		cmdline = {
			view = "cmdline",
		},
		views = {
			cmdline_popup = {
				win_options = {
					winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
				},
			},
			popupmenu = {
				win_options = {
					winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
				},
			},
		},
		presets = {
			bottom_search = false,
			command_palette = false,
			inc_rename = false,
			lsp_doc_border = false,
			long_message_to_split = false,
		},
		notify = {
			enabled = true,
		},
	},
	config = function()
		require("lualine").setup({
			sections = {
				lualine_x = {
					{
						color = { fg = "#ff9e64" },
					},
				},
			},
		})
	end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		{
			"rcarriga/nvim-notify",
			opts = {
				render = "compact",
				stages = "fade",
				timeout = 2000,
			},
		},
	},
}
