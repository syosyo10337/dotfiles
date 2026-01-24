local wezterm = require("wezterm")
-- 設定オブジェクトを初期化
local config = wezterm.config_builder()

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
config.hide_tab_bar_if_only_one_tab = true
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

-- 設定変更時に自動リロード
config.automatically_reload_config = true

return config
