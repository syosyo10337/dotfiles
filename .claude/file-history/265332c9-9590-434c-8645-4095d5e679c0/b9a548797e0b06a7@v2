return {
  -- Biome LSP (linter + formatter diagnostics)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        biome = {},
      },
    },
  },

  -- Biome as formatter via conform.nvim
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        css = { "biome" },
        markdown = { "markdownlint-cli2", "prettier" },
        ["markdown.mdx"] = { "markdownlint-cli2", "prettier" },
      },
    },
  },
}
