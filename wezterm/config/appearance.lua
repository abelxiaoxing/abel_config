local wezterm = require("wezterm")
local platform = require("utils.platform")()

local function get_integrated_title_button_style()
	if platform.is_mac then
		return "Mac"
	elseif platform.is_linux then
		return "Gnome"
	else
		return "Windows"
	end
end

local config = {
	term = "xterm-256color",
	animation_fps = 60,
	max_fps = 60,
	front_end = "WebGpu",
	webgpu_power_preference = "HighPerformance",

	color_scheme = "Gruvbox dark, medium (base16)",

	-- 背景
	window_background_opacity = 1.00,
	window_background_gradient = {
		colors = { "#1D261B", "#261A25" },
		-- 指定从左上角开始的线性渐变
		orientation = { Linear = { angle = -45.0 } },
	},
	background = {
		{
			source = { File = wezterm.config_dir .. "/backdrops/dark.png" },
			hsb = { brightness = 0.9 },
			-- 使图片居中显示
			width = "Contain",
			height = "Contain",
			horizontal_align = "Center",
			vertical_align = "Middle",
			repeat_x = "NoRepeat",
			repeat_y = "NoRepeat",
		},
		{
			source = { Color = "#1A1B26" },
			height = "100%",
			width = "100%",
			opacity = 0.95,
		},
	},

	-- 滚动条
	enable_scroll_bar = true,
	min_scroll_bar_height = "3cell",
	colors = {
		scrollbar_thumb = "#34354D",
	},

	-- 标签栏
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = false,
	use_fancy_tab_bar = true,
	tab_max_width = 25,
	show_tab_index_in_tab_bar = true,
	switch_to_last_active_tab_when_closing_tab = true,

	-- 光标
	default_cursor_style = "BlinkingBlock",
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",
	cursor_blink_rate = 700,

	-- 窗口
	adjust_window_size_when_changing_font_size = false,
	-- window_decorations = "INTEGRATED_BUTTONS|RESIZE", -- 默认配置，显示所有窗口按钮
	window_decorations = "RESIZE", -- 隐藏窗口按钮，仅保留调整大小功能
	integrated_title_button_style = get_integrated_title_button_style(),
	integrated_title_button_color = "auto",
	integrated_title_button_alignment = "Right",
	initial_cols = 120,
	initial_rows = 24,
	window_padding = {
		left = 5,
		right = 10,
		top = 12,
		bottom = 7,
	},
	window_close_confirmation = "AlwaysPrompt",
	window_frame = {
		active_titlebar_bg = "#0F2536",
		inactive_titlebar_bg = "#0F2536",
	},
	inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 },
}

if platform.is_win then
	config.win32_system_backdrop = "Acrylic"
end

return config