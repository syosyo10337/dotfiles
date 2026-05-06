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
        -- 根本バグ: rainbow-delimiters/lib.lua:202 が parser==nil を
        -- 検査せず parser:register_cbs を呼ぶ。Neovim 0.12 で
        -- vim.treesitter.get_parser() が「失敗時に nil を返す」仕様に
        -- 変わったが rainbow-delimiters 側が追従していないため。
        --
        -- nil parser が発生する条件:
        --   (a) 非実ファイルバッファ (snacks notif/picker, noice popup 等)
        --   (b) 実ファイルだが filetype に対応する parser が無い (zsh 等)
        if vim.bo[bufnr].buftype ~= "" then return false end
        local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
        return ok and parser ~= nil
      end,
    })
  end,
}
