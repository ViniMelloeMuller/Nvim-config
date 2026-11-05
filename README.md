# NVIM CONFIG - Vinicius Mello

Configuração pessoal modular para o Neovim (v0.11+ / v0.12), orientada ao `lazy.nvim` com suporte multiplataforma (macOS e Windows).

Outros CLI tools que uso constantemente podem ser vistos em [`extras.md`](extras.md).

---

## Pré-requisitos & Componentes Obrigatórios

Esta configuração utiliza a API nativa de LSP do Neovim com `blink.cmp`. Servidores de linguagem e utilitários de sistema devem ser instalados externamente via gerenciador de pacotes:

- **macOS**: [Homebrew](https://brew.sh)
- **Windows**: [Scoop](https://scoop.sh)

### 1. Servidores de Linguagem (LSP)

Instale os servidores configurados em [`lua/vinimello/plugins/lsp.lua`](lua/vinimello/plugins/lsp.lua):

#### macOS (Homebrew)
```bash
brew install lua-language-server pyright llvm gopls texlab
```
*(Nota: `llvm` fornece o `clangd`).*

#### Windows (Scoop)
```powershell
scoop install lua-language-server pyright llvm gopls texlab
```

---

### 2. Utilitários de Busca e Compilação

- **`ripgrep`** *(obrigatório para busca de arquivos e texto com Telescope)*:
  ```bash
  # macOS
  brew install ripgrep

  # Windows
  scoop install ripgrep
  ```

- **LaTeX & Visualizador PDF** *(para compilação via `<leader>b` e SyncTeX com TexLab)*:
  - **Distribuição TeX**: MacTeX (macOS) ou MiKTeX / TeX Live (Windows) — fornece `latexmk` e `lualatex`.
  - **Visualizador PDF**:
    - macOS: [Skim](https://skim-app.sourceforge.io/) (com suporte a SyncTeX configurado).
    - Windows: [SumatraPDF](https://www.sumatrapdfreader.org/).

---

### 3. Dicionário de Verificação Ortográfica (Português)

A verificação ortográfica nativa (`spell`) está habilitada para arquivos **LaTeX**, **Markdown** e **mensagens de commit do Git**. O Neovim necessita do arquivo `pt.utf-8.spl` no seu diretório de dados para validar termos em português em conjunto com o inglês.

Execute o comando correspondente ao seu sistema operacional:

#### macOS / Linux
```bash
curl -fLo ~/.local/share/nvim/site/spell/pt.utf-8.spl --create-dirs https://ftp.nluug.nl/pub/vim/runtime/spell/pt.utf-8.spl
```

#### Windows (PowerShell)
```powershell
New-Item -ItemType Directory -Force -Path "$HOME\AppData\Local\nvim-data\site\spell"
Invoke-WebRequest -Uri "https://ftp.nluug.nl/pub/vim/runtime/spell/pt.utf-8.spl" -OutFile "$HOME\AppData\Local\nvim-data\site\spell\pt.utf-8.spl"
```

---

## Atalhos Principais (Cheatsheet)

> **Nota:** A `<leader>` key é o **espaço** (`<Space>`).

### 1. LSP & Diagnósticos

A configuração adota os atalhos nativos do Neovim 0.11+ / 0.12 combinados com atalhos personalizados.

| Atalho | Modo | Descrição | Origem |
| :--- | :---: | :--- | :--- |
| `gd` | Normal | Ir para a definição do símbolo sob o cursor | Nativo / Custom |
| `gD` | Normal | Ir para a declaração do símbolo | Custom |
| `grn` | Normal | Renomear símbolo (*Rename*) | Nativo (0.11+) |
| `grr` | Normal | Listar referências do símbolo (*References*) | Nativo (0.11+) |
| `gri` | Normal | Ir para implementação (*Implementation*) | Nativo (0.11+) |
| `gra` ou `<leader>ca` | Normal | Ações de código (*Code Action*) | Nativo / Custom |
| `gO` | Normal | Listar símbolos do documento atual (*Outline*) | Nativo (0.11+) |
| `K` | Normal | Exibir documentação / informações de tipo (*Hover*) | Nativo |
| `<C-s>` | Insert | Exibir ajuda de assinatura de parâmetros | Nativo (0.11+) |
| `[d` / `]d` | Normal | Pular para diagnóstico anterior / próximo | Nativo |

---

### 2. Navegação, Busca & Gerenciamento de Buffers

| Atalho | Modo | Descrição |
| :--- | :---: | :--- |
| `<leader>F` | Normal | Buscar arquivos por nome no projeto (Telescope) |
| `<leader>g` | Normal | Busca por conteúdo de texto / Live Grep (Telescope) |
| `<leader>sr` | Normal / Visual | Busca e substituição interativa no projeto (Grug-Far) |
| `<leader>n` | Normal | Alternar painel da árvore de arquivos (NvimTree) |
| `<leader>d` | Normal | Abrir o painel inicial / Dashboard (Alpha) |
| `<C-j>` | Normal | Pular para o próximo buffer |
| `<C-k>` | Normal | Pular para o buffer anterior |
| `<leader>f` | Normal | Iniciar busca por termo no buffer atual (`/`) |
| `0` | Normal | Ir para o primeiro caractere não-branco da linha (`^`) |
| `<leader><CR>` | Normal | Limpar o destaque visual de buscas ativas (`:noh`) |
| `<leader>w` | Normal | Salvar buffer atual forçadamente (`:w!`) |

---

### 3. Painéis de Diagnósticos & Símbolos (Trouble)

| Atalho | Modo | Descrição |
| :--- | :---: | :--- |
| `<leader>xx` | Normal | Alternar painel de diagnósticos de todo o projeto |
| `<leader>xX` | Normal | Alternar diagnósticos exclusivos do buffer atual |
| `<leader>cs` | Normal | Alternar painel de símbolos do arquivo (árvore/outline) |
| `<leader>cS` | Normal | Alternar referências e definições LSP |
| `[q` / `]q` | Normal | Pular para item anterior / próximo no Trouble ou Quickfix |

---

### 4. Git & Controle de Versão (Gitsigns)

| Atalho | Modo | Descrição |
| :--- | :---: | :--- |
| `}` | Normal | Pular para a **próxima alteração Git** (*hunk*) ou próximo parágrafo |
| `{` | Normal | Pular para a **alteração Git anterior** (*hunk*) ou parágrafo anterior |

---

### 5. Compilação & Artefatos (Build Actions)

| Atalho | Modo | Descrição |
| :--- | :---: | :--- |
| `<leader>b` | Normal | Compilação ciente de tipo de arquivo (LaTeX com `latexmk`, C, C++, etc.) |
| `<leader>o` | Normal | Abrir o artefato compilado gerado (ex.: PDF do LaTeX no visualizador) |

---

### 6. LaTeX & TexLab (Específico de Buffers `.tex`)

| Atalho | Modo | Descrição |
| :--- | :---: | :--- |
| `<leader>lb` | Normal | TexLab: Compilar documento |
| `<leader>lv` | Normal | TexLab: Forward search no visualizador PDF (SyncTeX) |
| `<leader>lc` | Normal | TexLab: Limpar arquivos auxiliares de compilação |
| `<leader>lC` | Normal | TexLab: Limpar todos os artefatos |
| `<leader>le` | Normal | TexLab: Alterar ambiente (`\begin{...}`) |
| `<leader>lf` | Normal | TexLab: Listar ambientes ativos |
| `<leader>ld` | Normal | TexLab: Grafo de dependências |
| `<leader>lk` | Normal | TexLab: Cancelar compilação em andamento |

---

### 7. Terminal Flutuante (Floaterm)

| Atalho | Modo | Descrição |
| :--- | :---: | :--- |
| `<F12>` | Todos | Alternar visibilidade da janela do terminal flutuante |
| `<F7>` | Todos | Abrir uma nova instância de terminal |
| `<F10>` | Todos | Encerrar (*kill*) o terminal flutuante ativo |

---

### 8. Ortografia & Prosa (Spell Checking)

Habilitado automaticamente para `tex`, `markdown` e `gitcommit`:

| Atalho | Modo | Descrição |
| :--- | :---: | :--- |
| `]s` | Normal | Pular para a **próxima** palavra incorreta |
| `[s` | Normal | Pular para a **palavra anterior** incorreta |
| `z=` | Normal | Abrir lista de **sugestões de correção** para a palavra sob o cursor |
| `zg` | Normal | Adicionar palavra ao dicionário pessoal como correta (*Good*) |
| `zw` | Normal | Marcar palavra como incorreta (*Wrong*) |
| `zug` | Normal | Desfazer adição de palavra (`zg`) |
| `j` / `k` | Normal/Visual | Navegação visual por linhas dobradas (*wrapped lines*) |
