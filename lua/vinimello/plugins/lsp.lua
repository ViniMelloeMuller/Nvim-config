return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp",
		"folke/lazydev.nvim"
	},
	config = function()
		local blink_caps = require("blink.cmp").get_lsp_capabilities()
		local is_windows = (vim.loop.os_uname().sysname == "Windows_NT") or (vim.fn.has("win32") == 1)

		local servers = {
			"lua_ls", "html", "pyright", "clangd", "gopls", "texlab"
		}

		for _, server in ipairs(servers) do
			local server_cfg = {
				capabilities = blink_caps,
			}

			if server == "texlab" then
				server_cfg.settings = {
					texlab = {
						build = {
							executable = "latexmk",
							args = { "-lualatex", "-interaction=nonstopmode", "-synctex=1", "%f" },
							onSave = false,
							forwardSearchAfter = true,
						},
						forwardSearch = {
							executable = is_windows and "SumatraPDF" or "/Applications/Skim.app/Contents/SharedSupport/displayline",
							args = is_windows
								and { "-reuse-instance", "-forward-search", "%f", "%l", "%p" }
								or { "-g", "%l", "%p", "%f" },
						},
						chktex = {
							onOpenAndSave = true,
							onEdit = false,
						},
						diagnosticsDelay = 300,
						latexFormatter = "none",
						bibtexFormatter = "texlab",
						formatterLineLength = 80,
					},
				}
			end

			vim.lsp.config[server] = server_cfg

			vim.lsp.enable(server)
		end

		vim.diagnostic.config({
			update_in_insert=true
		})

	end,
	init = function()
		vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap=true, silent=true })
		vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap=true, silent=true })
		vim.api.nvim_set_keymap("n", "<leader>ca", "<cmd> lua vim.lsp.buf.code_action()<CR>", { noremap=true, silent=true })
	end
}
