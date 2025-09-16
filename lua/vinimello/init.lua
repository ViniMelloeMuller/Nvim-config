-- Opções Globais
vim.g.mapleader = " "

vim.opt.autoindent = true       -- Mantém a indentação da linha anterior
vim.opt.smartindent = true      -- Indentação inteligente para C-like
vim.opt.autoread = true         -- Recarrega arquivos modificados fora do vim
vim.opt.clipboard = 'unnamed'   -- Usa a área de transferência do sistema
vim.opt.encoding = 'UTF-8'      -- Define a codificação de caracteres
vim.opt.mouse = 'a'             -- Habilita o uso do mouse em todos os modos
vim.opt.updatetime = 300        -- Tempo em ms para escrever em swap e disparar CursorHold
vim.opt.undofile = false        -- Não cria arquivos de undo persistentes
vim.opt.backup = false          -- Não cria arquivos de backup

-- UI e Aparência
vim.opt.number = true           -- Mostra o número das linhas
vim.opt.relativenumber = true   -- Mostra o número relativo das linhas

-- Indentação e Tabs
vim.opt.shiftwidth = 4          -- Tamanho da indentação
vim.opt.softtabstop = 4         -- Número de espaços para um <Tab> no modo de inserção
vim.opt.tabstop = 4             -- Número de espaços que um <Tab> representa
vim.opt.smarttab = true         -- Insere tabs de acordo com 'shiftwidth'

-- Filetype
vim.cmd('filetype plugin on') -- A forma recomendada para isso ainda é via vim.cmd

-- Atalhos (Keymaps)
local keymap = vim.keymap.set

-- Limpa a função padrão da barra de espaço para podermos usá-la como leader
keymap('n', '<SPACE>', '<NOP>', { silent = true })

-- Atalhos de utilidade
keymap('n', '<leader>f', '/', { desc = "Procurar no arquivo" })
keymap('n', '<leader><CR>', ':noh<CR>', { silent = true, desc = "Limpar highlight da busca" })
keymap('n', '<leader>w', ':w!<CR>', { desc = "Forçar salvamento" })

-- Navegação entre buffers
keymap('n', '<C-j>', ':bn<CR>', { silent = true, desc = "Buffer seguinte" })
keymap('n', '<C-k>', ':bN<CR>', { silent = true, desc = "Buffer anterior" })

-- Mapeia 0 para ir ao primeiro caractere não-branco (comportamento de ^)
keymap({'n', 'v'}, '0', '^', { desc = "Ir para o primeiro caractere" })

-- Set default shell to powershell if windows

if vim.loop.os_uname().sysname == "Windows_NT" then
	vim.opt.shell = "pwsh"
	vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
	vim.opt.shellquote = "\""
	vim.opt.shellxquote = ""
end

require("vinimello.plugins")
require("vinimello.lazy")
