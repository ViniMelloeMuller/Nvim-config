return {
	'goolord/alpha-nvim',
	lazy = false,
	keys = {
		{ "<leader>d", "<cmd>Alpha<cr>", desc = "Dashboard (Alpha)" },
	},
	config = function ()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")
		local session_button = dashboard.button(
			"c", "  > Restore Session", ':lua require("persistence").load()<CR>'
		)

		dashboard.section.buttons.val = {
			session_button,
			dashboard.button( "e", "  > New File"            , ":ene <BAR> startinsert <CR>"),
			dashboard.button( ".", "󰉓  > Browse CWD (nvim .)" , ":edit .<CR>"),
			dashboard.button( "f", "󰈞  > Find File"           , ":Telescope find_files<CR>"),
			dashboard.button( "g", "󰱼  > Live Grep"           , ":Telescope live_grep<CR>"),
			dashboard.button( "r", "  > Recent Files"        , ":Telescope oldfiles<CR>"),
			dashboard.button( "s", "  > Settings"            , ':lua require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })<CR>'),
			dashboard.button( "l", "󰚰  > Plugins (Lazy)"      , ":Lazy<CR>"),
			dashboard.button( "q", "󰈆  > Quit NVIM"           , ":qa<CR>"),
		}

		-- Set header: ref: https://patorjk.com/software/taag/#p=display&v=0&f=ANSI%20Shadow&t=Type%20Something%20
		dashboard.section.header.val = {
			"██╗   ██╗███╗   ██╗██╗ ██████╗ █████╗ ███╗   ███╗██████╗ ",
			"██║   ██║████╗  ██║██║██╔════╝██╔══██╗████╗ ████║██╔══██╗",
			"██║   ██║██╔██╗ ██║██║██║     ███████║██╔████╔██║██████╔╝",
			"██║   ██║██║╚██╗██║██║██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ",
			"╚██████╔╝██║ ╚████║██║╚██████╗██║  ██║██║ ╚═╝ ██║██║     ",
			 "╚═════╝ ╚═╝  ╚═══╝╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ",
		}

		alpha.setup(dashboard.opts)

		vim.cmd([[
			autocmd FileType alpha setlocal nofoldenable
			]])
    end,
}
