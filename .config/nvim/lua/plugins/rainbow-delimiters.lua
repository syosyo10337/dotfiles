return {
  "HiPhish/rainbow-delimiters.nvim",
  init = function()
    -- Workaround:
    -- snacks.nvim の通知ウィンドウのスタイル定義 (snacks/notifier.lua の
    -- `Snacks.config.style("notification", { ft = "markdown", ... })`) によって
    -- 通知バッファに filetype=markdown がセットされた瞬間、rainbow-delimiters の
    -- FileType autocmd が発火し、scratch バッファ (buftype="nofile") に対して
    -- attach を試みて lib.lua:202 `parser:register_cbs` で失敗する。
    --
    -- rainbow-delimiters は `vim.g.rainbow_delimiters.condition` をフックとして
    -- 公開しているので、ここで attach の可否を制御する。
    vim.g.rainbow_delimiters = vim.tbl_deep_extend("force", vim.g.rainbow_delimiters or {}, {
      ---@param bufnr integer
      ---@return boolean
      condition = function(bufnr)
        -- 真のバグは rainbow-delimiters/lib.lua:202: Neovim 0.12 で
        -- vim.treesitter.get_parser() が「失敗時に nil を返す」仕様に
        -- 変わったが、rainbow-delimiters は pcall の success のみ見て
        -- parser==nil を検査せずに parser:register_cbs を呼ぶ。
        --
        -- 実ファイルバッファ (buftype="") 以外では parser を取れず、
        -- かつ rainbow を効かせる必要もない (snacks notif/picker/terminal,
        -- noice popup, blink.cmp menu, flash prompt 等) ため除外する。
        return vim.bo[bufnr].buftype == ""
      end,
    })
  end,
}
