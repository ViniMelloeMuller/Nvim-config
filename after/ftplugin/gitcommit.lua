-- Buffer-local settings for Git commit messages

vim.opt_local.spell = true
-- pt.utf-8.spl is generated locally from hunspell pt_BR (not versioned)
local has_pt = vim.fn.globpath(vim.o.runtimepath, "spell/pt.utf-8.spl") ~= ""
vim.opt_local.spelllang = has_pt and { "pt", "en_us" } or { "en_us" }
