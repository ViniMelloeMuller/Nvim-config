# AGENTS.md — Diretrizes para Desenvolvimento Agêntico

Contexto, arquitetura e regras de execução para agentes operando na configuração Neovim (`vinimello`).

## Contexto & Arquitetura

- **Propósito**: Configuração modular pessoal para Neovim v0.11+ / v0.12, orientada a [`lazy.nvim`](file:///Users/vinimem/.config/nvim/lua/vinimello/lazy.lua) com compatibilidade multiplataforma (macOS e Windows).
- **Namespace**: Todo o código reside sob [`lua/vinimello/`](file:///Users/vinimem/.config/nvim/lua/vinimello/).
- **Fluxo de Inicialização**:
  1. [`init.lua`](file:///Users/vinimem/.config/nvim/init.lua): Ponto de entrada raiz -> executa `require('vinimello')`.
  2. [`lua/vinimello/init.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/init.lua): Define opções globais (`vim.opt`), mapeamentos base (`<leader> = <Space>`), detecção de shell para Windows (`pwsh`), e requer `vinimello.plugins` e `vinimello.lazy`.
  3. [`lua/vinimello/lazy.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/lazy.lua): Bootstraps `lazy.nvim` caso ausente e inicializa `require("lazy").setup({ spec = "vinimello.plugins", ... })`.
  4. [`lua/vinimello/plugins/`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/): Diretório escaneado automaticamente pelo Lazy:
     - [`plugins/init.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/init.lua): Lista de plugins VimScript/Lua simples sem configurações ou dependências (ex.: plugins do tpope).
     - `plugins/<nome>.lua`: Módulos individuais retornando tabelas de spec do Lazy.

### Ponteiros de Contexto
- [extras.md](file:///Users/vinimem/.config/nvim/extras.md): Ferramentas externas de terminal (fzf, eza, ripgrep, bat) e fontes Nerd Font recomendadas.
- [README.md](file:///Users/vinimem/.config/nvim/README.md): Visão geral do repositório e notas de instalação de LSPs via gerenciadores de pacotes do sistema (Homebrew/Scoop).

---

## Convenções de Código & Design

- **Indentação**: Use TABs (largura visual de 4 espaços: `tabstop=4`, `shiftwidth=4`). Preserve tabs em todos os arquivos Lua.
- **Estrutura de Plugins**:
  - Crie um arquivo dedicado para plugins com configuração: [`lua/vinimello/plugins/<nome>.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/).
  - Retorne a tabela de spec conforme a API do `lazy.nvim` (`dependencies`, `opts`, `config`, `keys`, `cmd`, `event`, etc.).
  - Para plugins utilitários sem opções, adicione à lista em [`lua/vinimello/plugins/init.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/init.lua).
- **Atalhos & Keymaps**:
  - Leader key: `<Space>`.
  - Preferência: Registre atalhos na tabela `keys` do spec Lazy para garantir lazy-loading limpo. Se dependente de contexto runtime, utilize `init` ou `config`.
  - Mapeamentos existentes para evitar conflitos:
    - `<leader>f` (`/`), `<leader>w` (`:w!`), `<leader><cr>` (`:noh`).
    - `<leader>g` (live grep), `<leader>F` (find files) em [`telescope.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/telescope.lua).
    - `<leader>b` (build por filetype) e `<leader>o` (abrir artefato) em [`actions.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/actions.lua), mapeados em `init.lua`.
    - `<leader>n` (toggle árvore) em [`nvim-tree.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/nvim-tree.lua).
    - `<leader>lg` (lazygit) em [`lazgit.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/lazgit.lua).
    - `<leader>sr` (search & replace) em [`grug-far.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/grug-far.lua).
    - `<leader>xx`, `<leader>xX`, `<leader>cs`, `<leader>cS` em [`trouble.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/trouble.lua).
    - `}` e `{` customizados para navegação de hunks em [`gitsigns.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/gitsigns.lua).
- **LSP & Autocomplete**:
  - Motor de autocompletar: [`saghen/blink.cmp`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/cmp.lua) (não utilizar `nvim-cmp`).
  - Configuração de servidores LSP: Definida em [`lua/vinimello/plugins/lsp.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/lsp.lua). Utiliza a API nativa do Neovim moderno (`vim.lsp.config[server] = ...` e `vim.lsp.enable(server)`).
  - Diagnósticos inline gerenciados por [`tiny-inline-diagnostic.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/tiny-inline-diagnostic.lua) com `virtual_text = false` na API padrão.
  - Mason está presente em [`mason.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/mason.lua), mas binários externos instalados no SO também são suportados diretamente.
- **Suporte Multiplataforma**:
  - Sempre trate compatibilidade entre macOS e Windows via `vim.loop.os_uname().sysname == "Windows_NT"` ou `vim.fn.has('win32') == 1`.
  - Veja exemplo de bifurcação de comandos em [`floaterm.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/floaterm.lua).

---

## Fluxos de Trabalho do Agente

### 1. Adicionar ou Alterar Plugin
1. **Criar Spec**: Adicione [`lua/vinimello/plugins/<nome>.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/) retornando a tabela de configuração do Lazy.
2. **Declarar Dependências**: Especifique explicitamente dependências como `nvim-lua/plenary.nvim`, `nvim-tree/nvim-web-devicons` ou `nvim-treesitter/nvim-treesitter`.
3. **Verificar Sintaxe**:
   ```bash
   nvim --headless -c "lua local chunk, err = loadfile('lua/vinimello/plugins/<nome>.lua'); if not chunk then error(err) end" -c "qa"
   ```
   *Critério de conclusão*: Retorno com código de saída 0 e sem mensagens de erro.
4. **Verificar Inicialização**:
   ```bash
   nvim --headless "+qa"
   ```
   *Critério de conclusão*: Execução limpa sem exceções no `stderr`.

### 2. Adicionar Servidor LSP
1. **Atualizar Lista**: Insira o nome do servidor na tabela `servers` em [`lua/vinimello/plugins/lsp.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/plugins/lsp.lua).
2. **Customizar Opções** (se aplicável): Configure propriedades adicionais no dicionário `vim.lsp.config[server]`.
3. **Validar Carga**:
   ```bash
   nvim --headless -c "lua assert(loadfile('lua/vinimello/plugins/lsp.lua'))()" -c "qa"
   ```
   *Critério de conclusão*: Retorno código 0.

### 3. Ajustar Configurações Base ou Opções Globais
1. **Modificar** [`lua/vinimello/init.lua`](file:///Users/vinimem/.config/nvim/lua/vinimello/init.lua).
2. **Validar Carga**:
   ```bash
   nvim --headless -c "lua assert(loadfile('lua/vinimello/init.lua'))()" -c "qa"
   ```
   *Critério de conclusão*: Execução limpa sem erros.

---

## Verificação e Diagnóstico (Loop de Validação)

Execute este loop antes de concluir qualquer alteração no repositório:

1. **Checagem Sintática Completa**:
   ```bash
   nvim --headless -c "lua for _, f in ipairs(vim.fn.glob('lua/**/*.lua', true, true)) do local chunk, err = loadfile(f); if not chunk then error(err) end end" -c "qa"
   ```
   *Critério de sucesso*: Todos os arquivos `.lua` compilados com sucesso pelo LuaJIT sem lançar erros.

2. **Checagem de Inicialização Headless**:
   ```bash
   nvim --headless "+qa"
   ```
   *Critério de sucesso*: O Neovim inicializa, resolve o Lazy e finaliza com código 0 sem emitir warnings fatais ou erros.
