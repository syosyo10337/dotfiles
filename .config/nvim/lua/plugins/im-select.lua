return {
  {
    "keaising/im-select.nvim",
    config = function()
      require("im_select").setup({
        default_command = "/opt/homebrew/bin/im-select",
        default_im_select = "com.apple.keylayout.US",
        set_previous_events = { "InsertEnter" },
      })
    end,
  },
}
