return {
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
      },
      formatters = {
        ["markdownlint-cli2"] = {
          condition = function()
            return true
          end,
        },
      },
    },
  },
}
