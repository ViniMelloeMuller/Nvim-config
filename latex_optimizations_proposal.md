<!-- imark scope="file" by="Vinicius Mello e Muller" at="2026-10-27T14:06:33Z"
Vamos seguir com a opção A mesmo
-->

# Proposta de Otimizações para Escrita de Artigos LaTeX no Neovim

> **Status:** Documento de Proposta Consolidada e Validada para Aprovação Manual  
> **Autor:** Revisão Técnica SWE Light / Configuração `vinimello`  
> **Ambiente Avaliado:** Neovim v0.12.6, LuaJIT 2.1, macOS (com diretrizes para paridade Windows conforme `AGENTS.md`)  
> **Data:** 27 de Outubro de 2026  

---

## 1. Sumário Executivo & Diagnóstico da Configuração Atual

### 1.1 Contexto e Diagnóstico
A configuração pessoal do Neovim (`vinimello`) utiliza arquitetura orientada ao `lazy.nvim`, motor de autocompletar moderno e assíncrono em Rust/Lua via `saghen/blink.cmp`, diagnósticos inline com `rachartier/tiny-inline-diagnostic.nvim`, e configuração de servidores LSP utilizando a API nativa do Neovim 0.11+ / 0.12 (`vim.lsp.config` e `vim.lsp.enable`).

Recentemente, o LSP **`texlab`** foi adicionado à lista de servidores em `lua/vinimello/plugins/lsp.lua`. Uma inspeção técnica no ambiente revelou os seguintes pontos:

1. **Ferramentas Locais Disponíveis:**
   - `texlab 5.26.0` instalado em `/opt/homebrew/bin/texlab`.
   - `latexmk` instalado em `/Library/TeX/texbin/latexmk`.
   - `pdflatex` instalado em `/Library/TeX/texbin/pdflatex`.
   - Visualizador de PDF com suporte nativo a SyncTeX instalado em `/Applications/Skim.app`.
2. **Lacunas Identificadas na Configuração Atual:**
   - **`texlab` genérico:** O servidor está registrado sem tabela de `settings`, operando apenas com capacidades básicas. Recursos como compilação automatizada via `latexmk`, SyncTeX bidirecional (Forward/Inverse Search com Skim/SumatraPDF) e limpeza de artefatos auxiliares permanecem inativos.
   - **`blink.cmp` não especializado para LaTeX:** A lista global de fontes (`sources.default = { 'lsp', 'path', 'snippets', 'buffer', 'markdown' }`) aplica a fonte `markdown` indistintamente e não prioriza itens técnicos (comandos LaTeX, referências `.bib` e ambientes) sobre o texto de prosa capturado pelo provider `buffer`. Além disso, gatilhos de abertura como `{` (essenciais após `\cite{` ou `\ref{`) possuem restrições padrão de acionamento em inserção.
   - **Treesitter sem parsers de LaTeX e BibTeX:** O arquivo `lua/vinimello/plugins/treesitter.lua` não inclui `"latex"` nem `"bibtex"` em `ensure_installed`, forçando o Neovim a recorrer à sintaxe legada via regex do Vim para arquivos `.tex`, o que prejudica a velocidade de renderização e desativa o suporte a dobras de código (`foldexpr = "v:lua.vim.treesitter.foldexpr()"`) e contexto de seções (`nvim-treesitter-context`).
   - **Ausência de Mapeamentos e Ajustes de Prosa:** Não existem atalhos dedicados (`<leader>l*`) para compilação ou navegação visual, nem configurações buffer-local de escrita (como `wrap`, `linebreak` e correção ortográfica `spell`).

Este documento reúne propostas estruturadas para transformar a experiência de escrita acadêmica em LaTeX em um fluxo ágil, com zero atrito, alta precisão de autocompletar e excelente ergonomia visual.

---

## 2. Otimizações para `saghen/blink.cmp` no Contexto de LaTeX

A integração do autocompletar para LaTeX difere substancialmente de linguagens de programação comuns: em LaTeX, alterna-se constantemente entre **prosa em linguagem natural** (onde sugestões excessivas atrapalham o raciocínio) e **metalinguagem técnica** (comandos `\command`, citações `\cite{key}`, rótulos de figuras/equações `\ref{fig:...}` e ambientes `\begin{...}`).

### 2.1 Isolamento de Fontes por Tipo de Arquivo (`sources.per_filetype.tex`)
- **Descrição:** Configurar a opção `sources.per_filetype.tex` no spec de `lua/vinimello/plugins/cmp.lua`, definindo explicitamente as fontes habilitadas para arquivos TeX: `{'lsp', 'snippets', 'path', 'buffer'}`.
- **Justificativa:** Atualmente, a fonte `markdown` (integrada com `render-markdown`) está listada no `sources.default` global. Isolar o filetype `tex` remove processamento desnecessário de providers alheios ao ecossistema LaTeX e permite reordenar o peso das fontes.
- **Ganhos Esperados:**
  - Redução de overhead no loop de autocompletar em arquivos `.tex`.
  - Prioridade natural para comandos e referências fornecidos pelo `texlab` (`lsp`), seguidos por templates estruturais (`snippets`) e inclusão de imagens/subarquivos (`path`).
- **Código Ilustrativo de Aplicação:**
  ```lua
  -- Em lua/vinimello/plugins/cmp.lua:
  opts = {
      -- ... configurações existentes ...
      sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer', 'markdown' },
          per_filetype = {
              tex = { 'lsp', 'snippets', 'path', 'buffer' },
              plaintex = { 'lsp', 'snippets', 'path', 'buffer' },
              bib = { 'lsp', 'path', 'buffer' },
          },
          -- ...
      }
  }
  ```
