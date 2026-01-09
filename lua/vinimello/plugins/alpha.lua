return {
    'goolord/alpha-nvim',
    config = function ()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")
		local session_button = dashboard.button(
			"c", "  > Restore Session", ':lua require("persistence").load()<CR>'
		)

		dashboard.section.buttons.val = {
			-- dashboard.button( "e", "  > New file" , ":ene <BAR> startinsert <CR>"),
			session_button,
			dashboard.button( "lg","  > LazyGit"  , ":LazyGit<CR>"),
			dashboard.button( "f", "󰈞  > Find file", ":Telescope find_files<CR>"),
			dashboard.button( "g", "󰈞  > Ripgrep", ":Telescope live_grep<CR>"),
			dashboard.button( "r", "  > Recent"   , ":Telescope oldfiles<CR>"),
			dashboard.button( "u", "󰚰  > Update Packages"   , ":Lazy update<CR>"),
			dashboard.button( "s", "  > Settings" , ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
			dashboard.button( "q", "󰈆  > Quit NVIM", ":qa<CR>"),
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
