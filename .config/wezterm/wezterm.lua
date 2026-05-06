local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- キーバインド設定を読み込む
local keybinds = require("keybinds")
config.leader = keybinds.leader
config.keys = keybinds.keys

-- === 基本設定 ===
config.max_fps = 120
config.font = wezterm.font("Moralerspace Argon")
config.font_size = 12.0
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
config.use_fancy_tab_bar = true

-- Gruvbox カラーパレット
local gruvbox = {
	bg0 = "#282828",
	bg1 = "#3c3836",
	bg2 = "#504945",
	fg0 = "#fbf1c7",
	fg1 = "#ebdbb2",
	fg4 = "#a89984",
	orange = "#fe8019",
	yellow = "#fabd2f",
}

config.window_frame = {
	font = wezterm.font("Moralerspace Argon"),
	font_size = 12.0,
}

-- タブのタイトルから番号を除去し、プロセス名だけ表示
wezterm.on("format-tab-title", function(tab)
	local title = tab.active_pane.title
	return " " .. title .. " "
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

-- ペイン境界線の色
config.colors = {
	split = gruvbox.orange, -- アクティブペインとの境界をオレンジで強調
	tab_bar = {
		background = gruvbox.bg0,
		active_tab = {
			bg_color = gruvbox.orange,
			fg_color = gruvbox.bg0,
		},
		inactive_tab = {
			bg_color = gruvbox.bg2,
			fg_color = gruvbox.fg4,
		},
		inactive_tab_hover = {
			bg_color = gruvbox.bg1,
			fg_color = gruvbox.fg1,
		},
		new_tab = {
			bg_color = gruvbox.bg0,
			fg_color = gruvbox.fg4,
		},
	},
}

-- 非アクティブペインを暗くする
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}

-- 中クリックペーストを無効化
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Middle" } },
		mods = "NONE",
		action = wezterm.action.Nop,
	},
	{
		event = { Down = { streak = 1, button = "Middle" } },
		mods = "NONE",
		action = wezterm.action.Nop,
	},
}

-- 設定変更時に自動リロード
config.automatically_reload_config = true

return config
