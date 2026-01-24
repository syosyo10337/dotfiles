local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- キーバインド設定を読み込む
local keybinds = require("keybinds")
config.leader = keybinds.leader
config.keys = keybinds.keys

-- === 基本設定 ===
config.font = wezterm.font("Moralerspace Argon")
config.font_size = 16.0
config.use_ime = true
config.color_scheme = "Gruvbox dark, soft (base16)"

--透過率
config.window_background_opacity = 0.8
config.macos_window_background_blur = 15

-- ウィンドウ装飾（タイトルバーなし、リサイズ可能）
config.window_decorations = "RESIZE"

-- tab setting
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_right_half_circle_thick

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local tab_bar_bg = "#1e1e1e"
	local background = "#d5c4a1" -- bg2 (非アクティブタブ)
	local foreground = "#665c54" -- fg3 (非アクティブ文字)

	if tab.is_active then
		background = "#79740e" -- yellow (アクティブタブ)
		foreground = "#fbf1c7" -- bg (明るい文字)
	end

	local title = " " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. " "

	return {
		-- 左の丸み
		{ Background = { Color = tab_bar_bg } },
		{ Foreground = { Color = background } },
		{ Text = SOLID_LEFT_ARROW },
		-- タブ本体
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		-- 右の丸み
		{ Background = { Color = tab_bar_bg } },
		{ Foreground = { Color = background } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

-- LEADERキーの状態をステータスバーに表示
wezterm.on("update-status", function(window, pane)
	local leader = ""
	if window:leader_is_active() then
		leader = " LEADER "
	end
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#fabd2f" } },
		{ Background = { Color = "#3c3836" } },
		{ Text = leader },
	}))
end)

-- 設定変更時に自動リロード
config.automatically_reload_config = true

return config