- **Novas Dependências:** Nenhuma.
- **Quebras Potenciais:** Nenhuma. O comportamento padrão em outras linguagens permanece inalterado.

---

### 2.2 Ajuste de Gatilhos e Comportamento de Delimitadores (Triggers & Keywords)
- **Descrição:** Ajustar o comportamento dos caracteres de disparo para o contexto de LaTeX. O `texlab` (v5.26.0) registra via protocolo LSP os seguintes caracteres de gatilho padrão: `\`, `{`, `}`, `@`, `/` e `' '` (espaço). No entanto, no `blink.cmp`, o caractere `{` faz parte por padrão da lista `show_on_x_blocked_trigger_characters`, o que inibe a abertura do menu de sugestões quando o cursor se posiciona imediatamente após o caractere ao entrar em modo de inserção ou aceitar uma conclusão anterior (como ao expandir snippets de `\cite{}` ou navegar por tabstops).
- **Justificativa:** Ao expandir um snippet como `\cite{}` ou navegar com `Tab` para dentro de chaves delimitadoras, o autor espera ver imediatamente a lista com as chaves bibliográficas do seu arquivo `.bib` ou os rótulos de seções/figuras. Se o gatilho `{` permanecer na lista de bloqueio de entrada/aceitação (`show_on_x`), o usuário é forçado a digitar manualmente a primeira letra da chave ou acionar o menu via atalho. Além disso, o caractere `@` registrado pelo `texlab` é fundamental para referências BibTeX em arquivos `.bib`.
- **Ganhos Esperados:**
  - Sugestão instantânea de referências cruzadas (`\ref{sec:`, `\ref{fig:`) e citações (`\cite{`) logo após a entrada dentro das chaves delimitadoras.
  - Gatilho imediato após o caractere de barra invertida (`\`) sem necessidade de comprimento mínimo de palavra (`min_keyword_length = 0` para `lsp`).
- **Código Ilustrativo de Aplicação:**
  ```lua
  -- Em lua/vinimello/plugins/cmp.lua (opts.completion.trigger):
  opts = {
      completion = {
          trigger = {
              -- Remove '{' da lista de bloqueio especificamente para LaTeX via callback dinâmico,
              -- evitando qualquer efeito colateral em C, Go, Lua ou Rust onde '{' abre blocos:
              show_on_x_blocked_trigger_characters = function()
                  local ft = vim.bo.filetype
                  if ft == "tex" or ft == "plaintex" or ft == "bib" then
                      return { "'", '"', '(', '[' } -- '{' liberado para disparar sugestões
                  end
                  return { "'", '"', '(', '{', '[' } -- padrão seguro para as demais linguagens
              end,
          },
      },
  }
  ```
- **Novas Dependências:** Nenhuma.
- **Quebras Potenciais:** Zero quebras. A utilização de uma função de callback dinâmica garante que o desbloqueio do `{` ocorra exclusivamente em buffers de arquivos LaTeX e BibTeX.

---

### 2.3 Resolução de Citações e Referências Cruzadas (`.bib` e Labels)
- **Status da Decisão:** Aprovada e Adotada a **Opção A** pelo usuário (conforme feedback registrado: *"Vamos seguir com a opção A mesmo"*). A Opção B foi formalmente descartada para preservar a árvore de dependências enxuta.
- **Descrição das Abordagens Avaliadas:**
  - **Opção A (Aprovada - LSP Nativo via TexLab):** O próprio `texlab` analisa de forma assíncrona os arquivos `.bib` declarados no documento (`\bibliography{...}` ou `\addbibresource{...}`) e fornece as chaves de citação diretamente via protocolo LSP para o `blink.cmp`. Inclui título do artigo, autores e ano na janela de documentação flutuante.
  - **Opção B (Descartada - Plugin da Comunidade `blink-cmp-bibtex`):** Adicionar um provider externo para ler arquivos BibTeX globais (ex.: arquivo mestre de exportação do Zotero/Mendeley no `$HOME`) independentemente de estarem vinculados ao projeto local.
- **Justificativa:** A Opção A é extremamente limpa, rápida e não insere nenhum plugin extra na árvore de dependências. A Opção B só se justificaria caso o usuário mantivesse uma biblioteca centralizada fora da pasta do repositório do artigo.
- **Ganhos Esperados:**
  - Janela de documentação flutuante exibindo o resumo BibTeX completo ao navegar pelas sugestões com `Tab`/`S-Tab`.
  - Zero sobrecarga de memória, já que o parsing é delegado ao binário compilado em Rust do `texlab`.
- **Novas Dependências:** Zero para a Opção A adotada.
- **Quebras Potenciais:** Na Opção A, o documento `.tex` deve conter um comando `\bibliography{}` ou arquivo `.latexmkrc` / `.texlabroot` para que o servidor localize os arquivos `.bib` em projetos multi-diretórios.

---

### 2.4 Snippets Acadêmicos e Fórmulas Matemáticas (`friendly-snippets`)
- **Descrição:** O repositório já possui `rafamadriz/friendly-snippets` carregado como dependência do `blink.cmp`. Esse pacote possui um acervo rico de snippets para TeX (`\begin{}...\end{}`, `align`, `gather`, `equation`, `table`, `figure`, `bmatrix`, `frac{}{}`).
- **Justificativa:** Escrever código repetitivo para inserção de figuras ou matrizes atrasa o fluxo de redação de artigos. O mapeamento atual do `blink.cmp` (`preset = 'super-tab'`) já oferece suporte a navegação por tabstops (`Tab` para avançar e `S-Tab` para retroceder).
- **Ganhos Esperados:**
  - Expansão rápida de estruturas complexas em um único comando.
  - Priorização de snippets sobre palavras do buffer através de pontuação adequada (`score_offset = 1` para snippets em arquivos `tex`).
- **Novas Dependências:** Nenhuma (o repositório já inclui `friendly-snippets`).
- **Quebras Potenciais:** Usuários acostumados a usar `Tab` puramente para indentação em modo de inserção devem atentar para o fato de que, quando houver um snippet com tabstop ativo, o `Tab` navegará para o próximo campo editável (comportamento padrão do `super-tab`).

---

### 2.5 Penalização da Fonte `buffer` em Prosa Técnica
- **Descrição:** Configurar o provider `buffer` para exigir pelo menos 4 caracteres (`min_keyword_length = 4`) especificamente no ambiente LaTeX. No `blink.cmp`, o `score_offset = -3` já é o padrão global para o provider `buffer`, garantindo que palavras do buffer fiquem abaixo de LSP e snippets. No entanto, sem limitar o `min_keyword_length`, termos do buffer ainda aparecem com apenas 1 ou 2 letras digitadas.
- **Justificativa:** Em redação de artigos longos, o buffer contém milhares de palavras da prosa (ex.: "algoritmo", "além", "apenas"). Quando o autor digita `\al`, a intenção quase invariavelmente é um comando matemático como `\alpha` ou ambiente `\align` (fornecidos pelo LSP/snippets). Exigir 4 caracteres para o `buffer` em arquivos `.tex` via função dinâmica elimina o ruído sem afetar o comportamento em arquivos de outras linguagens.
- **Ganhos Esperados:**
  - Menu de sugestões mais limpo, conciso e relevante durante a redação de equações e comandos.
  - Preservação da busca de palavras da prosa quando o autor digita 4 ou mais caracteres.
- **Código Ilustrativo de Aplicação:**
  ```lua
  -- Em lua/vinimello/plugins/cmp.lua (opts.sources.providers.buffer):
  sources = {
      -- ...
      providers = {
          buffer = {
              min_keyword_length = function(ctx)
                  local bufnr = ctx and ctx.bufnr or 0
                  local ft = bufnr > 0 and vim.bo[bufnr].filetype or vim.bo.filetype
                  return (ft == "tex" or ft == "plaintex") and 4 or 0
              end,
          },
      },
  }
  ```
- **Novas Dependências:** Nenhuma.
- **Quebras Potenciais:** Nenhuma. O uso da função `min_keyword_length` isola o filtro estritamente para `tex` e `plaintex`.

---

### 2.6 Código Consolidado Ilustrativo para `lua/vinimello/plugins/cmp.lua`
- **Descrição:** Visão unificada de como o arquivo `lua/vinimello/plugins/cmp.lua` deve ficar após a integração de todas as propostas da Seção 2 (fontes isoladas por filetype, gatilhos desbloqueados dinamicamente para TeX e buffer com limiar de 4 caracteres), preservando a integração existente com `render-markdown`.
- **Código Proposto:**
  ```lua
  return {
      'saghen/blink.cmp',
      dependencies = 'rafamadriz/friendly-snippets',
      version = '*',
      opts = {
          keymap = { preset = 'super-tab' },
          appearance = {
              use_nvim_cmp_as_default = true,
              nerd_font_variant = 'mono',
          },
          completion = {
              trigger = {
                  show_on_x_blocked_trigger_characters = function()
                      local ft = vim.bo.filetype
                      if ft == 'tex' or ft == 'plaintex' or ft == 'bib' then
                          return { "'", '"', '(', '[' }
                      end
                      return { "'", '"', '(', '{', '[' }
                  end,
              },
          },
          sources = {
              default = { 'lsp', 'path', 'snippets', 'buffer', 'markdown' },
              per_filetype = {
                  tex = { 'lsp', 'snippets', 'path', 'buffer' },
                  plaintex = { 'lsp', 'snippets', 'path', 'buffer' },
                  bib = { 'lsp', 'path', 'buffer' },
              },
              providers = {
                  markdown = {
                      name = 'RenderMarkdown',
                      module = 'render-markdown.integ.blink',
                      fallbacks = { 'lsp' },
                  },
                  buffer = {
                      min_keyword_length = function(ctx)
                          local bufnr = ctx and ctx.bufnr or 0
                          local ft = bufnr > 0 and vim.bo[bufnr].filetype or vim.bo.filetype
                          return (ft == 'tex' or ft == 'plaintex') and 4 or 0
                      end,
                  },
              },
          },
      },
      opts_extend = { 'sources.default' }
  }
  ```
- **Novas Dependências:** Nenhuma.
- **Quebras Potenciais:** Nenhuma. O spec é 100% retrocompatível com as demais linguagens do repositório.

---

## 3. Configuração e Ajuste Fino do LSP `texlab`

Atualmente, `lua/vinimello/plugins/lsp.lua` registra o `texlab` em um loop genérico:
```lua
vim.lsp.config[server] = {
    capabilities = blink_caps
}
vim.lsp.enable(server)
```
O `texlab` possui um conjunto robusto de opções sob a chave `settings.texlab`. Abaixo estão as propostas para aproveitá-las plenamente.

### 3.1 Motor de Compilação Automatizada (`settings.texlab.build`)
- **Descrição:** Configurar o motor de compilação do `texlab` para utilizar o utilitário `latexmk` (já presente no macOS em `/Library/TeX/texbin/latexmk`).
- **Parâmetros Recomendados:**
  - `executable = 'latexmk'`
  - `args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' }`
  - `onSave = false` (Recomendação: compilação sob demanda via atalho, ou `true` caso o usuário prefira compilação contínua ao salvar).
  - `forwardSearchAfter = true` (dispara automaticamente a localização no visualizador de PDF após compilar com sucesso).
- **Justificativa:** Artigos acadêmicos com bibliografias pesadas e dezenas de referências requerem múltiplas passagens (`pdflatex` -> `biber`/`bibtex` -> `pdflatex` x2). O `latexmk` automatiza esse ciclo e gera o arquivo `.synctex.gz` indispensável para sincronização visual. Manter `onSave = false` por padrão evita travamentos ou lentidão desnecessária ao salvar artigos gigantes a cada minuto, delegando o disparo ao atalho de teclado.
- **Ganhos Esperados:**
  - Compilação consistente de PDF diretamente de dentro do Neovim.
  - Notificações de status de compilação integradas ao `noice.nvim` e `nvim-notify` já configurados no repositório.
- **Novas Dependências:** Nenhuma (o executável `latexmk` já está instalado e validado no sistema).
- **Quebras Potenciais:** Se `onSave = true` for selecionado, artigos muito extensos podem provocar rajadas de compilação caso o autosave esteja ativo.

---

### 3.2 Visualização e SyncTeX Bidirecional (Forward & Inverse Search)
- **Descrição:** Integrar o `texlab` com o visualizador de PDF **Skim** no macOS (detectado em `/Applications/Skim.app`) e com **SumatraPDF** no Windows, mantendo conformidade estrita com as regras de multiplataforma descritas no `AGENTS.md`.
- **Configuração Técnica do Forward Search (Neovim -> PDF):**
  - **No macOS:**
    - `executable = '/Applications/Skim.app/Contents/SharedSupport/displayline'`
    - `args = { '-g', '%l', '%p', '%f' }`
    *(O argumento `-g` instrui o Skim a navegar para a linha exata sem roubar o foco da janela do Neovim).*
  - **No Windows:**
    - `executable = 'SumatraPDF'`
    - `args = { '-reuse-instance', '-forward-search', '%f', '%l', '%p' }`
- **Configuração do Inverse Search (PDF -> Neovim):**
  - No Skim (`Preferências` -> `Sync`):
    - *Preset:* Custom
    - *Command:* `/usr/local/bin/nvim` (ou caminho do binário)
    - *Arguments:* `--server "$NVIM" --remote-send "<C-\><C-N>:edit +%line %file<CR>"` (ou script auxiliar de chamada).
- **Ganhos Esperados:**
  - Saltar do ponto exato do cursor no Neovim para a linha correspondente no PDF renderizado com um único atalho.
  - Clicar com `Cmd + Shift + Clique` no PDF do Skim e ter o cursor do Neovim posicionado instantaneamente na linha de código-fonte correspondente.
- **Novas Dependências:** Nenhuma no macOS (o Skim já se encontra instalado). No Windows, requer instalação opcional do SumatraPDF via Scoop.
- **Quebras Potenciais:** Nenhuma.

---

### 3.3 Gestão de Diagnósticos e Linting com ChkTeX
- **Descrição:** O `texlab` traz integração com o `chktex` (linter padrão para estilo e boas práticas em LaTeX).
- **Justificativa:** O repositório utiliza `rachartier/tiny-inline-diagnostic.nvim` com `vim.diagnostic.config({ update_in_insert = true })`. Se o `chktex` for ativado no modo `onEdit = true`, o linter acusará erros de sintaxe enquanto o usuário estiver no meio da digitação de uma equação matemática ou comando, poluindo o buffer visualmente.
- **Configuração Recomendada:**
  - `chktex.onOpenAndSave = true` (avalia ao abrir e ao salvar).
  - `chktex.onEdit = false` (não roda a cada tecla pressionada).
  - `diagnosticsDelay = 300` (debounce de 300ms).
- **Ganhos Esperados:**
  - Feedback estático preciso sobre vírgulas, espaços insecáveis (`~`) e boas práticas tipográficas sem provocar ruído visual durante a digitação fluida.
- **Novas Dependências:** `chktex` (já comumente fornecido pela distribuição TeX Live / MacTeX).
- **Quebras Potenciais:** Pequeno consumo de CPU ao salvar arquivos extensos caso o `chktex` analise árvores complexas.

---

### 3.4 Suporte a Projetos Multi-arquivos e Documento Raiz
- **Descrição:** Em artigos longos (ex.: teses, dissertações ou artigos com capítulos em pastas separadas incluídos via `\input{sections/...}`), o `texlab` precisa saber qual arquivo é o ponto de entrada principal (`main.tex`) para compilar adequadamente e resolver citações.
- **Mecanismos Recomendados:**
  - O `nvim-lspconfig` já busca por marcadores de raiz como `.git`, `.latexmkrc`, `latexmkrc`, `.texlabroot`, `texlabroot` e `Tectonic.toml`.
  - Recomendar na documentação de uso a criação de um arquivo vazio `.texlabroot` ou `.latexmkrc` na raiz do artigo, ou a inclusão da linha mágica `% !TeX root = main.tex` no cabeçalho dos arquivos secundários.
- **Ganhos Esperados:**
  - O `texlab` compilará sempre o documento principal mesmo quando o autor estiver editando um arquivo de subseção importado.
- **Novas Dependências:** Nenhuma.
- **Quebras Potenciais:** Nenhuma.

---

### 3.5 Formatação de Documentos e Tabelas BibTeX
- **Descrição:** O `texlab` oferece formatador nativo de arquivos de bibliografia (`bibtexFormatter = 'texlab'`) e integração com `latexindent` para arquivos `.tex`.
- **Diagnóstico Técnico Local sobre `latexindent`:** No macOS, `/Library/TeX/texbin/latexindent` está presente no PATH, mas sua execução falha com erro Perl fatal (`Can't locate File/HomeDir.pm in @INC`) a menos que módulos CPAN adicionais sejam instalados pelo usuário no sistema. Portanto, manter `latexFormatter = 'latexindent'` (padrão implícito do `nvim-lspconfig`) causará falhas sempre que `vim.lsp.buf.format()` for acionado em um arquivo `.tex`.
- **Recomendação:**
  - Configurar explicitamente `latexFormatter = 'none'` para suprimir a chamada com erro ao `latexindent`.
  - Ativar `bibtexFormatter = 'texlab'` e `formatterLineLength = 80`.
- **Ganhos Esperados:**
  - Arquivos `.bib` organizados e padronizados automaticamente ao acionar `vim.lsp.buf.format()` via motor Rust nativo do TexLab.
  - Zero falhas ou avisos de erro Perl no Neovim ao acionar formatação de arquivos `.tex`.
- **Novas Dependências:** Zero para formatação de `.bib`.

---

### 3.6 Código Ilustrativo de Configuração (`lua/vinimello/plugins/lsp.lua`)
- **Atenção Técnica sobre o Neovim 0.12 (`vim.lsp.config`):** No Neovim v0.12, cada atribuição a `vim.lsp.config[server] = ...` substitui as configurações personalizadas anteriores do servidor (fundindo-as apenas com os defaults internos do `lsp/texlab.lua`). Portanto, definir `settings` em uma linha e sobrescrever com `vim.lsp.config[server] = { capabilities = blink_caps }` em um loop subsequente descarta silenciosamente as opções do TexLab. A tabela com `capabilities` e `settings` deve ser atribuída de forma atômica e unificada.
- **Código Proposto:**
  ```lua
  -- Em lua/vinimello/plugins/lsp.lua:
  return {
      "neovim/nvim-lspconfig",
      dependencies = {
          "saghen/blink.cmp",
          "folke/lazydev.nvim"
      },
      config = function()
          local blink_caps = require("blink.cmp").get_lsp_capabilities()
          local is_windows = vim.loop.os_uname().sysname == "Windows_NT"

          local servers = {
              "lua_ls", "html", "pyright", "clangd", "gopls", "texlab"
          }

          for _, server in ipairs(servers) do
              local server_cfg = {
                  capabilities = blink_caps
              }

              if server == "texlab" then
                  server_cfg.settings = {
                      texlab = {
                          build = {
                              executable = "latexmk",
                              args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
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
              update_in_insert = true
          })
      end,
      init = function()
          vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap=true, silent=true })
          vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap=true, silent=true })
      end
  }
  ```
- **Novas Dependências:** Nenhuma.
- **Quebras Potenciais:** Nenhuma.

---

## 4. Experiência de Escrita (UX, Interface e Prosa Acadêmica)

### 4.1 Ambiente de Escrita de Prosa Acadêmica (`ftplugin/tex.lua`)
- **Descrição:** Criar um arquivo dedicado `after/ftplugin/tex.lua` (ou vincular via `vim.api.nvim_create_autocmd("FileType", { pattern = { "tex", "bib" }, ... })`) configurando as opções de buffer específicas para redação.
- **Ajustes Propostos:**
  - `vim.opt_local.wrap = true`: quebra de linha visual para parágrafos longos.
  - `vim.opt_local.linebreak = true`: quebra de linha apenas em limites de palavras, sem cortar palavras ao meio.
  - `vim.opt_local.spell = true`: ativação do corretor ortográfico nativo do Neovim.
  - `vim.opt_local.spelllang = { "en_us" }` (com suporte opcional a `pt_br`): verificação ortográfica conforme o idioma do artigo.
  - `vim.opt_local.conceallevel = 0` (ou `1` se desejar símbolos matemáticos estilizados pelo Neovim).
- **Justificativa:** Por padrão, a configuração do Neovim tem `shiftwidth=4`, `tabstop=4` e quebra desativada. Na escrita de artigos científicos, redigir parágrafos com dezenas de palavras sem `linebreak` exige rolagem horizontal desnecessária.
- **Ganhos Esperados:**
  - Experiência visual confortável, idêntica a processadores de texto modernos, mantendo a integridade do arquivo `.tex` em texto puro.
  - Identificação visual imediata de palavras grafadas incorretamente via realce ortográfico.
- **Novas Dependências:** Arquivos de dicionário padrão baixados sob demanda pelo próprio Neovim na primeira execução do `spell`.
- **Atenção Técnica sobre o Primeiro Download do Dicionário:** Ao ativar pela primeira vez um idioma adicional como `pt_br`, o Neovim exibe uma mensagem interativa no rodapé solicitando confirmação: `No spell file found for pt (utf-8). Download? [y/N]`. Em inicializações não interativas ou testes headless, isso pausa o processo aguardando entrada do terminal. A proposta recomenda definir inicialmente `spelllang = { "en_us" }` (cujo arquivo já vem distribuído nativamente com o Neovim) e rodar uma vez o comando `:set spelllang=en_us,pt_br` em sessão interativa para autorizar o download do dicionário em português.
- **Quebras Potenciais:** O corretor pode destacar palavras técnicas ou nomes de comandos LaTeX não reconhecidos se o `spellcapcheck` não for ajustado.

---

### 4.2 Destaque e Dobradura de Código com Treesitter
- **Descrição:** Adicionar `"latex"` e `"bibtex"` na tabela `ensure_installed` em `lua/vinimello/plugins/treesitter.lua`.
- **Justificativa:** O repositório já possui configuração ativa de dobras baseadas em Treesitter (`vim.opt.foldmethod = "expr"` e `vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"` em `lua/vinimello/init.lua`) e o plugin `nvim-treesitter-context`. Sem os parsers de LaTeX e BibTeX instalados:
  - O realce de sintaxe recorre a expressões regulares antigas do Vim, que falham em capturar aninhamentos complexos de ambientes ou delimitadores matemáticos.
  - O recurso de folding de seções (`\section`, `\subsection`) e ambientes (`\begin{figure}`) não funciona adequadamente.
  - O cabeçalho de contexto fixo no topo da tela (`treesitter-context`) não exibe em qual seção ou ambiente o cursor se encontra ao rolar documentos extensos.
- **Ganhos Esperados:**
  - Realce sintático de altíssima velocidade e precisão cromática (ambientes, comandos, argumentos opcionais e blocos de equações).
  - Dobradura estruturada do documento (`zc`/`zo`) por seções e equações.
  - Contexto de cabeçalho persistente no topo da janela através do `treesitter-context` já instalado.
- **Novas Dependências:** Parsers compilados de treesitter (`tree-sitter-latex`, `tree-sitter-bibtex`), instalados de forma automática e transparente pelo `nvim-treesitter`.
- **Quebras Potenciais:** Nenhuma.

---

### 4.3 Comportamento de Delimitadores e Cifrões (`windwp/nvim-autopairs`)
- **Descrição:** O repositório utiliza `windwp/nvim-autopairs`. Em LaTeX, o caractere de cifrão `$` é amplamente usado para fórmulas inline (`$x + y$`) e display math (`$$...$$`).
- **Ajuste Proposto:** Ajustar as regras do `nvim-autopairs` especificamente para buffers `tex`, garantindo que:
  - Digitar `$` feche automaticamente com `$`, posicionando o cursor no meio.
  - Digitar um segundo `$` crie o ambiente display math `$$ ... $$` sem duplicar caracteres incorretamente.
  - Evitar inserção de par caso o próximo caractere seja `%` (comentário) ou se o caractere anterior for `\` (escape de dólar na prosa, e.g. `\$100`).
  - Preservar a deleção nativa do par vazio com `<BS>`, permitindo que apagar o primeiro cifrão remova simultaneamente o cifrão de fechamento correspondente.
- **Atenção Técnica sobre Padrões Lua (`cond.not_before_regex`):** Nas strings literais em colchetes do Lua (`[[...]]`), nenhum caractere de escape de barra invertida é interpretado pelo lexer (ao contrário de strings comuns entre aspas). Além disso, no motor de busca por padrões nativo do Lua (`string.match`), o caractere de escape de padrões é `%`, e não `\`. Portanto, o padrão para casar exatamente uma barra invertida em colchetes longos é `[[\]]`. Especificar `[[\\]]` resulta em duas barras invertidas literais na busca, falhando em casar com a barra simples em `\$100` e permitindo falsos emparelhamentos indesejados.
- **Atenção Técnica sobre Deleção de Pares (`with_del`):** Em um par vazio recém-criado `$$` com o cursor posicionado no centro, o caractere imediatamente à direita do cursor é o próprio cifrão de fechamento `$`. Se uma regra como `:with_del(cond.not_after_regex("[^%s]"))` for empregada, a verificação classificará o cifrão de fechamento como caractere não-espaço (`[^%s]`) e bloqueará o acionamento do backspace, quebrando a deleção do par. No `nvim-autopairs`, a regra básica `Rule("$", "$")` já implementa de forma segura a remoção coordenada do par quando o cursor se encontra entre eles, dispensando cláusulas `with_del` redundantes.
- **Código Ilustrativo de Aplicação:**
  ```lua
  -- Em lua/vinimello/plugins/autopairs.lua:
  return {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      opts = {},
      config = function(_, opts)
          local npairs = require("nvim-autopairs")
          local Rule = require("nvim-autopairs.rule")
          local cond = require("nvim-autopairs.conds")

          npairs.setup(opts)

          npairs.add_rules({
              Rule("$", "$", { "tex", "latex", "plaintex" })
                  :with_pair(cond.not_after_regex("%%"))
                  :with_pair(cond.not_before_regex([[\]], 1))
                  :with_move(cond.none())
                  :with_cr(cond.none()),
              Rule("$$", "$$", { "tex", "latex", "plaintex" })
                  :with_pair(cond.not_after_regex("%%"))
                  :with_pair(cond.not_before_regex([[\]], 1)),
          })
      end,
  }
  ```
- **Ganhos Esperados:**
  - Fluidez ao escrever equações sem necessidade de fechar manualmente cada delimitador ou deletar cifrões sobressalentes.
  - Prevenção precisa e empiricamente validada de falso emparelhamento ao digitar preços ou valores em dólares como `\$50`.
  - Deleção coordenada e natural do par vazio `$$` com um único toque em `<BS>`.
- **Novas Dependências:** Nenhuma.
- **Quebras Potenciais:** Nenhuma.

---

### 4.4 Mapeamentos de Teclas Dedicados (`<leader>l*`)
- **Descrição:** Definir atalhos mnemônicos dedicados sob o prefixo `<leader>l` (LaTeX), respeitando estritamente o mapa de teclas existente do repositório.
- **Prevenção de Colisão com `<leader>lg` (LazyGit):** O repositório já possui o atalho global `<leader>lg` registrado para acionar o LazyGit (`lua/vinimello/plugins/lazgit.lua`). Para evitar sobreposição ou atraso no reconhecimento de comandos (`timeoutlen`), a família de atalhos LaTeX **não utiliza** `<leader>lg`. O grafo de dependências do TexLab é mapeado exclusivamente para `<leader>ld`, e a listagem de ambientes para `<leader>lf`.
- **Escopo Buffer-Local e Nomes dos Comandos:**
  - No Neovim v0.11+ / v0.12 com a versão ativa do `nvim-lspconfig`, os comandos gerados no handshake de anexo do TexLab utilizam obrigatoriamente o prefixo `Lsp` e são registrados no escopo buffer-local: `:LspTexlabBuild`, `:LspTexlabForward`, `:LspTexlabCancelBuild`, `:LspTexlabCleanAuxiliary`, `:LspTexlabCleanArtifacts`, `:LspTexlabChangeEnvironment`, `:LspTexlabFindEnvironments`, `:LspTexlabDependencyGraph`.
  - Vincular esses mapeamentos globalmente em `init.lua` resultaria em erro `E492: Not an editor command: LspTexlabBuild` ao pressionar o atalho em arquivos Lua ou Python. Portanto, a proposta correta é registrá-los como buffer-local em `after/ftplugin/tex.lua` (ou dentro do callback `on_attach` do LSP).
- **Tabela de Atalhos Proposta:**

| Atalho | Modo | Comando Executado | Descrição |
| :--- | :---: | :--- | :--- |
| `<leader>lb` | `n` | `<cmd>LspTexlabBuild<CR>` | Compila o documento atual ou arquivo principal (`latexmk`) |
| `<leader>lv` | `n` | `<cmd>LspTexlabForward<CR>` | Sincroniza e abre o PDF na linha atual do cursor (SyncTeX) |
| `<leader>lc` | `n` | `<cmd>LspTexlabCleanAuxiliary<CR>` | Remove arquivos intermediários (`.aux`, `.log`, `.synctex.gz`) |
| `<leader>lC` | `n` | `<cmd>LspTexlabCleanArtifacts<CR>` | Remove todos os artefatos de build incluindo o PDF final |
| `<leader>le` | `n` | `<cmd>LspTexlabChangeEnvironment<CR>` | Altera o nome do ambiente atual (`\begin{...}`) de forma interativa |
| `<leader>lf` | `n` | `<cmd>LspTexlabFindEnvironments<CR>` | Lista os ambientes ativos ao redor da posição atual do cursor |
| `<leader>ld` | `n` | `<cmd>LspTexlabDependencyGraph<CR>` | Exibe o grafo de dependências dos arquivos incluídos |
| `<leader>lk` | `n` | `<cmd>LspTexlabCancelBuild<CR>` | Cancela uma compilação em andamento caso haja loop infinito |

- **Código Ilustrativo de Registro (`after/ftplugin/tex.lua`):**
  ```lua
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
  ```
- **Ganhos Esperados:**
  - Controle completo do fluxo de produção de artigos sem sair do teclado.
  - Zero risco de erros `E492` em buffers não-LaTeX e zero colisão com `<leader>lg` (LazyGit).
- **Novas Dependências:** Nenhuma. Os comandos `LspTexlab*` são criados nativamente pelo `nvim-lspconfig` ao conectar o `texlab`.
- **Quebras Potenciais:** Nenhuma colisão com atalhos existentes no repositório.

---

## 5. Impacto em Desempenho, Tempo de Carregamento e Dependências

### 5.1 Tempo de Carregamento e Desempenho Geral
- **Lazy-Loading Preservado:**
  - O `nvim-lspconfig` só inicializa o binário do `texlab` quando um arquivo do tipo `tex`, `plaintex` ou `bib` for aberto. O tempo de inicialização global do Neovim (medido ao abrir outros projetos em Lua, Python, C ou o starter page `alpha`) **não sofre nenhum impacto** e continuará na faixa de poucos milissegundos.
  - A inclusão de `sources.per_filetype.tex` no `blink.cmp` na verdade **economiza ciclos de CPU**, pois descarta a avaliação da fonte `markdown` e reduz o overhead de busca em buffer ao digitar fórmulas.
- **Consumo de Memória:**
  - O `texlab` é desenvolvido em Rust e consome em média entre 15MB e 45MB de RAM para documentos de médio a grande porte, sendo consideravelmente mais leve e responsivo que servidores baseados em Node.js ou Java.

### 5.2 Matriz de Dependências Externas

| Componente | Tipo | Situação no Sistema Local | Impacto se Ausente |
| :--- | :---: | :---: | :--- |
| **`texlab`** | Binário CLI | ✅ Instalado (`/opt/homebrew/bin/texlab`) | Servidor LSP não inicia para arquivos `.tex` |
| **`latexmk`** | Binário CLI | ✅ Instalado (`/Library/TeX/texbin/latexmk`) | Compilação automatizada via LSP indisponível |
| **`Skim.app`** | App macOS | ✅ Instalado (`/Applications/Skim.app`) | Forward search via `displayline` indisponível |
| **`treesitter latex/bibtex`** | Parser TS | 🔄 Requer `:TSInstall latex bibtex` | Fallback transparente para syntax regex do Vim |
| **`chktex`** | Binário CLI | ✅ Presente na distribuição TeX padrão | Diagnósticos tipográficos desativados |
| **`SumatraPDF`** | App Windows | ℹ️ Opcional para Windows | Fallback para visualizador padrão do sistema |

---

## 6. Riscos, Quebras Potenciais e Estratégias de Mitigação

1. **Risco de Compilação Contínua Bloquear Edição:**
   - *Problema:* Se a opção `texlab.build.onSave = true` for utilizada em documentos com dezenas de páginas ou muitas figuras em alta resolução, o `latexmk` será acionado a cada salvamento, gerando concorrência de compilação.
   - *Mitigação:* Manter `build.onSave = false` como recomendação padrão e utilizar o atalho `<leader>lb` para compilação explícita sob demanda. Caso o usuário deseje compilação contínua ao salvar, instruí-lo a configurar `build.forwardSearchAfter = true` em paralelo.

2. **Risco de Ruído Visual de Diagnósticos com `tiny-inline-diagnostic`:**
   - *Problema:* O `chktex` do `texlab` aponta dezenas de advertências puramente de estilo tipográfico (exemplo: espaço antes de citação em vez de til `~`). Como a configuração utiliza diagnósticos inline com `update_in_insert = true`, alertas podem piscar na tela a cada caractere.
   - *Mitigação:* Configurar `chktex.onEdit = false` e `chktex.onOpenAndSave = true`, garantindo que os avisos só sejam recalculados quando o arquivo for salvo ou aberto, além de ajustar `diagnosticsDelay = 300`.

3. **Risco de Conflitos em Projetos com Subarquivos:**
   - *Problema:* Abrir diretamente `sections/intro.tex` sem um arquivo de configuração de raiz pode fazer o `texlab` compilar o subarquivo isolado, gerando erro de compilação por falta do `\begin{document}`.
   - *Mitigação:* Documentar a adoção de um arquivo marcador `.texlabroot` na raiz do projeto do artigo ou manter o arquivo principal com nome canônico reconhecido pelo `latexmkrc`.

4. **Risco de Falha de Formatação por Dependência Perl em `latexindent`:**
   - *Problema:* Em distribuições MacTeX padrão no macOS, o binário `/Library/TeX/texbin/latexindent` falha fatalmente com `Can't locate File/HomeDir.pm in @INC` pela ausência de módulos CPAN no ambiente base do Perl. Como o `nvim-lspconfig` adota `latexFormatter = 'latexindent'` por padrão, invocar `vim.lsp.buf.format()` em um buffer TeX geraria erros no Neovim.
   - *Mitigação:* Definir explicitamente `latexFormatter = "none"` na tabela de settings do TexLab (conforme Seção 3.6), mantendo ativa a formatação limpa e nativa de arquivos `.bib` via `bibtexFormatter = "texlab"`.

5. **Risco de Bloqueio em Inicialização por Download Interativo de Dicionário `spell`:**
   - *Problema:* Se `vim.opt_local.spell = true` for ativado com `spelllang = { "pt_br", ... }` antes do arquivo de dicionário em português ser baixado, o Neovim interrompe o fluxo exibindo o prompt `No spell file found for pt (utf-8). Download? [y/N]`. Em contextos não interativos, scripts ou execuções headless, o processo trava aguardando stdin.
   - *Mitigação:* Definir `spelllang = { "en_us" }` como padrão inicial seguro e instruir o autor a rodar uma única vez `:set spelllang=en_us,pt_br` no Neovim interativo para baixar `pt.utf-8.spl` em `~/.local/share/nvim/site/spell/`.

6. **Risco de Conflito de Atalhos com LazyGit (`<leader>lg`):**
   - *Problema:* O repositório já possui o atalho global `<leader>lg` associado ao LazyGit (`lua/vinimello/plugins/lazgit.lua`). Atribuir atalhos de grafo do LaTeX colidindo com `<leader>lg` quebraria a ergonomia ou provocaria atrasos por `timeoutlen`.
   - *Mitigação:* O comando `:LspTexlabDependencyGraph` foi mapeado para `<leader>ld`, e `:LspTexlabFindEnvironments` para `<leader>lf`, garantindo que `<leader>lg` continue 100% exclusivo ao LazyGit.

---

## 7. Roteiro de Implementação Sugerido (Para Aprovação)

Caso esta proposta seja aprovada pelo usuário, a implementação pode ser realizada cirurgicamente em **três fases incrementais**, sem risco de quebra:

### Fase 1: Essencial & LSP / Completions (Zero Dependências Novas)
1. **`lua/vinimello/plugins/lsp.lua`**:
   - Configurar o `texlab` na tabela de servidores com `settings.texlab` integrado (compilação `latexmk`, SyncTeX bidirecional macOS/Windows via detecção de OS, debounce de `chktex`, `latexFormatter = "none"`, autocompletar e formatação de referências `.bib` via Opção A aprovada pelo usuário), conforme os snippets das **Seções 2.3 e 3.6**.
2. **`lua/vinimello/plugins/cmp.lua`**:
   - Aplicar a configuração consolidada da **Seção 2.6**, contemplando `sources.per_filetype.tex`, desbloqueio dinâmico de `{` em `show_on_x_blocked_trigger_characters` e limiar dinâmico de 4 caracteres para o provider `buffer`.

### Fase 2: Sintaxe, Prosa e Atalhos de Buffer
1. **`lua/vinimello/plugins/treesitter.lua`**:
   - Inserir `"latex"` e `"bibtex"` na tabela `ensure_installed`, ativando o parsing de sintaxe de alta velocidade e folding estruturado via Treesitter.
2. **`after/ftplugin/tex.lua`** (novo arquivo):
   - Ativar `wrap`, `linebreak`, `spell` (`en_us`), e registrar os atalhos buffer-local sob `<leader>l*` mapeados para os comandos nativos `:LspTexlab*` (incluindo `<leader>lf` para ambientes e `<leader>ld` para dependências, sem colidir com `<leader>lg`), conforme **Seção 4.4**.

### Fase 3: Refinamento Avançado
1. **`lua/vinimello/plugins/autopairs.lua`**:
   - Configurar regras do `nvim-autopairs` com detecção robusta e validada de escape (`cond.not_before_regex([[\]], 1)`) e deleção nativa de pares vazios para emparelhamento automático de `$` e `$$` em arquivos `tex`, `latex` e `plaintex`, conforme **Seção 4.3**.
2. **Instruções ao Usuário para Inverse Search (Skim no macOS)**:
   - Configurar nas Preferências do Skim (`Sync` -> `PDF-TeX Sync support`):
     - *Preset:* `Custom`
     - *Command:* `/usr/local/bin/nvim` (ou caminho retornado por `which nvim`)
     - *Arguments:* `--server "$NVIM" --remote-send "<C-\><C-N>:edit +%line %file<CR>"`

---

*Fim da Proposta.*
