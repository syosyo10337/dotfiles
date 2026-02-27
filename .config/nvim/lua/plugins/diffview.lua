return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File History (all)" },
  },
  opts = {
    hooks = {
      diff_buf_read = function()
        vim.opt_local.foldenable = false
      end,
    },
    view = {
      default = { layout = "diff2_horizontal" },
    },
  },
}
