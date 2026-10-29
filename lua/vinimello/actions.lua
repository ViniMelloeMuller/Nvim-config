-- Filetype-aware actions bound to <leader>b (build) and <leader>o (open)

local M = {}

local is_windows = (vim.loop.os_uname().sysname == "Windows_NT") or (vim.fn.has("win32") == 1)

local is_mac = vim.loop.os_uname().sysname == "Darwin"

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

-- Opens `path` in Skim (macOS) or with the system default opener
local function open_path(path)
	if is_mac and vim.fn.isdirectory("/Applications/Skim.app") == 1 and path:match("%.pdf$") then
		vim.system({ "open", "-a", "Skim", path })
		return
	end
	local _, err = vim.ui.open(path)
	if err then
		notify(err, vim.log.levels.ERROR)
	end
end

-- Candidate PDFs for a LaTeX buffer, most specific first
local function latex_pdf_candidates(buf)
	local file = vim.api.nvim_buf_get_name(buf)
	local dir = vim.fs.dirname(file)
	local candidates = {}

	-- `% !TEX root = main.tex` points to the main file of multi-file projects
	for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 10, false)) do
		local root = line:match("^%s*%%%s*!TEX%s+root%s*=%s*(.-)%s*$")
		if root then
			local main = vim.fs.normalize(vim.fs.joinpath(dir, root))
			table.insert(candidates, (main:gsub("%.tex$", "") .. ".pdf"))
			break
		end
	end

	table.insert(candidates, (file:gsub("%.tex$", "") .. ".pdf"))
	table.insert(candidates, vim.fs.joinpath(dir, "main.pdf"))
	return vim.fn.uniq(candidates)
end

local openers = {
	tex = function(buf)
		local candidates = latex_pdf_candidates(buf)
		for _, pdf in ipairs(candidates) do
			if vim.uv.fs_stat(pdf) then
				return open_path(pdf)
			end
		end
		notify("PDF não encontrado (compile com <leader>b). Procurado em:\n" .. table.concat(candidates, "\n"), vim.log.levels.ERROR)
	end,
	html = function(buf)
		open_path(vim.api.nvim_buf_get_name(buf))
	end,
}
openers.plaintex = openers.tex

function M.open()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype
	local opener = openers[ft]
	if not opener then
		return notify(("Nenhuma ação de abrir configurada para filetype '%s'"):format(ft), vim.log.levels.WARN)
	end
	opener(buf)
end

return M
