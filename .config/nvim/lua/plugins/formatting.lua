return {
  -- Biome LSP (linter + formatter diagnostics)
  -- formatting.biome extras は formatter 登録のみで LSP は登録しないため、
  -- リアルタイム diagnostics を得る目的でここに残す。
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        biome = {},
      },
    },
  },

  -- markdown formatter は formatting.biome extras の supported に含まれないため、
  -- prettier + markdownlint-cli2 をここで明示する。
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "prettier", "markdownlint-cli2" },
        ["markdown.mdx"] = { "prettier", "markdownlint-cli2" },
      },
    },
  },
}
