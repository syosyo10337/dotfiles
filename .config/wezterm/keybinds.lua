local wezterm = require("wezterm")
local act = wezterm.action

-- Leaderキー有効時にステータスバーに表示
wezterm.on("update-right-status", function(window, pane)
	local leader = ""
	if window:leader_is_active() then
		leader = " LEADER "
	end
	window:set_right_status(leader)
end)

local M = {}

-- Leader: Ctrl+s (shorthand!)
M.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }

M.keys = {
	-- ===== ペイン分割 =====
	{ key = "v", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "s", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-- ===== ペイン移動 (hjkl) =====
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- ===== ペイン操作 =====
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState }, -- ペイン最大化トグル
	{ key = "g", mods = "LEADER", action = act.PaneSelect }, -- ペイン選択UI

	-- ===== タブ操作 =====
	{ key = "c", mods = "LEADER", action = act.SpawnTab("DefaultDomain") }, -- 新規タブ
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) }, -- 次のタブ
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) }, -- 前のタブ

	-- ===== その他 =====
	{ key = "[", mods = "LEADER", action = act.ActivateCopyMode }, -- コピーモード
	{ key = "]", mods = "LEADER", action = act.PasteFrom("Clipboard") }, -- ペースト
}

return M
