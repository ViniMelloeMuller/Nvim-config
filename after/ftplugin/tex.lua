-- Buffer-local settings for LaTeX files

vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 0
vim.opt_local.spell = true
-- pt.utf-8.spl is generated locally from hunspell pt_BR (not versioned)
local has_pt = vim.fn.globpath(vim.o.runtimepath, "spell/pt.utf-8.spl") ~= ""
vim.opt_local.spelllang = has_pt and { "pt", "en_us" } or { "en_us" }

-- Visual line movement on wrapped lines
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { buffer = true, expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { buffer = true, expr = true, silent = true })

-- TexLab buffer-local keymaps
local map = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc, silent = true })
end

map("<leader>lb", "<cmd>LspTexlabBuild<CR>", "TexLab: Compilar documento")
map("<leader>lv", "<cmd>LspTexlabForward<CR>", "TexLab: Forward search (SyncTeX)")
map("<leader>lc", "<cmd>LspTexlabCleanAuxiliary<CR>", "TexLab: Limpar arquivos auxiliares")
map("<leader>lC", "<cmd>LspTexlabCleanArtifacts<CR>", "TexLab: Limpar todos os artefatos")
map("<leader>le", "<cmd>LspTexlabChangeEnvironment<CR>", "TexLab: Mudar ambiente")
map("<leader>lf", "<cmd>LspTexlabFindEnvironments<CR>", "TexLab: Listar ambientes ativos")
map("<leader>ld", "<cmd>LspTexlabDependencyGraph<CR>", "TexLab: Grafo de dependências")
map("<leader>lk", "<cmd>LspTexlabCancelBuild<CR>", "TexLab: Cancelar compilação")
