-- Buffer-local settings for Markdown files

vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.spell = true
-- pt.utf-8.spl is generated locally from hunspell pt_BR (not versioned)
local has_pt = vim.fn.globpath(vim.o.runtimepath, "spell/pt.utf-8.spl") ~= ""
vim.opt_local.spelllang = has_pt and { "pt", "en_us" } or { "en_us" }

-- Visual line movement on wrapped lines
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { buffer = true, expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { buffer = true, expr = true, silent = true })
