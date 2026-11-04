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

## Atalhos Principais de Ortografia (Modo Normal)

- `]s` / `[s`: Pula para a próxima / anterior palavra incorreta.
- `z=`: Lista sugestões de correção para a palavra sob o cursor.
- `zg`: Adiciona a palavra ao dicionário pessoal como correta.
- `zw`: Marca a palavra como incorreta.
- `zug`: Desfaz a adição de uma palavra.
