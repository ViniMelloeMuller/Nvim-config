-- Filetype-aware actions bound to <leader>b (build) and <leader>o (open)

local M = {}

local is_windows = (vim.loop.os_uname().sysname == "Windows_NT") or (vim.fn.has("win32") == 1)

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "vinimello" })
end

-- Runs `cmd` in a floating terminal that stays open so build errors can be read
local function run_in_float(cmd, cwd)
	vim.cmd(("FloatermNew --autoclose=never --cwd=%s %s"):format(vim.fn.fnameescape(cwd), cmd))
end

-- Build command per filetype; `file` and `out` are already shell-escaped
local builders = {
	c = function(file, out)
		return ("gcc %s -o %s"):format(file, out)
	end,
	cpp = function(file, out)
		return ("g++ -std=c++17 %s -o %s"):format(file, out)
	end,
	go = function()
		return "go build ./..."
	end,
	rust = function()
		return "cargo build"
	end,
}

function M.build()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype

	if ft == "tex" or ft == "plaintex" then
		if #vim.lsp.get_clients({ bufnr = buf, name = "texlab" }) == 0 then
			return notify("texlab não está ativo neste buffer", vim.log.levels.ERROR)
		end
		return vim.cmd("LspTexlabBuild")
	end

	vim.cmd("silent! update")
	local file = vim.api.nvim_buf_get_name(buf)
	local dir = vim.fs.dirname(file)

	-- A Makefile in the project takes priority over the per-filetype default
	local makefile_root = vim.fs.root(buf, { "Makefile", "makefile", "GNUmakefile" })
	if makefile_root then
		return run_in_float("make", makefile_root)
	end

	local builder = builders[ft]
	if not builder then
		return notify(("Nenhum build configurado para filetype '%s'"):format(ft), vim.log.levels.WARN)
	end

	local out = vim.fn.fnamemodify(file, ":t:r") .. (is_windows and ".exe" or "")
	run_in_float(builder(vim.fn.shellescape(vim.fn.fnamemodify(file, ":t")), vim.fn.shellescape(out)), dir)
end

return M
