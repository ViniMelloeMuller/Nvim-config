-- lazy.nvim
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    presets = {
      bottom_search=false,
      command_palette=false,
      inc_rename=false,
      lsp_doc_border=false,
      long_message_to_split=false
    },
    notify = {
      enabled=true,
    }
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
       "rcarriga/nvim-notify",
       opts = {
        render = "compact",
        stages = "fade",
        timeout = 2000,
       },
    },
  },
}
