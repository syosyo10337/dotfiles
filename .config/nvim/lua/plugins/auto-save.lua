return {
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      -- 1秒後に自動保存 (VSCodeのafterDelayと同様)
      debounce_delay = 1000,
      -- auto-save時はBufWritePreを発火させない (フォーマットは手動セーブ時のみ)
      noautocmd = true,
    },
  },
}
